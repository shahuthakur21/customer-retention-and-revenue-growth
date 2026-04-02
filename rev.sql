--Table 1 - customer data

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
signup_date DATE,
city VARCHAR(50),
source_channel VARCHAR(50),
customer_segment VARCHAR(50),
subscription_plan VARCHAR (50),
monthly_value NUMERIC(10,2),
is_active VARCHAR(20)
);

--Table 2 transaction data
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions(
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
order_amount NUMERIC(10,2),
order_status VARCHAR(50),
refund_flag VARCHAR(20),
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
);

--Table 3 suppor_tickets_data
DROP TABLE IF EXISTS support_tickets;
CREATE TABLE support_tickets(
ticket_id INT PRIMARY KEY,
customer_id INT,
complaint_type VARCHAR(50),
resolution_days INT,
satisfaction_score INT,
ticket_status VARCHAR(20),
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
);

--Queries

--1) Total number of customers
SELECT COUNT(*) AS number_of_customers
FROM customers;
--2)Total transaction count
SELECT COUNT(*) AS total_transactions
FROM transactions;
--3) Total number of support_ticket
SELECT COUNT(*) AS total_tickets
FROM support_tickets;

--4) Overall Churn Rate
SELECT 
ROUND(COUNT(CASE WHEN is_active = 'Churned' THEN 1 END)*100.0/COUNT(*),2) 
AS churn_rate_percent
FROM customers;

--5) Churn by segment
SELECT customer_segment,
COUNT(*) AS total_customers,
COUNT(CASE WHEN is_active = 'Churned' THEN 1 END) AS churned_customers,
ROUND(COUNT(CASE WHEN is_active = 'Churned' THEN 1 END)*100.0/COUNT(*),2) AS churn_rate_percent
FROM customers
GROUP BY customer_segment
ORDER BY churn_rate_percent DESC;

--6)Revenue by Channel
SELECT c.source_channel,
SUM(t.order_amount) AS total_revenue
FROM customers c
JOIN transactions t
ON c.customer_id = t.customer_id
GROUP BY c.source_channel
ORDER BY total_revenue DESC;

--7) Refund Loss
SELECT c.source_channel,
SUM(t.order_amount) AS refund_loss
FROM customers c
JOIN transactions t 
ON c.customer_id = t.customer_id
WHERE t.refund_flag = 'Yes'
GROUP BY c.source_channel
ORDER BY refund_loss DESC;

--8) Support Resolution Impact on Churn
SELECT 
CASE 
WHEN s.resolution_days <= 2
THEN 'Fast'
WHEN s.resolution_days <= 5
THEN 'Moderate'
ELSE 'Slow'
END AS support_speed,
COUNT(*) AS total_cases,
COUNT(CASE WHEN c.is_active = 'Churned' THEN 1 END) AS churned_customers,
ROUND(COUNT(CASE WHEN c.is_active = 'Churned' THEN 1 END)*100.0/COUNT(*),2) AS churn_percent
FROM support_tickets s
JOIN customers c
ON s.customer_id = c.customer_id
GROUP BY support_speed
ORDER BY churned_customers DESC;