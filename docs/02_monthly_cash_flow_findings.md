# Business Task 02 – Cash Flow Analysis

## Business Objective

Analyze bank transaction data to evaluate cash flow trends
across currencies, months, and legal entities.

The goal is to identify significant cash flow changes,
compare financial activity across entities, and support
treasury management in monitoring cash movements.

## Dataset Overview

- **Company:** Global Manufacturing Group (fictional)
- **Dataset:** Synthetic bank transactions
- **Total transactions:** 60,000
- **Period:** January 2024 – September 2026
- **Legal entities:** 4
- **Currencies:** CZK, EUR, PLN, USD
- **Tools:** PostgreSQL, DBeaver

---

## Analysis Overview

### 02.A – Monthly Net Cash Flow

**Business Question:**
How does monthly net cash flow develop across different currencies?

Monthly net cash flow was calculated using `SUM(amount)`,
grouped by year, month, and currency.

This analysis provides an overview of historical cash flows
and identifies periods with significant net outflows.

### 02.B – Monthly Incoming & Outgoing Cash Flow

**Business Question:**
How much cash flows in and out each month?

Conditional aggregation using `SUM() FILTER (WHERE ...)`
was applied to calculate:

- **Incoming Cash Flow:** Positive transactions
- **Outgoing Cash Flow:** Negative transactions
- **Net Cash Flow:** Sum of incoming and outgoing amounts

This approach helps identify whether monthly cash flow
changes are driven by incoming or outgoing payments.

### 02.C – Monthly Cash Flow Trends & TOP 3 Declines

**Business Question:**
Which months recorded the largest month-over-month
declines in net cash flow?

The analysis used SQL window functions and CTEs to:

1. Calculate monthly net cash flow.
2. Retrieve previous monthly values using `LAG()`.
3. Calculate month-over-month changes.
4. Rank changes by currency using `ROW_NUMBER()`.
5. Identify the three largest negative changes per currency.

**Key Findings – Largest Monthly Declines**

| Currency | Month | Monthly Change |
|----------|-------|---------------:|
| CZK | January 2026 | -3,905,223.12 |
| EUR | June 2026 | -3,959,700.91 |
| PLN | November 2024 | -1,946,475.53 |
| USD | September 2025 | -2,772,422.37 |

Amounts are expressed in their original currencies
and must not be directly compared without FX conversion.

### 02.D – Cash Flow by Legal Entity

**Business Question:**
Which legal entities generate the highest incoming
and outgoing cash flows?

Three relational tables were connected using `JOIN`:

- `bank_transactions`
- `bank_accounts`
- `entities`

The analysis calculated:

- Transaction count
- Incoming cash flow
- Outgoing cash flow
- Net cash flow

Results were grouped by legal entity and transaction currency.

**Key Finding:**

All four legal entities recorded negative net cash flow
in their analyzed currencies over the reporting period.

Negative cash flow does not necessarily indicate
a liquidity shortage.

---

## Data Integrity Validation

An additional SQL check was performed to validate
the joins between bank transactions, bank accounts,
and legal entities.

- **Original transactions:** 60,000
- **Transactions after JOIN:** 60,000
- **Difference:** 0

The applied joins preserved the expected transaction count.

---

## SQL Techniques Applied

- `JOIN` – Combining relational tables
- `GROUP BY` – Grouping transactions
- `SUM()` and `COUNT()` – Aggregations
- `FILTER (WHERE ...)` – Conditional aggregations
- `EXTRACT()` – Extracting year and month
- `DATE_TRUNC()` – Monthly date aggregation
- `WITH` – Common Table Expressions
- `LAG()` – Previous period comparisons
- `ROW_NUMBER()` – Ranking monthly changes
- `PARTITION BY` – Separate calculations by currency

---

## Business Recommendations

1. **Investigate significant cash flow declines.**
   Analyze transaction categories and payment timing
   to identify potential drivers of large outflows.

2. **Monitor liquidity alongside cash flow.**
   Include opening balances and available financing
   before evaluating liquidity risks.

3. **Improve cash flow visibility.**
   Develop regular reporting of monthly inflows,
   outflows, and net cash flow.

4. **Implement currency conversion.**
   Convert transactions into a common reporting currency
   before consolidated comparisons.

5. **Review intercompany transactions.**
   Evaluate the impact of internal transfers
   on consolidated financial reporting.

---

## Limitations

- The dataset is synthetic.
- Transaction amounts are reported in original currencies.
- Opening balances are not included in this analysis.
- Cash flows are not yet classified into operating,
  investing, and financing activities.
- Missing calendar months may require additional handling
  when calculating month-over-month changes.

---

## Conclusion

Business Task 02 provides a structured analysis of
cash flow movements across months, currencies,
and legal entities.

The SQL analysis demonstrates how transaction-level
data can be transformed into meaningful treasury
reporting information.

**Next Step:**
Business Task 03 – Liquidity & Bank Balance Analysis.
