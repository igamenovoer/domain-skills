# Ponytail Source: csv-sum

Origin: [csv-sum.md](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/csv-sum.md). Revision: `356918eba965ee1eac64bd3a7f0dd02108350de5`. Captured: 2026-09-14. Original file SHA-256: `3e0ba36601b03f6d26b9afafe791d9332d4159ac865e345840d9b187bd823f78`. License: [MIT](license.md).

This is historical source material for offline inspection, not active instructions. Use the maintained mentality's definitions and scope rules. Upstream examples, modes, thresholds, and benchmark claims below are preserved as source evidence, not endorsed automatically. No network access or execution of the source is needed.

## Original Document

<!-- original-source:start -->
# CSV Sum

**Task:** "Write Python code that reads sales.csv and sums the 'amount' column."

Verbatim model output from a benchmark run, Claude Haiku 4.5, no-skill arm vs ponytail arm, temperature 1, source `benchmarks/output.json`. Reproduce: `npx promptfoo@latest eval -c benchmarks/promptfooconfig.yaml`.

## Without Ponytail, 20 lines of code

# Python code to read sales.csv and sum the 'amount' column

```python
import pandas as pd

# Read the CSV file
df = pd.read_csv('sales.csv')

# Sum the 'amount' column
total_amount = df['amount'].sum()

# Print the result
print(f"Total amount: ${total_amount:,.2f}")
```

## Alternative methods:

**Using CSV module (without pandas):**
```python
import csv

total_amount = 0

with open('sales.csv', 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        total_amount += float(row['amount'])

print(f"Total amount: ${total_amount:,.2f}")
```

**Using pandas with error handling:**
```python
import pandas as pd

try:
    df = pd.read_csv('sales.csv')
    total_amount = df['amount'].sum()
    print(f"Total amount: ${total_amount:,.2f}")
except FileNotFoundError:
    print("Error: sales.csv not found")
except KeyError:
    print("Error: 'amount' column not found")
```

**The pandas method is recommended** because it's:
- More concise and readable
- Handles data types automatically
- Provides built-in error handling
- Efficient for large files

## With Ponytail, 3 lines of code

```python
import csv

total = sum(float(row['amount']) for row in csv.DictReader(open('sales.csv')))
print(total)
```

Skipped: pandas, error handling, file closing, add when the CSV is large, malformed, or you need more analysis.

**20 → 3 lines of code**, same model, same prompt.
<!-- original-source:end -->
