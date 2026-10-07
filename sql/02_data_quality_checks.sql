-- Data quality checks
-- Ran these after loading the data, before doing any analysis


-- Total rows and unique loan ids
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT id) AS unique_ids
FROM bank_loan_data;
-- both are 38,576, so every loan id is unique


-- Checking for duplicate ids
SELECT id,
       COUNT(*) AS times_repeated
FROM bank_loan_data
GROUP BY id
HAVING COUNT(*) > 1;
-- no rows, so no duplicates


-- Missing job titles
SELECT COUNT(*) AS missing_emp_title
FROM bank_loan_data
WHERE emp_title IS NULL;
-- 1,438 loans (3.7%)


-- Missing values in the main columns
SELECT COUNT(*) AS rows_with_missing_values
FROM bank_loan_data
WHERE loan_amount IS NULL
   OR total_payment IS NULL
   OR int_rate IS NULL
   OR issue_date IS NULL
   OR loan_status IS NULL;
-- 0


-- Why I had to change the column types
SELECT COUNT(*) AS loans_over_32767
FROM bank_loan_data
WHERE loan_amount > 32767;
-- 725 loans would not fit in SMALLINT

SELECT COUNT(*) AS long_job_titles
FROM bank_loan_data
WHERE LEN(emp_title) > 50;
-- 31 titles are longer than 50 characters


-- Checking the categories for typos
SELECT loan_status,
       COUNT(*) AS total_loans
FROM bank_loan_data
GROUP BY loan_status;
-- Charged Off 5,333, Current 1,098, Fully Paid 32,145

SELECT term,
       COUNT(*) AS total_loans
FROM bank_loan_data
GROUP BY term;
-- 36 months 28,237, 60 months 10,339


-- Checking that the ranges make sense
SELECT MIN(issue_date) AS first_date,
       MAX(issue_date) AS last_date,
       MIN(loan_amount) AS smallest_loan,
       MAX(loan_amount) AS biggest_loan,
       MIN(int_rate) AS lowest_rate,
       MAX(int_rate) AS highest_rate
FROM bank_loan_data;
-- all loans are from 2021, loans from 500 to 35,000, rates from 5.42% to 24.59%


-- Should I drop the loans with no job title?
-- Comparing the bad loan rate with and without a job title
SELECT COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate
FROM bank_loan_data
WHERE emp_title IS NULL;
-- 18.5%

SELECT COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate
FROM bank_loan_data
WHERE emp_title IS NOT NULL;
-- 13.6%
-- loans with no job title go bad more often, so I kept them
