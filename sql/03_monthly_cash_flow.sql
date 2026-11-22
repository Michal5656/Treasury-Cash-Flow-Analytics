
/*
 ===========================================================
PROJECT: TREASURY & CASH FLOW ANALYTICS
BUSINESS TASK 02: CASH FLOW ANALYSIS
===========================================================
Company: Global Manufacturing Group (synthetic dataset)
Database: treasury_analytics
Source schema: staging

BUSINESS OBJECTIVE:
Analyze cash inflows, outflows and net cash flow
across months, currencies and legal entities.

Identify significant monthly cash flow declines
and provide a foundation for treasury reporting.

IMPORTANT:
Financial amounts are expressed in their original
currencies. Consolidated reporting requires FX conversion.
Negative net cash flow does not automatically indicate
a liquidity shortage.
===========================================================

*/

/*
-----------------------------------------------------------
02.A - MONTHLY NET CASH FLOW
-----------------------------------------------------------
Business Question:
How does monthly net cash flow develop
across different currencies?

Expected Output:
- Year
- Month
- Currency
- Transaction count
- Net cash flow

Notes:
Net cash flow = total incoming + total outgoing amounts.
Outgoing transactions are stored as negative values.

 */
SELECT
EXTRACT (year FROM bt.booking_date) AS YEAR,
EXTRACT (month FROM bt.booking_date) AS MONTH,
bt.currency_code,
count(bt.amount) AS transaction_count,
SUM(bt.amount) AS net_CF
FROM staging.bank_transactions bt
GROUP BY 
EXTRACT (year FROM bt.booking_date),
EXTRACT (month FROM bt.booking_date),
bt.currency_code
ORDER BY  year, month, bt.currency_code;

/*
=================================================
02.B - MONTHLY INCOMING & OUTGOING CASH FLOW
=================================================

Business question:
How much cash flows in and out each month
across different currencies?

Expected Output:
- Year
- Month
- Currency
- Transaction count
- Incoming cash flow
- Outgoing cash flow
- Net cash flow

Notes:
Incoming cash flow includes positive amounts.
Outgoing cash flow includes negative amounts.
Net cash flow is the sum of both.
*/

SELECT
EXTRACT (year FROM bt.booking_date) AS YEAR,
EXTRACT (month FROM bt.booking_date) AS MONTH,
bt.currency_code,
count(bt.amount) AS transaction_count,
sum(bt.amount)FILTER (WHERE bt.amount < 0) AS sum_of_outgoing_transactions,
sum(bt.amount) FILTER (WHERE bt.amount > 0) AS sum_of_incoming_transactions,
SUM(bt.amount) AS net_CF
FROM staging.bank_transactions bt
GROUP BY 
EXTRACT (year FROM bt.booking_date),
EXTRACT (month FROM bt.booking_date),
bt.currency_code
ORDER BY YEAR,MONTH, bt.currency_code;

/*
-----------------------------------------------------------
02.C - MONTHLY CASH FLOW TRENDS & TOP 3 DECLINES
-----------------------------------------------------------

Business Question:
Which three months recorded the largest
month-over-month net cash flow declines
for each currency?

Expected Output:
- Month
- Currency
- Net cash flow
- Monthly change
- Change rank

Methodology:
1. Calculate monthly cash flow using a CTE.
2. Calculate month-over-month changes using LAG().
3. Rank changes separately for each currency
   using ROW_NUMBER().
4. Return the three largest negative changes
   for each currency.

Notes:
The first month has no previous comparison
and therefore returns NULL.

LAG() uses the previous available row.
Missing calendar months should be considered
when extending this analysis to production data.
*/

WITH monthly_cash_flow AS (
SELECT
        DATE_TRUNC('month', bt.booking_date)::date AS month,
        bt.currency_code,
        count(*) AS transaction_count,
        SUM(bt.amount) AS net_cash_flow 
        FROM staging.bank_transactions bt
        GROUP BY DATE_TRUNC('month', bt.booking_date), bt.currency_code 
),
 monthly_changes AS (
SELECT
	month,
	currency_code,
	net_cash_flow, 
	net_cash_flow - LAG(net_cash_flow) OVER (
	        PARTITION BY currency_code
        ORDER BY month )
        AS monthly_change
        FROM monthly_cash_flow 
        ),
   ranked_changes AS (
    SELECT
        month,
        currency_code,
        net_cash_flow,
        monthly_change,
        ROW_NUMBER() OVER (
            PARTITION BY currency_code
            ORDER BY monthly_change ASC NULLS LAST
        ) AS change_rank
    FROM monthly_changes 
)
SELECT
    month,
    currency_code,
    net_cash_flow,
    monthly_change,
    change_rank
FROM ranked_changes
WHERE change_rank  <= 3
	AND monthly_change < 0
ORDER BY currency_code, change_rank;

/*
-----------------------------------------------------------
02.D - CASH FLOW BY LEGAL ENTITY
-----------------------------------------------------------

Business Question:
Which legal entities generate the highest
cash inflows, outflows and negative net cash flow?

Expected Output:
- Entity name
- Country
- Currency
- Transaction count
- Incoming cash flow
- Outgoing cash flow
- Net cash flow

Methodology:
Join bank transactions to bank accounts
and link each account to its legal entity.

Notes:
Group by both entity and transaction currency
to avoid mixing different currencies.

Entity ID is retained in GROUP BY to distinguish
legal entities with potentially identical names.
*/

SELECT
	e.entity_name AS entity,
	e.country_code AS country,
	count(*) AS transaction_count,
	bt.currency_code AS currency,
	sum(bt.amount)FILTER (WHERE bt.amount < 0) AS outgoing_cash_flow,
	sum(bt.amount) FILTER (WHERE bt.amount > 0) AS incoming_cash_flow,
	SUM(bt.amount) AS net_cash_flow
    FROM staging.bank_transactions bt
JOIN staging.bank_accounts ba
    ON ba.account_id = bt.account_id
JOIN staging.entities e 
	ON ba.entity_id = e.entity_id
	GROUP BY e.entity_id, e.entity_name, e.country_code,  bt.currency_code
	ORDER BY e.entity_name, bt.currency_code
    ; 

 /*
-----------------------------------------------------------
02.E - JOIN INTEGRITY CHECK
-----------------------------------------------------------

Business Question:
Does joining transactions, bank accounts
and entities preserve the expected record count?

Expected Result:
60,000 transactions.

Actual Result:
60,000 transactions.

Conclusion:
The inner joins preserved the transaction count.
No transaction loss or multiplication was detected
in this specific join.
*/

SELECT
    COUNT(*) AS transaction_count
FROM staging.bank_transactions bt
JOIN staging.bank_accounts ba
    ON ba.account_id = bt.account_id
JOIN staging.entities e
    ON ba.entity_id = e.entity_id;

/*
===========================================================
BUSINESS TASK 02 - CONCLUSION
===========================================================

COMPLETED ANALYSES:
02.A - Monthly Net Cash Flow
02.B - Monthly Incoming & Outgoing Cash Flow
02.C - Monthly Trends and TOP 3 Declines
02.D - Cash Flow by Entity
02.E - JOIN Integrity Check

KEY FINDINGS:
- Net cash flow is negative across all four currencies
  over the analyzed period.
- Significant month-over-month declines were identified.
- Cash flow can be analyzed by individual legal entity.
- All 60,000 transactions were retained after joins.

BUSINESS CONSIDERATIONS:
- Investigate significant cash flow declines by category.
- Analyze opening balances before assessing liquidity.
- Apply FX conversion for consolidated reporting.
- Consider the effects of intercompany transfers.

NEXT STEP:
Business Task 03 - Liquidity & Bank Balance Analysis

===========================================================
END OF BUSINESS TASK 02
===========================================================
*/
