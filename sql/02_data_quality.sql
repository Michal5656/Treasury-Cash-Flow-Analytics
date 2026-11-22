-- Run after CSV import. Expected transaction count = 60000.
SELECT 'entities' AS dataset, COUNT(*) AS rows FROM staging.entities
UNION ALL SELECT 'bank_accounts', COUNT(*) FROM staging.bank_accounts
UNION ALL SELECT 'transaction_categories', COUNT(*) FROM staging.transaction_categories
UNION ALL SELECT 'opening_balances', COUNT(*) FROM staging.opening_balances
UNION ALL SELECT 'fx_rates', COUNT(*) FROM staging.fx_rates
UNION ALL SELECT 'bank_transactions', COUNT(*) FROM staging.bank_transactions;

-- Find unmapped categories (intentional data-quality issue).
SELECT COUNT(*) AS missing_category FROM staging.bank_transactions WHERE category_id IS NULL;

-- Validate IC transfer pairs; expected zero rows.
SELECT reference, COUNT(*) AS row_count, SUM(amount) AS net_amount
FROM staging.bank_transactions
WHERE counterparty_type = 'INTERCOMPANY'
GROUP BY reference
HAVING COUNT(*) <> 2 OR SUM(amount) <> 0;

-- Check currency consistent with bank account; expected zero.
SELECT COUNT(*) AS mismatched_currency
FROM staging.bank_transactions t JOIN staging.bank_accounts a USING(account_id)
WHERE t.currency_code <> a.currency_code;
