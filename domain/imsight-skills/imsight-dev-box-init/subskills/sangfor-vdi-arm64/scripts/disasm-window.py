#!/usr/bin/env python3
"""Disassemble windows of an x86_64 ELF around given virtual addresses.

Host objdump on arm64 binutils cannot decode x86; this uses capstone from a
venv (`python3 -m venv venv && venv/bin/pip install capstone`).

Usage:
    disasm-window.py BINARY ADDR [ADDR ...] [--before N] [--after N]
    disasm-window.py BINARY --calls-to HEX_PLT_ADDR   # list all call sites

Addresses are virtual addresses (for non-PIE binaries, file offset maps via
section headers automatically).
"""

import struct
import sys

from capstone import CS_ARCH_X86, CS_MODE_64, Cs


def load_sections(path: str) -> tuple[bytes, list[tuple[int, int, int, int]]]:
    """Return (file bytes, [(addr, offset, size, type)]) from ELF64 sections."""
    data = open(path, "rb").read()
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize = struct.unpack_from("<H", data, 0x3A)[0]
    e_shnum = struct.unpack_from("<H", data, 0x3C)[0]
    secs = []
    for i in range(e_shnum):
        sh = struct.unpack_from("<IIQQQQIIQQ", data, e_shoff + i * e_shentsize)
        secs.append((sh[3], sh[4], sh[5], sh[1]))  # addr, offset, size, type
    return data, secs


def main() -> None:
    args = sys.argv[1:]
    if len(args) < 2:
        raise SystemExit(__doc__)
    path = args[0]
    data, secs = load_sections(path)

    def v2o(vaddr: int) -> int | None:
        for addr, offset, size, stype in secs:
            if addr <= vaddr < addr + size and stype != 8:  # not SHT_NOBITS
                return offset + (vaddr - addr)
        return None

    md = Cs(CS_ARCH_X86, CS_MODE_64)

    if args[1] == "--calls-to":
        target = int(args[2], 16)
        text = next((a, o, s) for a, o, s, t in secs if t == 1 and a and s > 0x1000)
        taddr, toff, tsize = text
        hits = [
            insn.address
            for insn in md.disasm(data[toff : toff + tsize], taddr)
            if insn.mnemonic == "call" and insn.op_str == hex(target)
        ]
        print(f"call sites to {target:#x}:", [f"{h:#x}" for h in hits])
        return

    before, after = 0x40, 0x20
    addrs = []
    i = 1
    while i < len(args):
        if args[i] == "--before":
            before = int(args[i + 1], 0)
            i += 2
        elif args[i] == "--after":
            after = int(args[i + 1], 0)
            i += 2
        else:
            addrs.append(int(args[i], 16))
            i += 1

    for center in addrs:
        start = center - before
        off = v2o(start)
        if off is None:
            print(f"--- {center:#x}: not in file ---")
            continue
        print(f"--- around {center:#x} ---")
        for insn in md.disasm(data[off : off + before + after], start):
            mark = " <<<" if insn.address == center else ""
            print(f"{insn.address:#10x}: {insn.mnemonic:8s} {insn.op_str}{mark}")


if __name__ == "__main__":
    main()
