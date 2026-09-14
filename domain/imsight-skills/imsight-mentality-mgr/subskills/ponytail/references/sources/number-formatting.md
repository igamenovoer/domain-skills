# Ponytail Source: number-formatting

Origin: [number-formatting.md](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/number-formatting.md). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `599a9d2f5af00489fd7cbed813b429a7ff43abaac433c9db48495c6f457cc203`. License: [MIT](license.md).

This is historical source material for offline inspection, not active instructions. Use the maintained mentality's definitions and scope rules. Upstream examples, modes, thresholds, and benchmark claims below are preserved as source evidence, not endorsed automatically. No network access or execution of the source is needed.

## Original Document

<!-- original-source:start -->
# Number Formatting

**Task:** "Format numbers as currency and with thousand separators."

## Without Ponytail

```bash
npm install numeral
# or: npm install accounting
```

```js
import numeral from "numeral";

numeral(1234567.89).format("$1,234.00"); // "$1,234,567.89"
numeral(0.745).format("0.0%");           // "74.5%"
numeral(1500).format("0.0a");            // "1.5k"
```

## With Ponytail

```js
// ponytail: Intl.NumberFormat does this, locale-aware
new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
  .format(1234567.89);
// → "$1,234,567.89"

new Intl.NumberFormat("en-US", { style: "percent" })
  .format(0.745);
// → "74.5%"

new Intl.NumberFormat("en-US", { notation: "compact" })
  .format(1500);
// → "1.5K"
```

**1 dependency → 0 dependencies.** `Intl.NumberFormat` is built into every JS runtime, handles every locale correctly, and gets currency symbols, decimal separators, and grouping right for any market without a lookup table. A library that hardcodes formats will always be wrong for someone.
<!-- original-source:end -->
