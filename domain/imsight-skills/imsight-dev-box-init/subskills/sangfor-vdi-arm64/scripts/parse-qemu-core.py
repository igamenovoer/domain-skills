#!/usr/bin/env python3
"""Parse a qemu-user x86_64 guest ELF core: per-thread registers and fault marker.

qemu-user writes qemu_<comm>_<ts>_<pid>.core when a guest dies of an unhandled
fatal signal. Host binutils on arm64 do not decode x86_64 NT_PRSTATUS notes,
so this script extracts them directly. qemu cores carry no NT_FILE note; use
the QEMU strace mmap/openat correlation described in session-crash-fix.md to
attribute addresses to libraries.

Usage:
    parse-qemu-core.py CORE [-m]

-m also dumps the PT_LOAD segment table (vaddr ranges present in the core).
"""

import struct
import sys

REG_ORDER = (
    "r15", "r14", "r13", "r12", "rbp", "rbx", "r11", "r10", "r9", "r8",
    "rax", "rcx", "rdx", "rsi", "rdi", "orig_rax", "rip", "cs", "eflags",
    "rsp", "ss", "fs_base", "gs_base",
)
# x86_64 elf_prstatus: si_signo/si_code/si_errno (12), pr_cursig (2+2 pad),
# pr_sigpend (8), pr_sighold (8), pr_pid/ppid/pgrp/sid (16),
# pr_utime/stime/cutime/cstime (64), pr_reg (27*8), pr_fpvalid (4)
PRSTATUS_REG_OFF = 112


def read_notes(data: bytes) -> tuple[list[tuple[int, bytes]], list[tuple[int, int, int]]]:
    """Return (notes, pt_load segments) from an ELF64 LE core image."""
    if data[:4] != b"\x7fELF" or data[4] != 2 or data[5] != 1:
        raise SystemExit("not an ELF64 little-endian file")
    e_phoff = struct.unpack_from("<Q", data, 0x20)[0]
    e_phentsize = struct.unpack_from("<H", data, 0x36)[0]
    e_phnum = struct.unpack_from("<H", data, 0x38)[0]
    notes: list[tuple[int, bytes]] = []
    loads: list[tuple[int, int, int]] = []
    for i in range(e_phnum):
        p_type, _flags, p_offset, p_vaddr, _p, p_filesz, _m, _a = struct.unpack_from(
            "<IIQQQQQQ", data, e_phoff + i * e_phentsize
        )
        if p_type == 4:  # PT_NOTE
            off, end = p_offset, p_offset + p_filesz
            while off + 12 <= end:
                namesz, descsz, ntype = struct.unpack_from("<III", data, off)
                off += 12 + ((namesz + 3) & ~3)
                notes.append((ntype, data[off : off + descsz]))
                off += (descsz + 3) & ~3
        elif p_type == 1:  # PT_LOAD
            loads.append((p_vaddr, p_filesz, p_offset))
    return notes, loads


def main() -> None:
    path = sys.argv[1]
    with open(path, "rb") as f:
        data = f.read()
    notes, loads = read_notes(data)

    threads = []
    for ntype, desc in notes:
        if ntype == 1 and len(desc) >= PRSTATUS_REG_OFF + 27 * 8:  # NT_PRSTATUS
            threads.append(
                {
                    "pid": struct.unpack_from("<i", desc, 32)[0],
                    "cursig": struct.unpack_from("<h", desc, 12)[0],
                    "regs": struct.unpack_from("<27Q", desc, PRSTATUS_REG_OFF),
                }
            )

    print(f"== {len(threads)} threads ==")
    for t in threads:
        r = t["regs"]
        mark = " <<< FAULT" if t["cursig"] == 11 else ""
        print(
            f"pid={t['pid']:6d} cursig={t['cursig']:2d} "
            f"rip={r[16]:#018x} rsp={r[19]:#018x} rbp={r[4]:#018x} "
            f"rax={r[10]:#x} rbx={r[5]:#x} rdi={r[14]:#x} rsi={r[13]:#x}{mark}"
        )

    if len(sys.argv) > 2 and sys.argv[2] == "-m":
        print("\n== PT_LOAD segments ==")
        for vaddr, filesz, offset in sorted(loads):
            print(f"{vaddr:#018x}-{vaddr + filesz:#018x} file_off={offset:#x}")


if __name__ == "__main__":
    main()
