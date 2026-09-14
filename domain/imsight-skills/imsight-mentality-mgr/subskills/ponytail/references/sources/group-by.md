# Ponytail Source: group-by

Origin: [group-by.md](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/group-by.md). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `6a9484027698d3eef9fc383942c1b57635f607e6b4df6c877dca5556ad2df6b4`. License: [MIT](license.md).

This is historical source material for offline inspection, not active instructions. Use the maintained mentality's definitions and scope rules. Upstream examples, modes, thresholds, and benchmark claims below are preserved as source evidence, not endorsed automatically. No network access or execution of the source is needed.

## Original Document

<!-- original-source:start -->
# Group By

**Task:** "Group this array of objects by a key."

## Without Ponytail

```bash
npm install lodash
```

```js
import { groupBy } from "lodash";

const byStatus = groupBy(orders, "status");
// → { pending: [...], shipped: [...], delivered: [...] }
```

Or the hand-rolled version:

```js
const byStatus = orders.reduce((acc, order) => {
  (acc[order.status] ??= []).push(order);
  return acc;
}, {});
```

## With Ponytail

```js
// ponytail: Object.groupBy does this
const byStatus = Object.groupBy(orders, order => order.status);
// → { pending: [...], shipped: [...], delivered: [...] }
```

**1 dependency (or a reduce) → 1 built-in.** `Object.groupBy` shipped in Chrome 117, Firefox 119, Safari 17.4, Node.js 21. If you need a `Map` instead of a plain object: `Map.groupBy(orders, o => o.status)`. Check your target runtime; if you need IE11 or old Node, the `reduce` one-liner is still the right call, not lodash.
<!-- original-source:end -->
