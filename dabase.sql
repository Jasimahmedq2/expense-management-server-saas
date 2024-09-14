CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    status BOOLEAN DEFAULT TRUE,
    logo VARCHAR(255),
    expire_date Date DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE user_role_enum AS ENUM ('employee', 'manager', 'admin', 'super_admin');


CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INT REFERENCES role(id),
    phone VARCHAR(20),
    user_type user_role_enum, 
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE module (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
);

CREATE TABLE sub_module (
    id SERIAL PRIMARY KEY,
    module_id INT REFERENCES module(id),
    name VARCHAR(255) NOT NULL,
);

CREATE TABLE company_module (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    module_id INT REFERENCES module(id),
    name VARCHAR(255) NOT NULL,
);

CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    name VARCHAR(255) NOT NULL,
    crated_by INT REFERENCES user(id),
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE role_permission (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES role(id),
    sub_module_id INT REFERENCES sub_module(id),
    company_id INT REFERENCES company(id),
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE user_otp (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES user(id),
    otp_code VARCHAR(6) NOT NULL,
    generated_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE
);

CREATE TABLE user_password_reset (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES user(id),
    reset_token VARCHAR(255),
    requested_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    is_used BOOLEAN DEFAULT FALSE
);

CREATE TABLE expense_category (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE budget (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    category_id INT REFERENCES expense_category(id),
    amount NUMERIC(12, 2) NOT NULL,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE expense (
    id SERIAL PRIMARY KEY,
    expense_no VARCHAR(255) NOT NULL,
    payment_method PAYMENT_METHOD,
    company_id INT REFERENCES company(id),
    category_id INT REFERENCES expense_category(id),
    amount NUMERIC(12, 2) NOT NULL,
    currency_id INT REFERENCES currency(id),
    receipt_url TEXT,
    expense_date DATE NOT NULL,
    created_by INT REFERENCES user(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE income_category (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE income (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    income_no VARCHAR(255) NOT NULL,
    payment_method PAYMENT_METHOD,
    category_id INT REFERENCES income_category(id),
    amount NUMERIC(12, 2) NOT NULL,
    currency_id INT REFERENCES currency(id),
    income_date DATE NOT NULL,
    created_by INT REFERENCES user(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    name VARCHAR(255) NOT NULL,
    account_type VARCHAR(50) CHECK (account_type IN ('Bank', 'Cash', 'Mobile Banking', 'Cheque')),
    balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE LEDGER_TYPE AS ENUM('IN', 'OUT')

CREATE TYPE PAYMENT_METHOD AS ENUM('BANK', 'CASH', 'MOBILE BANKING', 'CHEQUE')



CREATE TABLE account_ledger (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    account_id INT REFERENCES account(id),
    type LEDGER_TYPE,
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    voucher_no VARCHAR(255) NOT NULL,
    payment_method PAYMENT_METHOD,
    details VARCHAR(255),
    tr_type VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE balance_transfer (
    id SERIAL PRIMARY KEY,
    transfer_no VARCHAR(255) NOT NULL,
    company_id INT REFERENCES company(id),
    from_account_id INT REFERENCES account(id),
    to_account_id INT REFERENCES account(id),
    amount NUMERIC(12, 2) NOT NULL,
    transfer_date TIMESTAMP DEFAULT NOW(),
    created_by INT REFERENCES user(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE balance_adjustment (
    id SERIAL PRIMARY KEY,
    adjustment_no VARCHAR(255),
    company_id INT REFERENCES company(id),
    account_id INT REFERENCES account(id),
    amount NUMERIC(12, 2) NOT NULL,
    adjust_date TIMESTAMP DEFAULT NOW(),
    created_by INT REFERENCES user(id),
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    user_id REFERENCES user(id)
    company_id INT REFERENCES company(id),
    position VARCHAR(255),
    manager_id INT REFERENCES employee(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payroll (
    id SERIAL PRIMARY KEY,
    payroll_no VARCHAR(255),
    company_id INT REFERENCES company(id),
    employee_id INT REFERENCES employee(id),
    base_salary NUMERIC(12, 2) NOT NULL,
    total_addition NUMERIC(12, 2) DEFAULT 0.00, 
    total_deduction NUMERIC(12, 2) DEFAULT 0.00, 
    net_salary AS (base_salary + total_addition - total_deduction) STORED, 
    pay_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payroll_addition (
    id SERIAL PRIMARY KEY,
    payroll_id INT REFERENCES payroll(id),
    company_id INT REFERENCES company(id),
    description VARCHAR(255) NOT NULL, 
    amount NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payroll_deduction (
    id SERIAL PRIMARY KEY,
    payroll_id INT REFERENCES payroll(id),
    company_id INT REFERENCES company(id),
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);




CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    company_id INT REFERENCES company(id),
    created_by INT REFERENCES user(id),
    action VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE currency (
    id SERIAL PRIMARY KEY,
    code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL, 
    symbol VARCHAR(10) NOT NULL, 
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

