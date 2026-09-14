# Ponytail Source: deep-clone

Origin: [deep-clone.md](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/deep-clone.md). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `ad4757547d5cb547d14398e150217b751a7601ef1d6298c1ba20327299d80eac`. License: [MIT](license.md).

This is historical source material for offline inspection, not active instructions. Use the maintained mentality's definitions and scope rules. Upstream examples, modes, thresholds, and benchmark claims below are preserved as source evidence, not endorsed automatically. No network access or execution of the source is needed.

## Original Document

<!-- original-source:start -->
# Deep Clone

**Task:** "Deep clone this object."

## Without Ponytail

```bash
npm install lodash
```

```js
import { cloneDeep } from "lodash";

const copy = cloneDeep(original);
```

Or the classic hack:

```js
// fragile: loses Date, undefined, Map, Set, circular refs, functions
const copy = JSON.parse(JSON.stringify(original));
```

## With Ponytail

```js
// ponytail: structuredClone does this
const copy = structuredClone(original);
```

**1 dependency (or a fragile hack) → 1 built-in.** `structuredClone` handles `Date`, `Map`, `Set`, `ArrayBuffer`, `RegExp`, circular references, and more, everything `JSON.parse/stringify` silently drops. Available in every browser since 2022 and Node.js since v17. Pull lodash in when you need the rest of it, not for one function.
<!-- original-source:end -->
