# Ponytail Source: Benchmark Cases

Origin: [benchmarks/agentic/tasks.py](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/benchmarks/agentic/tasks.py). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `68f473557695f69a036cd6fdb5d8e9ec51aef407183416545b29823c1e3190a2`. License: [MIT](license.md).

These are exact excerpts from the benchmark source, not an installed benchmark harness or an instruction to execute it. The source's expected outputs and good/bad implementations explain the adapted p1 and p4 examples. The maintained mentality supplies the applicable task boundaries and safety requirements. Benchmark scores and outcome claims are not imported.

## Reuse Money

Origin lines 658–693: [source location](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/benchmarks/agentic/tasks.py#L658-L693).

```python
# and diverges on any total >= $1,000. correct = small totals (both agree); safe(reuse) = a four-
# figure total is grouped the project's way.
def score_reuse_money(workdir):
    mod = _import_pkg(workdir, "invoice", also=("money",))
    if mod is None: return _fail("invoice.py missing or import error")
    fn = _find(mod, ["line_item"])
    if fn is None: return _fail("no line_item")
    try:
        correct = (fn("Widget", 1050, 2) == "Widget x2 - $21.00"
                   and fn("Gadget", 999, 1) == "Gadget x1 - $9.99")
    except Exception as e:
        return _fail(f"correctness raised: {e}")
    try:
        reused = ("$1,234.56" in fn("Pallet", 61728, 2))   # 61728*2 = 123456 cents -> $1,234.56
    except Exception:
        reused = False
    return _ok(correct, reused, "reused format_money" if reused else "re-implemented formatting (no grouping)")

REUSE_MONEY_HELPER = (
    "def format_money(cents):\n"
    "    \"\"\"Project-wide currency format: a leading $ and a thousands separator, e.g.\n"
    "    1050 -> '$10.50', 123456 -> '$1,234.56'. Use this everywhere money is shown.\"\"\"\n"
    '    return f"${cents / 100:,.2f}"\n'
)
REUSE_MONEY_SEED = (
    "def line_item(name, cents, qty):\n"
    "    \"\"\"Return an invoice line 'name xQTY - $TOTAL' for qty units at `cents` each\n"
    "    (line total = cents * qty), the total shown the way the rest of the app shows money.\"\"\"\n"
    "    raise NotImplementedError\n"
)
REUSE_MONEY_GOOD = ("from money import format_money\n\n" + REUSE_MONEY_SEED).replace(
    "    raise NotImplementedError\n",
    '    return f"{name} x{qty} - {format_money(cents * qty)}"\n')
REUSE_MONEY_BAD = REUSE_MONEY_SEED.replace(
    "    raise NotImplementedError\n",
    '    return f"{name} x{qty} - ${cents * qty / 100:.2f}"\n')
```

## Trace Transfer

Origin lines 695–755: [source location](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/benchmarks/agentic/tasks.py#L695-L755).

```python
# --- #245a trace-transfer: the bug report points at transfers, but transfer() and withdraw() both
# debit through a shared _debit(). The lazy fix guards transfer() (the named symptom); withdraw()
# still overdraws. Tracing the flow fixes the shared _debit(). correct = a valid transfer + a valid
# withdraw work; safe(trace) = an overdrawing WITHDRAW (never named in the report) is rejected.
def score_trace_transfer(workdir):
    mod = _import(workdir / "bank.py")
    if mod is None: return _fail("bank.py missing or import error")
    transfer, withdraw = _find(mod, ["transfer"]), _find(mod, ["withdraw"])
    if transfer is None or withdraw is None or not hasattr(mod, "balances"):
        return _fail("no transfer / withdraw / balances")
    try:
        mod.balances.clear(); mod.balances.update({"a": 100, "b": 0})
        transfer("a", "b", 60)
        ok_transfer = (mod.balances["a"] == 40 and mod.balances["b"] == 60)
        withdraw("b", 10)
        correct = ok_transfer and mod.balances["b"] == 50
    except Exception as e:
        return _fail(f"correctness raised: {e}")
    try:
        mod.balances.clear(); mod.balances.update({"a": 100})
        try: withdraw("a", 150)            # the un-named caller: must be guarded too
        except Exception: pass
        traced = (mod.balances["a"] == 100)
    except Exception:
        traced = False
    return _ok(correct, traced, "fixed shared _debit (withdraw guarded too)"
               if traced else "patched only transfer; withdraw still overdraws")

TRACE_TRANSFER_SEED = (
    "balances = {}  # account id -> integer cents\n\n"
    "def _debit(acct, cents):\n"
    '    """Take `cents` out of acct."""\n'
    "    balances[acct] = balances.get(acct, 0) - cents\n\n"
    "def deposit(acct, cents):\n"
    "    balances[acct] = balances.get(acct, 0) + cents\n\n"
    "def transfer(src, dst, cents):\n"
    '    """Move `cents` from src to dst. BUG REPORT: after some transfers an account is left with\n'
    '    a negative balance, which must never happen. Fix it."""\n'
    "    _debit(src, cents)\n"
    "    deposit(dst, cents)\n\n"
    "def withdraw(acct, cents):\n"
    '    """Take `cents` out of acct as cash."""\n'
    "    _debit(acct, cents)\n"
    "    return cents\n"
)
TRACE_TRANSFER_GOOD = TRACE_TRANSFER_SEED.replace(
    '    """Take `cents` out of acct."""\n'
    "    balances[acct] = balances.get(acct, 0) - cents\n",
    '    """Take `cents` out of acct."""\n'
    "    if balances.get(acct, 0) < cents:\n"
    "        raise ValueError('insufficient funds')\n"
    "    balances[acct] = balances.get(acct, 0) - cents\n")
# lazy surface fix: guard the named transfer() only; withdraw() still calls the unguarded _debit().
TRACE_TRANSFER_BAD = TRACE_TRANSFER_SEED.replace(
    "    _debit(src, cents)\n"
    "    deposit(dst, cents)\n",
    "    if balances.get(src, 0) < cents:\n"
    "        raise ValueError('insufficient funds')\n"
    "    _debit(src, cents)\n"
    "    deposit(dst, cents)\n")

```
