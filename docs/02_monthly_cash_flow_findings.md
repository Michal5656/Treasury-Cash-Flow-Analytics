Business Task 02 – Cash Flow Analysis

Business Objective

Analyze bank transaction data to evaluate cash flow trends across currencies, months, and legal entities.

The objective is to identify significant cash flow changes, compare financial activity across entities, and support treasury management in monitoring cash movements.

Dataset Overview

Company: Global Manufacturing Group (fictional)

Dataset: Synthetic bank transactions

Total transactions: 60,000

Period: January 2024 – September 2026

Legal entities: 4

Currencies: CZK, EUR, PLN, USD

Tools: PostgreSQL, DBeaver

Source tables: bank_transactions, bank_accounts, entities

Analysis Overview

02.A – Monthly Net Cash Flow

Business Question: How does monthly net cash flow develop across different currencies?

Monthly net cash flow was calculated using SUM(amount), with transactions grouped by year, month, and currency.

This analysis provides a historical overview of monthly cash movements and allows the identification of periods with unusually high net outflows.

02.B – Monthly Incoming & Outgoing Cash Flow

Business Question: How much cash flows in and out each month?

Conditional aggregation using SUM() FILTER (WHERE ...) was applied to calculate:

Incoming cash flow – positive transactions

Outgoing cash flow – negative transactions

Net cash flow – total sum of incoming and outgoing transactions

This approach helps distinguish between changes driven by lower customer receipts and those caused by higher payments.

02.C – Monthly Cash Flow Trends & TOP 3 Declines

Business Question: Which months experienced the largest month-over-month deterioration in net cash flow?

Common Table Expressions (CTEs) and SQL window functions were used to:

Aggregate monthly net cash flow.

Calculate month-over-month changes using LAG().

Rank monthly changes separately for each currency using ROW_NUMBER().

Identify the three largest negative changes for each currency.

Key Findings – Largest Monthly Declines

Currency

Month

Monthly Change

CZK

January 2026

-3,905,223.12

EUR

June 2026

-3,959,700.91

PLN

November 2024

-1,946,475.53

USD

September 2025

-2,772,422.37

These figures represent the largest month-over-month declines within each currency, not consolidated cash flow amounts.

02.D – Cash Flow by Legal Entity

Business Question: Which legal entities generate the highest cash inflows, outflows, and negative net cash flow?

Three database tables were joined to associate bank transactions with their respective legal entities.

bank_transactions – transaction-level information

bank_accounts – bank account ownership

entities – legal entity details

The analysis calculated transaction counts, incoming cash flow, outgoing cash flow, and net cash flow for each entity and currency.

Key Finding:

All four entities recorded negative net cash flow in their analyzed transaction currencies over the reporting period.

However, negative cash flow does not necessarily indicate insufficient liquidity.

Data Integrity Validation

An additional SQL check was performed to verify whether joining the three tables caused transaction loss or duplication.

Original transaction count: 60,000

Transaction count after JOINs: 60,000

Difference: 0

The result confirms that the applied joins preserved the expected transaction count.

SQL Techniques Applied

JOIN – combining related database tables

GROUP BY – aggregating transaction data

SUM() and COUNT() – financial and volume calculations

FILTER (WHERE ...) – conditional aggregation

EXTRACT() and DATE_TRUNC() – date transformations

WITH – Common Table Expressions

LAG() – retrieving previous period values

ROW_NUMBER() – ranking monthly changes

PARTITION BY – performing separate calculations by currency

Business Recommendations

Investigate significant cash flow declines. Review transaction categories and payment timing to identify potential drivers of unusually high net outflows.

Monitor liquidity alongside cash flow. Incorporate opening balances and available financing before drawing conclusions about financial liquidity.

Improve cash flow visibility. Develop regular reporting of monthly incoming, outgoing, and net cash flow.

Implement currency conversion. Convert transaction values into a common reporting currency before consolidated comparisons.

Review intercompany transactions. Consider internal transfers and their potential impact on consolidated reporting.

Limitations

The dataset is synthetic and does not represent real corporate financial performance.

Cash flow results are reported in original transaction currencies.

Historical bank balances and available credit facilities were not included in this analysis.

The analysis does not yet distinguish all operating, investing, and financing cash flows.

Monthly decline calculations compare consecutive available monthly records; missing calendar periods would require additional handling.

Conclusion

The analysis provides a structured overview of cash flow activity across currencies, reporting periods, and legal entities.

The results demonstrate how SQL can be used to transform transaction-level data into actionable financial information.

The next phase of the project will focus on Liquidity & Bank Balance Analysis, incorporating opening balances to evaluate historical cash positions and liquidity development.
