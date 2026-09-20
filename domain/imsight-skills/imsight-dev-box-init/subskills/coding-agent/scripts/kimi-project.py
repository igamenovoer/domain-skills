#!/usr/bin/env python3
"""kimi-project.py — deploy and track Kimi Code auth sessions in project-scope data homes.

An "auth session" is one independent OAuth login, identified by (user_id,
device_id) read from the refresh-token JWT: the device_id claim is stable per
login grant and survives refreshes, while independent logins of the same
account carry different device ids. Several sessions of one account are
distinct, separately deployable units; copies of the SAME session (a slot
home plus every project it was deployed into) are linked: they refresh
independently, and freshness is ranked per session.

Account "slots" are the long-lived Kimi data homes: ~/.kimi-code (slot
"default") plus every directory under ~/kimi-homes/ (one per kimi-<suffix>
launcher). A slot is self-declaring: whatever session it currently holds IS
its identity — there is no registration and no drift. Re-logging a slot into
another session simply makes that the slot's new truth; copies deployed
elsewhere are unaffected and owned by their projects. This tool copies a
session's auth state (config.toml + credentials/) into a project's
.kimi-code/ home and logs every deployment so later audits know where
credentials live.

Runtime state: ~/kimi-homes/manifest.json (session aliases and per-slot
exclusion flags), ~/kimi-homes/deployments.jsonl (append-only deployment
log), and per-home .backup/ directories (single-entry auth backups written by
backup or by deploy/undeploy --force-with-backup, read by restore). No token
material is ever written to state files or printed. A slot whose flags are
"excluded" is private: its credentials are never read, scanned, or deployed
by any subcommand.

Dependencies: Python 3.9+ standard library only.
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import shutil
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional

DEFAULT_HOME = Path.home() / ".kimi-code"
HOMES_ROOT = Path.home() / "kimi-homes"
MANIFEST_PATH = HOMES_ROOT / "manifest.json"
LOG_PATH = HOMES_ROOT / "deployments.jsonl"

AUTH_PARTS = ("config.toml", "credentials")


class UsageError(Exception):
    """Fatal user-facing error; printed without a traceback."""


def die(message: str) -> "NoReturn":  # noqa: F821
    raise UsageError(message)


def now_text() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime())


def fmt_age(seconds: float) -> str:
    """Render a duration as 6d2h / 2h6m / 5m."""
    s = max(0, int(seconds))
    d, rem = divmod(s, 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    if d:
        return f"{d}d{h}h"
    if h:
        return f"{h}h{m}m"
    return f"{m}m"


def short_uid(uid: str) -> str:
    return uid[:8]


def short_sess(uid: str, dev: str) -> str:
    if dev and dev != "unknown":
        return f"{uid[:8]}/{dev[:8]}"
    return f"{uid[:8]}/?"


def short_key(key: str) -> str:
    if ":" in key:
        uid, dev = key.split(":", 1)
        return short_sess(uid, dev)
    return short_uid(key)


def yellow(text: str) -> str:
    """ANSI-yellow when printing to a terminal (honors NO_COLOR)."""
    if not sys.stdout.isatty() or os.environ.get("NO_COLOR"):
        return text
    return f"\033[33m{text}\033[0m"


# ---------------------------------------------------------------------------
# Credentials


def jwt_payload(token: str) -> dict:
    """Decode the payload segment of a JWT without verifying the signature."""
    parts = token.split(".")
    if len(parts) < 2:
        raise ValueError("not a JWT")
    seg = parts[1]
    seg += "=" * (-len(seg) % 4)
    return json.loads(base64.urlsafe_b64decode(seg))


@dataclass(frozen=True)
class CredCopy:
    """One readable credential file: a copy of one auth session."""

    user_id: str
    device_id: str
    iat: int  # refresh-token issued-at; ranks freshness within a session
    exp: int  # refresh-token expiry; displayed as TTL
    cred_file: Path

    @property
    def home(self) -> Path:
        """The data home this credential lives in (<home>/credentials/*.json)."""
        return self.cred_file.parent.parent

    @property
    def key(self) -> str:
        return f"{self.user_id}:{self.device_id}"

    def short(self) -> str:
        return short_sess(self.user_id, self.device_id)


def device_id_fallback(home: Path) -> str:
    """Read a home's device_id file (used when the JWT has no device_id claim)."""
    f = home / "device_id"
    try:
        return re.sub(r"\s+", "", f.read_text(errors="replace"))[:64]
    except OSError:
        return ""


def read_cred(cred_file: Path) -> Optional[CredCopy]:
    """Parse one credential file; return None when it is unusable."""
    try:
        data = json.loads(cred_file.read_text())
        token = data.get("refresh_token")
        if not token:
            return None
        payload = jwt_payload(token)
        uid = payload.get("user_id") or payload.get("sub") or ""
        iat, exp = int(payload["iat"]), int(payload["exp"])
        if not uid:
            return None
        dev = payload.get("device_id") or ""
        if not dev:
            dev = device_id_fallback(cred_file.parent.parent)
        return CredCopy(uid, dev, iat, exp, cred_file)
    except (OSError, ValueError, KeyError, TypeError):
        return None


def home_copies(home: Path) -> list[CredCopy]:
    """All readable credential copies inside one home."""
    creds_dir = home / "credentials"
    copies: list[CredCopy] = []
    if not creds_dir.is_dir():
        return copies
    for f in sorted(creds_dir.glob("*.json")):
        copy = read_cred(f)
        if copy is None:
            print(f"warning: skipped {f}: unreadable credential", file=sys.stderr)
        else:
            copies.append(copy)
    return copies


def home_current(home: Path) -> Optional[CredCopy]:
    """The freshest credential copy a home currently holds."""
    copies = home_copies(home)
    return max(copies, key=lambda c: c.iat) if copies else None


def home_has_auth(home: Path) -> bool:
    return (home / "config.toml").exists() or (home / "credentials").exists()


# ---------------------------------------------------------------------------
# Manifest (~/kimi-homes/manifest.json, schema version 2)


class Manifest:
    """All configurable state: session aliases and per-slot exclusion flags."""

    def __init__(self, data: Optional[dict] = None):
        data = data or {}
        self.aliases: dict[str, str] = dict(data.get("aliases") or {})
        self.slots: dict[str, dict] = dict(data.get("slots") or {})

    @classmethod
    def load(cls) -> "Manifest":
        try:
            data = json.loads(MANIFEST_PATH.read_text())
        except (OSError, ValueError):
            return cls()
        if not isinstance(data, dict):
            return cls()
        return cls(data)

    def save(self) -> None:
        HOMES_ROOT.mkdir(parents=True, exist_ok=True)
        slots = {name: {"path": e.get("path", ""),
                        "flags": e.get("flags", ""),
                        "updated_at": e.get("updated_at", "")}
                 for name, e in self.slots.items()}
        data = {"version": 3, "aliases": self.aliases, "slots": slots}
        fd, tmp = tempfile.mkstemp(dir=str(HOMES_ROOT), prefix=".manifest.")
        try:
            with os.fdopen(fd, "w") as fh:
                json.dump(data, fh, indent=2)
                fh.write("\n")
            os.chmod(tmp, 0o600)
            os.replace(tmp, MANIFEST_PATH)
        except BaseException:
            try:
                os.unlink(tmp)
            except OSError:
                pass
            raise

    # -- slots (only the exclusion flag is tracked; identity is read live) --

    def slot_entry(self, slot: str) -> Optional[dict]:
        return self.slots.get(slot)

    def is_excluded(self, slot: str) -> bool:
        return (self.slot_entry(slot) or {}).get("flags", "") == "excluded"

    def excluded_homes(self) -> set[str]:
        return {e.get("path", "") for e in self.slots.values()
                if e.get("flags") == "excluded"}

    def set_slot_flags(self, slot: str, path: Path, flags: str) -> None:
        self.slots[slot] = {
            "path": str(path),
            "flags": flags,
            "updated_at": now_text(),
        }

    # -- aliases --

    def aliases_for_session(self, uid: str, dev: str) -> list[str]:
        key = f"{uid}:{dev}"
        return sorted(n for n, v in self.aliases.items() if v == key)

    def legacy_aliases_for_uid(self, uid: str) -> list[str]:
        return sorted(n for n, v in self.aliases.items() if ":" not in v and v == uid)


# ---------------------------------------------------------------------------
# Deployment log (~/kimi-homes/deployments.jsonl)


def log_entries() -> list[dict]:
    try:
        lines = LOG_PATH.read_text().splitlines()
    except OSError:
        return []
    entries = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except ValueError:
            continue
        if isinstance(e, dict):
            entries.append(e)
    return entries


def append_log(action: str, **fields: object) -> None:
    HOMES_ROOT.mkdir(parents=True, exist_ok=True)
    entry: dict[str, object] = {"ts": int(time.time()), "time": now_text(), "action": action}
    for k, v in fields.items():
        if v is None:
            continue
        entry[k] = int(v) if k in ("ts", "cred_iat") else str(v)
    with open(LOG_PATH, "a") as fh:
        fh.write(json.dumps(entry, separators=(",", ":")) + "\n")
    os.chmod(LOG_PATH, 0o600)


def entry_home(entry: dict) -> str:
    """Deploy-target home of a log entry (handles legacy project= entries)."""
    home = entry.get("home") or ""
    if home:
        return str(home)
    project = entry.get("project") or ""
    return f"{project}/.kimi-code" if project else ""


def deploy_entries() -> list[dict]:
    return [e for e in log_entries() if e.get("action") == "deploy"]


def logged_deploy_homes() -> list[str]:
    return sorted({h for h in (entry_home(e) for e in deploy_entries()) if h})


def last_deploy_entry(home: Path) -> Optional[dict]:
    found = None
    for e in deploy_entries():
        if entry_home(e) == str(home):
            found = e
    return found


def last_deploy_from_slot(home: Path) -> Optional[dict]:
    """Newest deploy entry whose source is this slot's home."""
    found = None
    for e in deploy_entries():
        if (e.get("source_home") or "") == str(home):
            found = e
    return found


def fmt_log_entry(e: dict) -> str:
    out = f"{e.get('time', '?')}  {e.get('action', '?'):<8}"
    uid = e.get("user_id") or ""
    if uid:
        out += f"  {short_sess(uid, e.get('device_id') or '')}"
    for field, prefix in (("project", ""), ("home", ""), ("source_home", "from "),
                          ("backup", "backup ")):
        v = e.get(field) or ""
        if v:
            out += f"  {prefix}{v}"
    return out


# ---------------------------------------------------------------------------
# Slots, copies, freshness


def discover_slots() -> dict[str, Path]:
    """All slots: 'default' plus every directory under ~/kimi-homes/."""
    slots = {"default": DEFAULT_HOME}
    if HOMES_ROOT.is_dir():
        for d in sorted(HOMES_ROOT.iterdir()):
            if d.is_dir() and not d.name.startswith("."):
                slots[d.name] = d
    return slots


def slot_home(slot: str) -> Path:
    home = discover_slots().get(slot)
    if home is None:
        known = " ".join(discover_slots())
        die(f"unknown slot '{slot}'. Known: {known}")
    return home


def collect_copies(man: Manifest, extra_roots: Iterable[Path] = ()) -> list[CredCopy]:
    """Every reachable copy: non-excluded slots, logged deploy homes, extra roots."""
    copies: list[CredCopy] = []
    for name, home in discover_slots().items():
        if man.is_excluded(name):
            continue
        copies.extend(home_copies(home))
    for home in logged_deploy_homes():
        h = Path(home)
        if not h.is_dir():
            continue  # dead deploy target — not part of any comparison
        copies.extend(home_copies(h))
    for root in extra_roots:
        copies.extend(path_copies(man, root))
    # Deduplicate identical copies (same cred file).
    seen: set[str] = set()
    unique: list[CredCopy] = []
    for c in copies:
        k = str(c.cred_file)
        if k not in seen:
            seen.add(k)
            unique.append(c)
    return unique


def path_copies(man: Manifest, root: Path) -> list[CredCopy]:
    """Copies under a scan root: a home, a project, or a parent of projects."""
    excluded = man.excluded_homes()
    copies: list[CredCopy] = []

    def add(home: Path) -> None:
        if str(home) in excluded:
            print(f"note: {home} is excluded (private); skipped", file=sys.stderr)
            return
        copies.extend(home_copies(home))

    add(root)
    add(root / ".kimi-code")
    if root.is_dir():
        for child in sorted(root.iterdir()):
            if child.is_dir():
                sub = child / ".kimi-code"
                if str(sub) not in excluded:
                    copies.extend(home_copies(sub))
    return copies


def freshest_of(copies: Iterable[CredCopy], uid: str, dev: str) -> Optional[CredCopy]:
    best = None
    for c in copies:
        if c.user_id == uid and c.device_id == dev:
            if best is None or c.iat > best.iat:
                best = c
    return best


def session_seats(man: Manifest, uid: str, dev: str) -> list[tuple[str, Path]]:
    """Slots currently holding this session (read live; seats are self-declaring)."""
    seats = []
    for name, home in discover_slots().items():
        if man.is_excluded(name):
            continue
        current = home_current(home)
        if current is not None and current.user_id == uid and current.device_id == dev:
            seats.append((name, home))
    return seats


# ---------------------------------------------------------------------------
# Auth file operations


def copy_auth(src: Path, dst: Path) -> None:
    """Copy config.toml + credentials/ between homes with private permissions."""
    dst.mkdir(parents=True, exist_ok=True)
    cfg = src / "config.toml"
    if cfg.exists():
        shutil.copy2(cfg, dst / "config.toml")
        os.chmod(dst / "config.toml", 0o600)
    creds = src / "credentials"
    if creds.is_dir():
        dst_creds = dst / "credentials"
        dst_creds.mkdir(exist_ok=True)
        os.chmod(dst_creds, 0o700)
        for f in creds.iterdir():
            if f.is_file():
                shutil.copy2(f, dst_creds / f.name)
                os.chmod(dst_creds / f.name, 0o600)


def clear_auth(home: Path) -> None:
    cfg = home / "config.toml"
    if cfg.exists():
        cfg.unlink()
    shutil.rmtree(home / "credentials", ignore_errors=True)


def backup_home(home: Path) -> bool:
    """Copy a home's auth into <home>/.backup/ (single entry). Returns True if replacing."""
    replaced = (home / ".backup").exists()
    tmp = home / f".backup.tmp.{os.getpid()}"
    shutil.rmtree(tmp, ignore_errors=True)
    tmp.mkdir(parents=True)
    src_view = home
    # Copy auth parts into tmp via a shim so copy_auth's layout applies.
    cfg = src_view / "config.toml"
    if cfg.exists():
        shutil.copy2(cfg, tmp / "config.toml")
        os.chmod(tmp / "config.toml", 0o600)
    creds = src_view / "credentials"
    if creds.is_dir():
        dst_creds = tmp / "credentials"
        dst_creds.mkdir()
        os.chmod(dst_creds, 0o700)
        for f in creds.iterdir():
            if f.is_file():
                shutil.copy2(f, dst_creds / f.name)
                os.chmod(dst_creds / f.name, 0o600)
    if replaced:
        shutil.rmtree(home / ".backup")
    os.replace(tmp, home / ".backup")
    return replaced


def rescue_to_seats(man: Manifest, copy: CredCopy) -> bool:
    """Copy this session's auth into every slot holding the same session but older."""
    rescued = False
    for name, seat in session_seats(man, copy.user_id, copy.device_id):
        if seat == copy.home:
            continue
        current = home_current(seat)
        if current is None or copy.iat > current.iat:
            clear_auth(seat)
            copy_auth(copy.home, seat)
            print(f"note: rescued newer copy of {copy.short()} into canonical home "
                  f"{seat} (slot {name})")
            append_log("rescue", user_id=copy.user_id, device_id=copy.device_id,
                       source_home=copy.home, home=seat, cred_iat=copy.iat)
            rescued = True
    return rescued


def seat_covers(man: Manifest, home: Path, copy: CredCopy) -> bool:
    """True when another slot holds the same session with iat >= copy's."""
    for _name, seat in session_seats(man, copy.user_id, copy.device_id):
        if seat == home:
            continue
        current = home_current(seat)
        if current is not None and current.iat >= copy.iat:
            return True
    return False


# ---------------------------------------------------------------------------
# Target resolution


def project_dir(opt_project: Optional[str]) -> Path:
    d = Path(opt_project or ".").resolve()
    if not d.is_dir():
        die(f"project directory not found: {opt_project or '.'}")
    return d


def resolve_home(opt_project: Optional[str], fallback: str) -> Path:
    """--project DIR > $KIMI_CODE_HOME > fallback ('default' or 'cwd')."""
    if opt_project:
        return project_dir(opt_project) / ".kimi-code"
    env = os.environ.get("KIMI_CODE_HOME")
    if env:
        return Path(env)
    if fallback == "default":
        return DEFAULT_HOME
    return project_dir(None) / ".kimi-code"


def check_not_excluded_home(man: Manifest, home: Path, verb: str) -> None:
    for name, e in man.slots.items():
        if e.get("flags") == "excluded" and e.get("path") == str(home):
            die(f"{home} is excluded (private); {verb} would touch its credentials. "
                f"Run 'include {name}' to lift this.")


def parse_force(args: argparse.Namespace) -> tuple[bool, bool]:
    """Return (force, force_with_backup)."""
    return bool(args.force or args.force_with_backup), bool(args.force_with_backup)


# ---------------------------------------------------------------------------
# Selector resolution


def resolve_selector(sel: str, man: Manifest,
                     copies: list[CredCopy]) -> tuple[str, str, str]:
    """Resolve a deploy selector.

    Returns
    -------
    tuple[str, str, str]
        ("slot", name, "") or ("session", user_id, device_id).
    """
    key = man.aliases.get(sel)
    if key:
        if ":" in key:
            uid, dev = key.split(":", 1)
            return ("session", uid, dev)
        sessions = sorted({(c.user_id, c.device_id) for c in copies
                           if c.user_id == key})
        if len(sessions) == 1:
            return ("session", *sessions[0])
        if not sessions:
            die(f"alias '{sel}' points to account {short_uid(key)}, which no slot "
                "or logged project holds")
        die(f"alias '{sel}' points to account {short_uid(key)}, which has several "
            f"live sessions: {' '.join(short_sess(u, d) for u, d in sessions)}\n"
            f"Rebind it to one session: alias {sel} <slot>")
    if sel in discover_slots():
        return ("slot", sel, "")
    for field in ("device", "user"):
        if field == "device":
            matches = sorted({(c.user_id, c.device_id) for c in copies
                              if c.device_id and c.device_id.startswith(sel)})
        else:
            matches = sorted({(c.user_id, c.device_id) for c in copies
                              if c.user_id.startswith(sel)})
        if len(matches) == 1:
            return ("session", *matches[0])
        if len(matches) > 1:
            listing = " ".join(short_sess(u, d) for u, d in matches)
            hint = ("\nUse an alias or slot name to pick one login."
                    if field == "user" else "")
            die(f"selector '{sel}' is ambiguous between sessions: {listing}{hint}")
    valid = " ".join(sorted(set(man.aliases) | set(discover_slots())))
    die(f"unknown selector '{sel}'. Valid: {valid}")


# ---------------------------------------------------------------------------
# Commands: read-only


def cmd_list(args: argparse.Namespace) -> None:
    man = Manifest.load()
    copies = collect_copies(man)

    rows: list[tuple[str, str, str, Path, Optional[CredCopy]]] = []
    for name, home in discover_slots().items():
        current = None if man.is_excluded(name) else home_current(home)
        if current is not None:
            uid, dev = current.user_id, current.device_id
            aliases = man.aliases_for_session(uid, dev) or man.legacy_aliases_for_uid(uid)
            alias_s = ",".join(aliases) if aliases else "-"
            sess_s = short_sess(uid, dev)
        else:
            alias_s = sess_s = "-"
        rows.append((name, alias_s, sess_s, home, current))

    print("slot info:")
    print(f"  {'slot':<14} {'alias':<10} {'session':<19} seat dir")
    for name, alias_s, sess_s, home, _current in rows:
        print(f"  {name:<14} {alias_s:<10} {sess_s:<19} {home}")

    print("\nslot deployment and freshness:")
    cwd_home = Path.cwd() / ".kimi-code"
    for name, alias_s, _sess_s, home, current in rows:
        print(f"  {name}" + (f" (alias: {alias_s})" if alias_s != "-" else ""))
        if man.is_excluded(name):
            print("    excluded (private) — credentials not read")
            continue
        last = last_deploy_from_slot(home)
        if last is not None:
            lhome = entry_home(last) or "unknown"
            # A deployment only counts while the target still holds this session;
            # a later deploy of another session into the same target overwrote it.
            duid = last.get("user_id") or ""
            ddev = last.get("device_id") or ""
            target = home_current(Path(lhome)) if Path(lhome).is_dir() else None
            live = (target is not None and target.user_id == duid
                    and (not ddev or target.device_id == ddev))
            if not live:
                deployed_s = f"{lhome} (overwritten)"
            elif lhome == str(cwd_home):
                deployed_s = f"{yellow(lhome)} (here)"
            else:
                deployed_s = lhome
        else:
            deployed_s = "never"
        if current is not None:
            best = freshest_of(copies, current.user_id, current.device_id)
            if best is not None:
                if best.home == cwd_home:
                    auth_s = f"{yellow(str(best.cred_file))} (here)"
                else:
                    auth_s = str(best.cred_file)
            else:
                auth_s = "none found"
        else:
            auth_s = "-"
        print(f"    last deployed: {deployed_s}")
        print(f"    latest auth:   {auth_s}")


def cmd_status(args: argparse.Namespace) -> None:
    man = Manifest.load()
    project = project_dir(args.project)
    home = project / ".kimi-code"
    now = int(time.time())

    if not home_has_auth(home):
        print(f"{project}: no project home (deploy to create one)")
        return
    print(f"project: {project}")
    current = home_current(home)
    if current is None:
        print("  home exists but has no readable credentials")
        return
    aliases = man.aliases_for_session(current.user_id, current.device_id)
    al = f" ({','.join(aliases)})" if aliases else ""
    print(f"  session: {current.short()}{al}")
    print(f"  refreshed: {fmt_age(now - current.iat)} ago; "
          f"refresh token TTL {fmt_age(current.exp - now)}")

    last = last_deploy_entry(home)
    if last is not None:
        print(f"  last deployed: {last.get('time', '?')} from {last.get('source_home', '?')}")
        duid = last.get("user_id") or ""
        ddev = last.get("device_id") or ""
        if duid and (duid != current.user_id
                     or (ddev and ddev != current.device_id)):
            print(f"  DRIFTED — deployed as {short_sess(duid, ddev)}, "
                  f"now holds {current.short()}")
    else:
        print("  last deployed: never (no log entry for this project)")

    copies = collect_copies(man)
    best = freshest_of(copies, current.user_id, current.device_id)
    if best is not None and best.cred_file != current.cred_file and best.iat > current.iat:
        print(f"  stale — a fresher copy of this session exists at {best.home} "
              f"(newer by {fmt_age(best.iat - current.iat)})")
    else:
        print("  this copy is the freshest known for its session")


def cmd_log(args: argparse.Namespace) -> None:
    entries = log_entries()
    if not entries:
        print("deployment log is empty")
        return
    for e in entries[-args.count:]:
        print(fmt_log_entry(e))


def cmd_scan(args: argparse.Namespace) -> None:
    man = Manifest.load()
    now = int(time.time())
    roots: list[Path] = []
    for p in args.paths:
        rp = Path(p)
        if not rp.is_dir():
            print(f"warning: scan path skipped (not a directory): {p}", file=sys.stderr)
            continue
        roots.append(rp.resolve())
    copies = collect_copies(man, roots)

    print("== session freshness")
    if copies:
        sessions: dict[tuple[str, str], list[CredCopy]] = {}
        for c in copies:
            sessions.setdefault((c.user_id, c.device_id), []).append(c)
        print(f"distinct sessions: {len(sessions)}   credential files: {len(copies)}")
        for i, ((uid, dev), group) in enumerate(sorted(sessions.items()), 1):
            group.sort(key=lambda c: c.iat, reverse=True)
            latest = group[0]
            n = len(group)
            print(f"session #{i}: user_id={uid} "
                  f"device_id={dev or 'unknown'}  ({n} cop{'ies' if n > 1 else 'y'})")
            expired = " [refresh EXPIRED]" if latest.exp < now else ""
            print(f"  latest: {latest.cred_file}")
            print(f"          refreshed {fmt_age(now - latest.iat)} ago, refresh token "
                  f"expires in {fmt_age(latest.exp - now)}{expired}")
            for stale in group[1:]:
                expired = " [refresh EXPIRED]" if stale.exp < now else ""
                print(f"  stale:  {stale.cred_file} "
                      f"(behind by {fmt_age(latest.iat - stale.iat)}){expired}")
    else:
        print("no credential files found")


# ---------------------------------------------------------------------------
# Commands: mutating


def cmd_alias(args: argparse.Namespace) -> None:
    man = Manifest.load()
    name, slot = args.name, args.slot
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", name):
        die(f"alias '{name}' must be lowercase letters, digits, hyphens")
    home = slot_home(slot)
    if man.is_excluded(slot):
        die(f"slot '{slot}' is excluded (private); run 'include {slot}' before "
            "aliasing its session")
    current = home_current(home)
    if current is None:
        die(f"slot '{slot}' has no readable credentials — log in first")
    key = current.key
    existing = man.aliases.get(name)
    force, _ = parse_force(args)
    if existing and existing != key and not force:
        die(f"alias '{name}' already points to {short_key(existing)}; use --force "
            f"to rebind to {short_key(key)}")
    man.aliases[name] = key
    man.save()
    print(f"alias {name} -> {short_key(key)} (session currently in slot '{slot}')")


def cmd_unalias(args: argparse.Namespace) -> None:
    man = Manifest.load()
    existing = man.aliases.get(args.name)
    if existing is None:
        die(f"no alias '{args.name}'")
    del man.aliases[args.name]
    man.save()
    print(f"removed alias {args.name} (was {short_key(existing)})")


def cmd_exclude(args: argparse.Namespace) -> None:
    man = Manifest.load()
    slot = args.slot
    home = slot_home(slot)
    if man.is_excluded(slot):
        print(f"slot '{slot}' is already excluded")
        return
    man.set_slot_flags(slot, home, "excluded")
    man.save()
    print(f"excluded '{slot}' ({home})")
    print("  its credentials will not be read, scanned, or deployed by any subcommand")
    print(f"  undo with: kimi-project.py include {slot}")
    current = home_current(home)
    if current is not None:
        aliases = (man.aliases_for_session(current.user_id, current.device_id)
                   or man.legacy_aliases_for_uid(current.user_id))
        if aliases:
            print(f"  note: alias(es) {','.join(aliases)} point to this session; "
                  "deploys by alias will fail while it exists only here")


def cmd_include(args: argparse.Namespace) -> None:
    man = Manifest.load()
    slot = args.slot
    home = slot_home(slot)
    if not man.is_excluded(slot):
        print(f"slot '{slot}' is not excluded")
        return
    man.set_slot_flags(slot, home, "")
    man.save()
    print(f"included '{slot}' ({home}); it is readable, scannable, and deployable again")


def cmd_deploy(args: argparse.Namespace) -> None:
    man = Manifest.load()
    force, force_backup = parse_force(args)
    via_env = not args.project and bool(os.environ.get("KIMI_CODE_HOME"))
    home = resolve_home(args.project, "cwd")
    check_not_excluded_home(man, home, "deploy")
    if home_has_auth(home) and not force:
        die(f"{home} already holds an account.\nUse --force to overwrite it "
            "(no backup), or --force-with-backup to back it up to .backup/ first.")
    now = int(time.time())
    copies = collect_copies(man)

    # --- pick the source copy ---
    if args.from_slot:
        slot = args.from_slot
        if man.is_excluded(slot):
            die(f"slot '{slot}' is excluded (private); it is never a deploy source. "
                f"Run 'include {slot}' to lift this.")
        source_home = slot_home(slot)
        source = home_current(source_home)
        if source is None:
            die(f"slot '{slot}' has no readable credentials — log in first")
        best = freshest_of(copies, source.user_id, source.device_id)
        if best is not None and best.cred_file != source.cred_file \
                and best.iat > source.iat and not force:
            die(f"slot '{slot}' is not the freshest copy of {source.short()}; "
                f"{best.home} is newer by {fmt_age(best.iat - source.iat)}.\n"
                f"Deploy from there instead (selector: {source.short()}), or use --force.")
    else:
        kind, v1, v2 = resolve_selector(args.selector, man, copies)
        if kind == "slot":
            if man.is_excluded(v1):
                die(f"slot '{v1}' is excluded (private); it is never a deploy source. "
                    f"Run 'include {v1}' to lift this.")
            source_home = slot_home(v1)
            source = home_current(source_home)
            if source is None:
                die(f"slot '{v1}' has no readable credentials — log in first")
            best = freshest_of(copies, source.user_id, source.device_id)
            if best is not None and best.iat > source.iat:
                source = best
        else:
            source = freshest_of(copies, v1, v2)
            if source is None:
                die(f"session {short_sess(v1, v2)} is not present in any slot or "
                    "logged project.\nLog it into a slot first (e.g. kimi-<suffix> "
                    "login), then retry.")

    source_home = source.home
    if source_home == home:
        die(f"source and target are the same home ({home}); nothing to deploy")

    # Canonical convergence: a newer copy is rescued into slots holding the session.
    rescue_to_seats(man, source)

    if home_has_auth(home):
        # Forced overwrite: rescue the target's own newer auth first.
        old = home_current(home)
        rescued = rescue_to_seats(man, old) if old is not None else False
        if not rescued and old is not None:
            copies_now = collect_copies(man)
            best = freshest_of(copies_now, old.user_id, old.device_id)
            if best is not None and best.cred_file == old.cred_file:
                if force_backup:
                    print(f"note: {home} holds the freshest known copy of its "
                          "session; it is preserved in .backup/")
                else:
                    print(f"warning: {home} holds the freshest known copy of its "
                          "session; overwriting with no backup", file=sys.stderr)
        if force_backup:
            replaced = backup_home(home)
            append_log("backup", user_id=old.user_id if old else "",
                       device_id=old.device_id if old else "", home=home)
            print(f"previous auth backed up to {home}/.backup"
                  + (" (replaced)" if replaced else ""))
        clear_auth(home)

    copy_auth(source_home, home)
    append_log("deploy", selector=args.selector, user_id=source.user_id,
               device_id=source.device_id, source_home=source_home, home=home,
               cred_iat=source.iat)
    man.save()

    aliases = man.aliases_for_session(source.user_id, source.device_id)
    al = f" ({','.join(aliases)})" if aliases else ""
    print(f"deployed {source.short()}{al} from {source_home}")
    print(f"  credential refreshed {fmt_age(now - source.iat)} ago; "
          f"refresh TTL {fmt_age(source.exp - now)}")
    print(f"  into {home}")
    if not via_env:
        print(f"next: export KIMI_CODE_HOME={home}")
        print("      (or from its project dir: source ~/set-kimi-home-as-pwd.sh)")


def cmd_undeploy(args: argparse.Namespace) -> None:
    man = Manifest.load()
    force, force_backup = parse_force(args)
    home = resolve_home(args.project, "cwd")
    check_not_excluded_home(man, home, "undeploy")
    if not home_has_auth(home):
        die(f"{home} holds no deployed auth — nothing to undeploy")
    current = home_current(home)
    if current is None and not force:
        die(f"{home} has no readable credentials to return; use --force to remove "
            "its auth state anyway")

    rescued = rescue_to_seats(man, current) if current is not None else False
    if not rescued and current is not None and not force \
            and not seat_covers(man, home, current):
        die(f"{home} holds the freshest known copy of {current.short()} and no "
            "slot home holds an equally fresh copy.\nUse "
            f"--force-with-backup to keep it in {home}/.backup/, or --force to "
            "discard it.")
    if force_backup:
        backup_home(home)
        append_log("backup", user_id=current.user_id if current else "",
                   device_id=current.device_id if current else "", home=home)
        print(f"previous auth backed up to {home}/.backup")
    clear_auth(home)
    append_log("undeploy", user_id=current.user_id if current else "",
               device_id=current.device_id if current else "", home=home,
               cred_iat=current.iat if current else 0)
    man.save()
    sess = current.short() if current is not None else "-"
    if rescued:
        print(f"undeployed {sess}: session returned to its slot home; "
              f"auth removed from {home}")
    else:
        print(f"undeployed {sess}: auth removed from {home}")


def collect_into_seat(man: Manifest, copies: list[CredCopy],
                      name: str, home: Path) -> None:
    """Write the freshest known copy of a slot's session back into its seat dir."""
    if man.is_excluded(name):
        print(f"{name}: excluded (private) — skipped")
        return
    current = home_current(home)
    if current is None:
        print(f"{name}: no session (empty) — nothing to collect")
        return
    best = freshest_of(copies, current.user_id, current.device_id)
    if best is None or best.iat <= current.iat:
        print(f"{name}: already holds the freshest copy of {current.short()}")
        return
    clear_auth(home)
    copy_auth(best.home, home)
    append_log("collect", user_id=best.user_id, device_id=best.device_id,
               source_home=best.home, home=home, cred_iat=best.iat)
    print(f"{name}: collected {best.short()} from {best.home} "
          f"(newer by {fmt_age(best.iat - current.iat)})")


def cmd_collect(args: argparse.Namespace) -> None:
    man = Manifest.load()
    slots = discover_slots()
    target = args.slot
    if target == "all" and "all" in slots:
        print("'collect all' is ambiguous: a slot named 'all' exists.", file=sys.stderr)
        print("  e — collect into every seat", file=sys.stderr)
        print("  s — collect into the slot named 'all' only", file=sys.stderr)
        try:
            choice = input("collect all means [e/s]? ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print("\naborted", file=sys.stderr)
            raise SystemExit(1)
        if choice == "e":
            target = "__every__"
        elif choice == "s":
            target = "all"
        else:
            die(f"invalid choice {choice!r}; expected 'e' or 's'")
    elif target == "all":
        target = "__every__"

    copies = collect_copies(man)
    if target == "__every__":
        for name, home in slots.items():
            collect_into_seat(man, copies, name, home)
    else:
        collect_into_seat(man, copies, target, slot_home(target))
    man.save()


def cmd_backup(args: argparse.Namespace) -> None:
    man = Manifest.load()
    home = resolve_home(args.project, "default")
    check_not_excluded_home(man, home, "backup")
    if not home_has_auth(home):
        die(f"{home} has no config.toml or credentials/ — nothing to back up")
    current = home_current(home)
    replaced = backup_home(home)
    append_log("backup", user_id=current.user_id if current else "",
               device_id=current.device_id if current else "", home=home)
    man.save()
    print(f"backed up {home}")
    print(f"  into {home}/.backup (single backup entry per home)")
    if replaced:
        print(f"  note: replaced the previous backup at {home}/.backup")
    if current is not None:
        print(f"  session: {current.short()}")
    print("  undo with: kimi-project.py restore   (same target resolution as backup)")


def cmd_restore(args: argparse.Namespace) -> None:
    man = Manifest.load()
    home = resolve_home(args.project, "default")
    check_not_excluded_home(man, home, "restore")
    backup = home / ".backup"
    if not backup.is_dir():
        die(f"no backup at {backup} — nothing to restore")
    if not (backup / "config.toml").exists() and not (backup / "credentials").is_dir():
        die(f"backup at {backup} holds neither config.toml nor credentials/")
    had_live = home_has_auth(home)
    clear_auth(home)
    copy_auth(backup, home)
    current = home_current(home)
    append_log("restore", user_id=current.user_id if current else "",
               device_id=current.device_id if current else "", home=home)
    man.save()
    print(f"restored {home} from {backup}")
    if current is not None:
        print(f"  session: {current.short()}")
    if had_live:
        print("  the previous live auth was overwritten")
    print(f"  backup kept at {backup} (restores are repeatable)")


def cmd_forget(args: argparse.Namespace) -> None:
    entries = log_entries()
    if not entries:
        print("deployment log is empty")
        return
    kept: list[dict] = []
    removed = 0

    def entry_matches_paths(e: dict, cand_homes: set[str], cand_projs: set[str]) -> bool:
        h = e.get("home") or ""
        p = e.get("project") or ""
        return (h and h in cand_homes) or (p and p in cand_projs)

    if args.dead:
        for e in entries:
            hh = entry_home(e)
            if hh and not Path(hh).exists():
                removed += 1
                print(f"  dropping: {fmt_log_entry(e)}")
            else:
                kept.append(e)
    else:
        cand_homes: set[str] = set()
        cand_projs: set[str] = set()
        for x in args.paths:
            xs = str(Path(x).resolve()) if Path(x).is_dir() else x.rstrip("/")
            cand_homes.update((xs, xs + "/.kimi-code"))
            cand_projs.add(xs)
            if xs.endswith("/.kimi-code"):
                cand_projs.add(str(Path(xs).parent))
        for e in entries:
            if entry_matches_paths(e, cand_homes, cand_projs):
                removed += 1
                print(f"  dropping: {fmt_log_entry(e)}")
            else:
                kept.append(e)

    if removed == 0:
        print("no matching log entries")
        return
    fd, tmp = tempfile.mkstemp(dir=str(HOMES_ROOT), prefix=".deployments.")
    with os.fdopen(fd, "w") as fh:
        for e in kept:
            fh.write(json.dumps(e, separators=(",", ":")) + "\n")
    os.chmod(tmp, 0o600)
    os.replace(tmp, LOG_PATH)
    print(f"forgot {removed} log entr{'y' if removed == 1 else 'ies'}")
    if not args.dead:
        for x in args.paths:
            xs = str(Path(x).resolve()) if Path(x).is_dir() else x.rstrip("/")
            hh = ""
            if Path(xs, ".kimi-code").exists():
                hh = xs + "/.kimi-code"
            elif xs.endswith("/.kimi-code"):
                hh = xs
            if hh and home_has_auth(Path(hh)):
                print(f"note: {hh} still holds credentials; scan no longer tracks it")


# ---------------------------------------------------------------------------
# Entrypoint


def build_parser() -> argparse.ArgumentParser:
    epilog = """\
An auth session is one independent OAuth login, identified by (user_id,
device_id) — two logins of the same account are distinct sessions. Slots are
self-declaring: whatever session a slot currently holds is its identity; there
is no registration and no drift.

deploy selector: alias, slot name, or id prefix (user_id or device_id — a
prefix matching several sessions is refused). Target resolution: --project
DIR, else $KIMI_CODE_HOME, else cwd's .kimi-code (backup/restore fall back to
~/.kimi-code instead).
"""
    p = argparse.ArgumentParser(
        prog="kimi-project.py",
        description="Deploy and track Kimi Code auth sessions in project-scope "
                    "data homes.",
        epilog=epilog,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="command", required=True, metavar="command")

    def add(name: str, help_text: str) -> argparse.ArgumentParser:
        return sub.add_parser(name, help=help_text)

    add("list", "show slot info, deployment, and freshness")
    sp = add("status", "show a project's session state (default: cwd)")
    sp.add_argument("--project")
    sp = add("log", "show deployment log (default 20 entries)")
    sp.add_argument("count", nargs="?", type=int, default=20)
    sp = add("scan", "per-session freshness audit")
    sp.add_argument("paths", nargs="*")

    sp = add("alias", "bind an alias to the session currently in a slot")
    sp.add_argument("name")
    sp.add_argument("slot")
    sp.add_argument("--force", action="store_true")
    sp.add_argument("--force-with-backup", action="store_true")
    sp = add("unalias", "remove an alias")
    sp.add_argument("name")
    sp = add("exclude", "mark a slot private: never read, scanned, or deployed from")
    sp.add_argument("slot")
    sp = add("include", "lift the exclusion")
    sp.add_argument("slot")

    sp = add("deploy", "copy a session's config+credentials into the target home")
    sp.add_argument("selector")
    sp.add_argument("--from", dest="from_slot", metavar="SLOT")
    sp.add_argument("--project")
    sp.add_argument("--force", action="store_true",
                    help="overwrite an occupied home (no backup)")
    sp.add_argument("--force-with-backup", action="store_true",
                    help="back the home up to .backup/ first")
    sp = add("undeploy", "return a project's auth and remove it from the project")
    sp.add_argument("--project")
    sp.add_argument("--force", action="store_true")
    sp.add_argument("--force-with-backup", action="store_true")
    sp = add("backup", "copy the target home's auth into its .backup/")
    sp.add_argument("--project")
    sp = add("restore", "overwrite the target home's auth with its .backup/")
    sp.add_argument("--project")
    sp = add("forget", "drop deployment-record entries (never removes files)")
    sp.add_argument("--dead", action="store_true",
                    help="drop every entry whose home no longer exists")
    sp.add_argument("paths", nargs="*")
    sp = add("collect", "write each seat's freshest session copy back to its seat dir")
    sp.add_argument("slot", help="slot id, or 'all' for every seat")
    return p


def main(argv: Optional[list[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    handlers = {
        "list": cmd_list,
        "status": cmd_status,
        "log": cmd_log,
        "scan": cmd_scan,
        "alias": cmd_alias,
        "unalias": cmd_unalias,
        "exclude": cmd_exclude,
        "include": cmd_include,
        "deploy": cmd_deploy,
        "undeploy": cmd_undeploy,
        "backup": cmd_backup,
        "restore": cmd_restore,
        "forget": cmd_forget,
        "collect": cmd_collect,
    }
    try:
        if args.command == "forget" and not args.dead and not args.paths:
            die("forget needs at least one PATH, or --dead")
        handlers[args.command](args)
    except UsageError as e:
        print(str(e), file=sys.stderr)
        return 1
    except BrokenPipeError:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
