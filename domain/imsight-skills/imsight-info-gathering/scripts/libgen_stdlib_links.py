#!/usr/bin/env python3
"""Find LibGen direct download links using only Python's standard library."""

from __future__ import annotations

import argparse
import json
import re
import sys
import tomllib
from dataclasses import asdict, dataclass
from html import unescape
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable, List, Optional
from urllib.error import HTTPError, URLError
from urllib.parse import quote_plus, urljoin
from urllib.request import (
    ProxyHandler,
    Request,
    build_opener,
)


USER_AGENT = "Mozilla/5.0 libgen-stdlib-links/0.1"
LIBGEN_HOST_RE = re.compile(r"https?://([^/]*libgen\.[^/]+)", re.IGNORECASE)
GET_LINK_RE = re.compile(r"(?:^|/)get\.php\?md5=", re.IGNORECASE)
MD5_RE = re.compile(r"md5=([a-f0-9]{32})", re.IGNORECASE)
DEFAULT_CONFIG_PATH = (
    Path(__file__).resolve().parent.parent / "find-libgen.defaults.toml"
)


@dataclass
class Link:
    href: str
    text: str = ""


@dataclass
class Cell:
    text: str
    links: List[Link]


@dataclass
class Book:
    title: str
    authors: List[str]
    publisher: str
    year: str
    language: str
    pages: str
    size: str
    extension: str
    mirrors: List[str]
    direct_urls: List[str]


class TableParser(HTMLParser):
    """Small table/link collector for the LibGen result pages."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.tables: List[List[List[Cell]]] = []
        self._table_depth = 0
        self._table: List[List[Cell]] = []
        self._row: List[Cell] = []
        self._cell_text: List[str] = []
        self._cell_links: List[Link] = []
        self._active_href: Optional[str] = None
        self._active_link_text: List[str] = []
        self._in_cell = False
        self._in_row = False

    def handle_starttag(
        self, tag: str, attrs: List[tuple[str, Optional[str]]]
    ) -> None:
        attrs_dict = dict(attrs)
        if tag == "table":
            if self._table_depth == 0:
                self._table = []
            self._table_depth += 1
        elif tag == "tr" and self._table_depth:
            self._row = []
            self._in_row = True
        elif tag in {"td", "th"} and self._in_row:
            self._cell_text = []
            self._cell_links = []
            self._in_cell = True
        elif tag == "a" and self._in_cell:
            href = attrs_dict.get("href")
            if href:
                self._active_href = href
                self._active_link_text = []

    def handle_data(self, data: str) -> None:
        if self._in_cell:
            self._cell_text.append(data)
        if self._active_href is not None:
            self._active_link_text.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag == "a" and self._active_href is not None:
            self._cell_links.append(
                Link(
                    href=unescape(self._active_href),
                    text=normalize_text(" ".join(self._active_link_text)),
                )
            )
            self._active_href = None
            self._active_link_text = []
        elif tag in {"td", "th"} and self._in_cell:
            self._row.append(
                Cell(
                    text=normalize_text(" ".join(self._cell_text)),
                    links=self._cell_links,
                )
            )
            self._cell_text = []
            self._cell_links = []
            self._in_cell = False
        elif tag == "tr" and self._in_row:
            if self._row and self._table_depth == 1:
                self._table.append(self._row)
            self._row = []
            self._in_row = False
        elif tag == "table" and self._table_depth:
            self._table_depth -= 1
            if self._table_depth == 0:
                self.tables.append(self._table)
                self._table = []


def normalize_text(value: str) -> str:
    return " ".join(unescape(value).split())


def build_http_opener(proxy: Optional[str], no_proxy: bool):
    if no_proxy:
        return build_opener(ProxyHandler({}))
    if proxy:
        return build_opener(ProxyHandler({"http": proxy, "https": proxy}))
    return build_opener()


def load_defaults(config_path: str) -> dict[str, str]:
    path = Path(config_path).expanduser()
    if not path.exists():
        return {}
    with path.open("rb") as handle:
        config = tomllib.load(handle)
    defaults = config.get("defaults", {})
    if not isinstance(defaults, dict):
        return {}
    resolved: dict[str, str] = {}
    for key in ("mirror", "proxy"):
        value = defaults.get(key)
        if isinstance(value, str) and value.strip():
            resolved[key] = value.strip()
    return resolved


def fetch_text(url: str, opener, timeout: int) -> str:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    with opener.open(request, timeout=timeout) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, errors="replace")


def parse_tables(html: str) -> List[List[List[Cell]]]:
    parser = TableParser()
    parser.feed(html)
    parser.close()
    return parser.tables


def parse_authors(text: str) -> List[str]:
    return [part.strip() for part in re.split(r"[,;]", text) if part.strip()]


def search_books(
    query: str,
    mirror: str,
    opener,
    timeout: int,
    results: int,
    page: int,
) -> List[Book]:
    url = f"{mirror.rstrip('/')}/index.php?req={quote_plus(query)}&res={results}&page={page}"
    html = fetch_text(url, opener, timeout)
    tables = parse_tables(html)
    if len(tables) < 2:
        return []

    books: List[Book] = []
    for row in tables[1]:
        if len(row) < 9:
            continue
        title_cell = row[0]
        mirrors = [
            urljoin(mirror, link.href)
            for link in row[8].links
            if link.href and not link.href.startswith("#")
        ]
        if not mirrors:
            continue
        books.append(
            Book(
                title=title_cell.text,
                authors=parse_authors(row[1].text),
                publisher=row[2].text,
                year=row[3].text,
                language=row[4].text,
                pages=row[5].text,
                size=row[6].text,
                extension=row[7].text.lower(),
                mirrors=mirrors,
                direct_urls=[],
            )
        )
    return books


def find_direct_url(mirror_url: str, opener, timeout: int) -> Optional[str]:
    if not LIBGEN_HOST_RE.match(mirror_url):
        return None
    try:
        html = fetch_text(mirror_url, opener, timeout)
    except (HTTPError, URLError, TimeoutError, OSError):
        return None

    parser = TableParser()
    parser.feed(html)
    parser.close()

    for table in parser.tables:
        for row in table:
            for cell in row:
                for link in cell.links:
                    if GET_LINK_RE.search(link.href):
                        return urljoin(mirror_url, link.href)
    return None


def hydrate_direct_urls(
    books: Iterable[Book],
    opener,
    timeout: int,
    max_mirrors_per_book: int,
) -> None:
    for book in books:
        for mirror_url in book.mirrors[:max_mirrors_per_book]:
            direct_url = find_direct_url(mirror_url, opener, timeout)
            if direct_url:
                book.direct_urls.append(direct_url)


def book_matches(
    book: Book,
    title: Optional[str],
    author: Optional[str],
    year: Optional[str],
    extension: Optional[str],
) -> bool:
    if title and title.lower() not in book.title.lower():
        return False
    if author and author.lower() not in " ".join(book.authors).lower():
        return False
    if year and year != book.year:
        return False
    if extension and extension.lower().lstrip(".") != book.extension:
        return False
    return True


def wget_command(url: str, output: Optional[str], bytes_limit: Optional[int]) -> str:
    parts = ["wget"]
    if bytes_limit:
        parts.append(f"--header='Range: bytes=0-{bytes_limit - 1}'")
    if output:
        parts.extend(["-O", shell_quote(output)])
    parts.append(shell_quote(url))
    return " ".join(parts)


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def output_text(books: List[Book], wget_bytes: Optional[int]) -> None:
    for index, book in enumerate(books, start=1):
        print(f"[{index}] {book.title}")
        if book.authors:
            print(f"    authors: {', '.join(book.authors)}")
        details = [
            part
            for part in [
                book.publisher,
                book.year,
                book.language,
                book.size,
                book.extension,
            ]
            if part
        ]
        if details:
            print(f"    details: {' | '.join(details)}")
        for direct_url in book.direct_urls:
            md5_match = MD5_RE.search(direct_url)
            stem = md5_match.group(1) if md5_match else f"result-{index}"
            ext = book.extension or "download"
            output = f"{stem}.{ext}.part" if wget_bytes else f"{stem}.{ext}"
            print(f"    url: {direct_url}")
            print(f"    wget: {wget_command(direct_url, output, wget_bytes)}")


def output_json(books: List[Book]) -> None:
    print(json.dumps([asdict(book) for book in books], indent=2, ensure_ascii=False))


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Search a LibGen-style mirror and print direct URLs suitable for wget. "
            "Uses only Python's standard library."
        )
    )
    parser.add_argument(
        "query", help="Search keywords, title, author, ISBN, or other info"
    )
    parser.add_argument(
        "--config",
        default=str(DEFAULT_CONFIG_PATH),
        help="TOML defaults file for optional mirror/proxy values",
    )
    parser.add_argument(
        "--mirror", help="LibGen mirror URL; defaults to config when omitted"
    )
    parser.add_argument(
        "--proxy", help="HTTP/HTTPS proxy URL; defaults to config when omitted"
    )
    parser.add_argument(
        "--no-proxy", action="store_true", help="Ignore proxy environment variables"
    )
    parser.add_argument("--timeout", type=int, default=30, help="HTTP timeout in seconds")
    parser.add_argument("--results", type=int, default=25, help="Results per page")
    parser.add_argument("--page", type=int, default=1, help="Search result page")
    parser.add_argument(
        "--limit", type=int, default=5, help="Maximum matched books to inspect"
    )
    parser.add_argument(
        "--max-mirrors", type=int, default=1, help="Mirror pages to inspect per book"
    )
    parser.add_argument("--title", help="Keep results whose title contains this text")
    parser.add_argument("--author", help="Keep results whose author text contains this text")
    parser.add_argument("--year", help="Keep results from this year")
    parser.add_argument("--extension", help="Keep results with this extension, e.g. pdf")
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of text")
    parser.add_argument(
        "--wget-bytes",
        type=int,
        help="Include wget commands with a byte-range header for partial download tests",
    )
    return parser.parse_args(argv)


def main(argv: List[str]) -> int:
    args = parse_args(argv)
    defaults = load_defaults(args.config)
    mirror = args.mirror or defaults.get("mirror")
    proxy = args.proxy if args.proxy is not None else defaults.get("proxy")

    if not mirror:
        print(
            "missing mirror: pass --mirror or set defaults.mirror in the config",
            file=sys.stderr,
        )
        return 2

    opener = build_http_opener(proxy, args.no_proxy)
    try:
        books = search_books(
            args.query,
            mirror,
            opener,
            args.timeout,
            args.results,
            args.page,
        )
    except (HTTPError, URLError, TimeoutError, OSError) as exc:
        print(f"search failed: {exc}", file=sys.stderr)
        return 2

    filtered = [
        book
        for book in books
        if book_matches(book, args.title, args.author, args.year, args.extension)
    ][: args.limit]
    hydrate_direct_urls(filtered, opener, args.timeout, args.max_mirrors)
    filtered = [book for book in filtered if book.direct_urls]

    if args.json:
        output_json(filtered)
    else:
        output_text(filtered, args.wget_bytes)
    return 0 if filtered else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
