CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('savings', 'current', 'business')),
    balance NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
CREATE TABLE atm_machines (
    atm_id SERIAL PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive', 'maintenance')),
    cash_available NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    atm_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('withdrawal', 'deposit', 'transfer', 'balance_inquiry')),
    amount NUMERIC(15, 2) CHECK (amount >= 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (atm_id) REFERENCES atm_machines(atm_id) ON DELETE CASCADE
);
INSERT INTO users (first_name, last_name, email, phone)
VALUES 
('Ram', 'Shrestha', 'ram.shrestha@gmail.com', '9841234567'),
('Sita', 'Gurung', 'sita.gurung@gmail.com', '9807654321'),
('Kamal', 'Rai', 'kamal.rai@hotmail.com', '9812345678'),
('Gita', 'Thapa', 'gita.thapa@yahoo.com', '9823456789'),
('Hari', 'Lama', 'hari.lama@gmail.com', '9801234567');

INSERT INTO accounts (user_id, account_number, account_type, balance)
VALUES 
(1, '1000001234567891', 'savings', 200000.00),  
(1, '1000001234567892', 'current', 50000.00),   
(2, '2000002234567891', 'savings', 150000.00),  
(3, '3000003234567891', 'business', 800000.00), 
(4, '4000004234567891', 'savings', 100000.00),  
(5, '5000005234567891', 'savings', 75000.00); 

INSERT INTO atm_machines (location, status, cash_available)
VALUES 
('Thamel, Kathmandu', 'active', 500000.00),
('Lakeside, Pokhara', 'maintenance', 300000.00),
('Mahendranagar, Kanchanpur', 'active', 200000.00),
('Biratnagar, Morang', 'inactive', 0.00),
('Patan, Lalitpur', 'active', 400000.00);

INSERT INTO transactions (account_id, atm_id, transaction_type, amount)
VALUES 
(1, 1, 'withdrawal', 20000.00),  -- Ram withdrew from Thamel ATM
(2, 2, 'deposit', 30000.00),     -- Sita deposited in Lakeside ATM
(3, 3, 'withdrawal', 50000.00),  -- Kamal withdrew from Mahendranagar ATM
(4, 1, 'transfer', 25000.00),    -- Gita transferred from Thamel ATM
(5, 5, 'balance_inquiry', 0.00), -- Hari checked balance at Patan ATM
(1, 5, 'withdrawal', 10000.00);  -- Ram withdrew again from Patan ATM


SELECT * FROM users;


SELECT * FROM accounts;

SELECT * FROM atm_machines;

SELECT * FROM transactions;

SELECT u.user_id, u.first_name, u.last_name, a.account_id, a.account_type, a.balance
FROM users u
LEFT JOIN accounts a
ON u.user_id = a.user_id
WHERE a.account_type = 'savings';

SELECT u.user_id, u.first_name, u.last_name, a.account_id, a.account_number, a.account_type, a.balance
FROM users u
LEFT JOIN accounts a
ON u.user_id = a.user_id
ORDER BY u.user_id;

SELECT t.transaction_id, 
       a.account_number, 
       t.transaction_type, 
       t.amount, 
       atm.location AS atm_location, 
       t.transaction_date
FROM transactions t
JOIN accounts a
ON t.account_id = a.account_id
JOIN atm_machines atm
ON t.atm_id = atm.atm_id
ORDER BY 
t.transaction_date;

SELECT t.transaction_id, 
       a.account_number, 
       t.transaction_type, 
       t.amount, 
       atm.location AS atm_location
FROM transactions t
INNER JOIN accounts a
ON t.account_id = a.account_id
INNER JOIN atm_machines atm
ON t.atm_id = atm.atm_id;


SELECT a.account_id, 
       a.account_number, 
       t.transaction_id, 
       t.transaction_type, 
       t.amount
FROM accounts a
LEFT JOIN transactions t
ON a.account_id = t.account_id;


SELECT t.transaction_id, 
       t.transaction_type, 
       t.amount, 
       a.account_id, 
       a.account_number
FROM transactions t
RIGHT JOIN accounts a
ON t.account_id = a.account_id;


SELECT a.account_id, 
       a.account_number, 
       t.transaction_id, 
       t.transaction_type, 
       t.amount
FROM accounts a
FULL OUTER JOIN transactions t
ON a.account_id = t.account_id;
BEGIN;

INSERT INTO accounts (user_id, account_number, account_type, balance, created_at) 
VALUES (1, '3000003234567891', 'current', 50000.00, NOW());

DO $$
DECLARE
    new_account_id INT;
BEGIN
    SELECT account_id INTO new_account_id 
    FROM accounts 
    WHERE account_number = '3000003234567891';

    INSERT INTO transactions (account_id, atm_id, transaction_type, amount, transaction_date)
    VALUES (new_account_id, 1, 'deposit', 50000.00, NOW());
END $$;

COMMIT;





CREATE TABLE Accounts_1NF (
    account_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Transactions_1NF (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    atm_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts_1NF(account_id),
    FOREIGN KEY (atm_id) REFERENCES ATM_Machines(atm_id)
);

CREATE TABLE ATM_Machines_1NF (
    atm_id SERIAL PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    cash_available NUMERIC(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE User_Addresses (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    address VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


INSERT INTO User_Addresses (user_id, address)
VALUES
(1, 'Kathmandu'),
(2, 'Pokhara'),
(3, 'Chitwan'),
(4, 'Lalitpur'),
(5, 'Bhaktapur');


