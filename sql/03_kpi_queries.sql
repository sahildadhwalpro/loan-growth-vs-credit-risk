-- KPI queries for the Summary and Segments pages
-- MTD = December 2021 (latest month), PMTD = November 2021 (month before)


-- Total loan applications
SELECT COUNT(id) AS total_loan_applications
FROM bank_loan_data;
-- 38,576

SELECT COUNT(id) AS mtd_loan_applications
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;
-- 4,314

SELECT COUNT(id) AS pmtd_loan_applications
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;
-- 4,035


-- Total funded amount
SELECT SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data;
-- $435.8M

SELECT SUM(loan_amount) AS mtd_funded_amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;
-- $54.0M

SELECT SUM(loan_amount) AS pmtd_funded_amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;
-- $47.8M


-- Total amount received
SELECT SUM(total_payment) AS total_amount_received
FROM bank_loan_data;
-- $473.1M

SELECT SUM(total_payment) AS mtd_amount_received
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;
-- $58.1M

SELECT SUM(total_payment) AS pmtd_amount_received
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;
-- $50.1M


-- Average interest rate
SELECT AVG(int_rate) * 100 AS avg_interest_rate
FROM bank_loan_data;
-- 12.05%

SELECT AVG(int_rate) * 100 AS mtd_avg_interest_rate
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;
-- 12.36%

SELECT AVG(int_rate) * 100 AS pmtd_avg_interest_rate
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;
-- 11.94%


-- Average DTI
SELECT AVG(dti) * 100 AS avg_dti
FROM bank_loan_data;
-- 13.33%

SELECT AVG(dti) * 100 AS mtd_avg_dti
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;
-- 13.67%

SELECT AVG(dti) * 100 AS pmtd_avg_dti
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;
-- 13.30%


-- Good loans (Fully Paid or Current)
SELECT COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0 / COUNT(id) AS good_loan_percentage
FROM bank_loan_data;
-- 86.2%

SELECT COUNT(id) AS good_loan_applications,
       SUM(loan_amount) AS good_loan_funded_amount,
       SUM(total_payment) AS good_loan_amount_received
FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';
-- 33,243 loans, $370.2M funded, $435.8M received


-- Bad loans (Charged Off)
SELECT COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0 / COUNT(id) AS bad_loan_percentage
FROM bank_loan_data;
-- 13.8%

SELECT COUNT(id) AS bad_loan_applications,
       SUM(loan_amount) AS bad_loan_funded_amount,
       SUM(total_payment) AS bad_loan_amount_received
FROM bank_loan_data
WHERE loan_status = 'Charged Off';
-- 5,333 loans, $65.5M funded, $37.3M received
-- so the lender lost about $28.2M on bad loans


-- Loan status table
SELECT loan_status,
       COUNT(id) AS total_loan_applications,
       SUM(total_payment) AS total_amount_received,
       SUM(loan_amount) AS total_funded_amount,
       AVG(int_rate) * 100 AS avg_interest_rate,
       AVG(dti) * 100 AS avg_dti
FROM bank_loan_data
GROUP BY loan_status;


-- Segments page: by month
SELECT MONTH(issue_date) AS month_number,
       DATENAME(MONTH, issue_date) AS month_name,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date);
-- funded amount went from $25.0M in January to $54.0M in December


-- By state
SELECT address_state,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY address_state
ORDER BY total_loan_applications DESC;


-- By term
SELECT term,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY term
ORDER BY term;


-- By employment length
SELECT emp_length,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;


-- By purpose
SELECT purpose,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY purpose
ORDER BY total_loan_applications DESC;


-- By home ownership
SELECT home_ownership,
       COUNT(id) AS total_loan_applications,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY total_loan_applications DESC;
