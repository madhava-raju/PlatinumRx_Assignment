USE hotel_project;

CREATE TABLE clinics (
    cid VARCHAR(50),
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE customer (
    uid VARCHAR(50),
    name VARCHAR(100),
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50),
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount INT,
    datetime DATETIME,
    sales_channel VARCHAR(50)
);

CREATE TABLE expenses (
    eid VARCHAR(50),
    cid VARCHAR(50),
    description VARCHAR(200),
    amount INT,
    datetime DATETIME
);


INSERT INTO clinics VALUES
('c1','ABC Clinic','Hyderabad','Telangana','India'),
('c2','XYZ Clinic','Hyderabad','Telangana','India'),
('c3','Care Clinic','Chennai','Tamil Nadu','India'),
('c4','Health Plus','Chennai','Tamil Nadu','India'),
('c5','Wellness Center','Bangalore','Karnataka','India');


INSERT INTO customer VALUES
('u1','John','9999999991'),
('u2','Ram','9999999992'),
('u3','Sita','9999999993'),
('u4','Ravi','9999999994'),
('u5','Anita','9999999995');


INSERT INTO clinic_sales VALUES
('o1','u1','c1',10000,'2021-01-10 10:00:00','online'),
('o2','u2','c1',8000,'2021-01-15 12:00:00','offline'),
('o3','u3','c2',15000,'2021-02-10 11:00:00','online'),
('o4','u1','c2',7000,'2021-02-20 13:00:00','app'),
('o5','u4','c3',20000,'2021-03-05 09:00:00','offline'),
('o6','u5','c3',5000,'2021-03-15 14:00:00','online'),
('o7','u2','c4',12000,'2021-04-10 10:30:00','app'),
('o8','u3','c4',9000,'2021-04-20 15:00:00','offline'),
('o9','u1','c5',25000,'2021-05-05 16:00:00','online'),
('o10','u4','c5',10000,'2021-05-25 17:00:00','offline');


INSERT INTO expenses VALUES
('e1','c1','rent',5000,'2021-01-12 09:00:00'),
('e2','c1','salary',4000,'2021-01-20 10:00:00'),
('e3','c2','equipment',8000,'2021-02-15 11:00:00'),
('e4','c3','rent',10000,'2021-03-10 12:00:00'),
('e5','c3','salary',8000,'2021-03-20 13:00:00'),
('e6','c4','maintenance',7000,'2021-04-15 14:00:00'),
('e7','c5','rent',12000,'2021-05-10 15:00:00'),
('e8','c5','salary',9000,'2021-05-20 16:00:00');

# 1. Find the revenue we got from each sales channel in a given year
SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;


# 2. Find top 10 the most valuable customers for a given year

SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

# 3. Find month wise revenue, expense, profit , status (profitable / not-profitable) for a given year

SELECT 
    m.month,
    m.revenue,
    IFNULL(e.expense, 0) AS expense,
    (m.revenue - IFNULL(e.expense, 0)) AS profit,
    CASE 
        WHEN (m.revenue - IFNULL(e.expense, 0)) > 0 
        THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM (
    SELECT 
        MONTH(datetime) AS month, 
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
) m
LEFT JOIN (
    SELECT 
        MONTH(datetime) AS month, 
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
) e
ON m.month = e.month;

# 4. For each city find the most profitable clinic for a given month

WITH clinic_profit AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - IFNULL(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e 
        ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime) = 3
      AND YEAR(cs.datetime) = 2021
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT city, cid, profit
FROM ranked
WHERE rnk = 1;

# 5. For each state find the second least profitable clinic for a given month

WITH clinic_profit AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - IFNULL(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e 
        ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime) = 3
      AND YEAR(cs.datetime) = 2021
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT state, cid, profit
FROM ranked
WHERE rnk = 2;


