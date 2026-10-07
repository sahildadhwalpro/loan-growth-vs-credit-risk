-- Risk analysis for the Risk Drivers page
-- Question: did growing this fast mean making worse loans?
--
-- charge_off_rate = % of loans that went bad (Charged Off)
-- cash_return_ratio = money paid back / money lent (under 1 means the lender lost money)


-- Overall
SELECT COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       SUM(total_payment) * 1.0 / SUM(loan_amount) AS cash_return_ratio
FROM bank_loan_data;
-- 13.8% went bad, cash return ratio 1.086


-- Weighted average interest rate (bigger loans count more)
SELECT SUM(int_rate * loan_amount) / SUM(loan_amount) * 100 AS weighted_avg_interest_rate
FROM bank_loan_data;
-- 12.81%


-- By quarter: did loans get worse as the lender grew?
SELECT DATEPART(QUARTER, issue_date) AS quarter,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       SUM(CASE WHEN LTRIM(term) = '60 months' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS pct_60_month,
       SUM(CASE WHEN grade IN ('D', 'E', 'F', 'G') THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS pct_grade_d_to_g,
       AVG(int_rate) * 100 AS avg_interest_rate
FROM bank_loan_data
GROUP BY DATEPART(QUARTER, issue_date)
ORDER BY quarter;
-- charge-off rate went from 12.5% in Q1 to 14.5% in Q4
-- 60-month loans went from 20% to 28%, but grades D to G went down from 25% to 23%
-- so it's not riskier borrowers, it's more 60-month loans


-- By term
SELECT LTRIM(term) AS term,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       AVG(int_rate) * 100 AS avg_interest_rate
FROM bank_loan_data
GROUP BY LTRIM(term);
-- 60-month loans go bad 22.3% of the time vs 10.7% for 36-month


-- By grade and term: is the lender charging enough for 60-month loans?
SELECT grade,
       LTRIM(term) AS term,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       AVG(int_rate) * 100 AS avg_interest_rate,
       SUM(total_payment) * 1.0 / SUM(loan_amount) AS cash_return_ratio,
       SUM(total_payment) - SUM(loan_amount) AS net_amount
FROM bank_loan_data
GROUP BY grade, LTRIM(term)
ORDER BY grade, term;
-- same grade, 60-month loans cost less than 1 point more but go bad more often
-- grade A 60-month is the only one that lost money: 0.959 ratio, about -$174K on 415 loans


-- By purpose
SELECT purpose,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       SUM(loan_amount) AS total_funded_amount,
       SUM(total_payment) AS total_amount_received,
       SUM(total_payment) * 1.0 / SUM(loan_amount) AS cash_return_ratio
FROM bank_loan_data
GROUP BY purpose
ORDER BY charge_off_rate DESC;
-- small business is the worst: 25.6% went bad, $24.12M lent and $23.81M paid back


-- By annual income
SELECT income_group,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate
FROM (
    SELECT id,
           loan_status,
           CASE WHEN annual_income < 30000 THEN '1. Under $30K'
                WHEN annual_income < 50000 THEN '2. $30K-50K'
                WHEN annual_income < 75000 THEN '3. $50K-75K'
                WHEN annual_income < 100000 THEN '4. $75K-100K'
                ELSE '5. $100K+'
           END AS income_group
    FROM bank_loan_data
) AS income_groups
GROUP BY income_group
ORDER BY income_group;
-- under $30K: 17.4%, $100K+: 10.4%


-- By monthly payment as % of monthly income
SELECT payment_group,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate
FROM (
    SELECT id,
           loan_status,
           CASE WHEN installment * 12 / annual_income < 0.05 THEN '1. Under 5%'
                WHEN installment * 12 / annual_income < 0.10 THEN '2. 5-10%'
                WHEN installment * 12 / annual_income < 0.15 THEN '3. 10-15%'
                ELSE '4. 15%+'
           END AS payment_group
    FROM bank_loan_data
) AS payment_groups
GROUP BY payment_group
ORDER BY payment_group;
-- under 5%: 11.4%, over 15%: 21.2%


-- By employment length
SELECT emp_length,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;
-- all between 12% and 15%, so job length doesn't really matter


-- By verification status
SELECT verification_status,
       COUNT(id) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(id) AS charge_off_rate,
       AVG(loan_amount) AS avg_loan_amount
FROM bank_loan_data
GROUP BY verification_status
ORDER BY charge_off_rate;
-- verified borrowers go bad more, but they also have much bigger loans
