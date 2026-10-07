-- Bank Loan Project
-- Creating the database and the table for the loan data (SQL Server)

CREATE DATABASE bank_loan_db;
GO

USE bank_loan_db;
GO

-- I loaded Bank_Loan_Data.csv with the Import Flat File wizard.
-- The wizard picked some column types that were too small, so I changed them:
--   loan_amount and total_payment were SMALLINT (max 32,767), changed to INT
--   emp_title was NVARCHAR(50), changed to VARCHAR(100) because some job titles are longer

CREATE TABLE bank_loan_data (
    id INT PRIMARY KEY,
    address_state VARCHAR(2),
    application_type VARCHAR(20),
    emp_length VARCHAR(20),
    emp_title VARCHAR(100),
    grade VARCHAR(1),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(20),
    next_payment_date DATE,
    member_id INT,
    purpose VARCHAR(50),
    sub_grade VARCHAR(2),
    term VARCHAR(20),
    verification_status VARCHAR(20),
    annual_income FLOAT,
    dti FLOAT,
    installment FLOAT,
    int_rate FLOAT,
    loan_amount INT,
    total_acc INT,
    total_payment INT
);

-- Notes:
-- term has a space at the start (' 36 months'), so I use LTRIM(term) when filtering on it
-- int_rate and dti are decimals (0.12 means 12%)
