# Ponytail Source: Original Rules

Origin: [skills/ponytail/SKILL.md — Rules](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/skills/ponytail/SKILL.md#rules). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `1316a2f3f95741d2300b116fe0c2d81ce4a9568656ed0a62643f54aaf09957f2`. License: [MIT](license.md).

This exact section excerpt supplies the global-lock comment used by p7. It is historical source material, not current instructions. The mentality manager replaces upstream's blanket deletion and reduced-requirement advice with its own scoped rules; reading this source enables no principle.

<!-- original-source:start -->
## Rules

- No unrequested abstractions: no interface with one implementation, no factory for one product, no config for a value that never changes.
- No boilerplate, no scaffolding "for later", later can scaffold for itself.
- Deletion over addition. Boring over clever, clever is what someone decodes at 3am.
- Fewest files possible. Shortest working diff wins — but only once you understand the problem. The smallest change in the wrong place isn't lazy, it's a second bug.
- Complex request? Ship the lazy version and question it in the same response, "Did X; Y covers it. Need full X? Say so." Never stall on an answer you can default.
- Two stdlib options, same size? Take the one that's correct on edge cases. Lazy means writing less code, not picking the flimsier algorithm.
- Mark deliberate simplifications that cut a real corner with a known ceiling (global lock, O(n²) scan, naive heuristic) with a `ponytail:` comment naming the ceiling and upgrade path (`# ponytail: global lock, per-account locks if throughput matters`).

<!-- original-source:end -->
