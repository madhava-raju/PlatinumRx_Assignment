CREATE DATABASE hotel_project;
USE hotel_project;


CREATE TABLE users (
    user_id VARCHAR(50),
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address VARCHAR(200)
);

CREATE TABLE bookings (
    booking_id VARCHAR(50),
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50),
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity FLOAT
);

CREATE TABLE items (
    item_id VARCHAR(50),
    item_name VARCHAR(100),
    item_rate INT
);


INSERT INTO users VALUES
('21wrcxuy-67erfn','John Doe','9700000001','john.doe@example.com','ABC City'),
('22abcyz-98ghjk','Ram Kumar','9700000002','ram@gmail.com','Hyderabad'),
('23pqrs-45lmno','Sita Devi','9700000003','sita@gmail.com','Chennai'),
('24uvwx-78qrst','Ravi Teja','9700000004','ravi@gmail.com','Bangalore');


INSERT INTO bookings VALUES
('bk-001','2021-09-23 07:36:48','rm-101','21wrcxuy-67erfn'),
('bk-002','2021-10-05 10:15:20','rm-102','22abcyz-98ghjk'),
('bk-003','2021-11-12 12:30:10','rm-103','23pqrs-45lmno'),
('bk-004','2021-11-20 09:45:00','rm-104','21wrcxuy-67erfn'),
('bk-005','2021-12-01 14:10:05','rm-105','24uvwx-78qrst');


INSERT INTO items VALUES
('itm-a9e8-q8fu','Tawa Paratha',18),
('itm-a07vh-aer8','Mix Veg',89),
('itm-w978-23u4','Paneer Butter Masala',150),
('itm-x123-abcd','Fried Rice',120);


INSERT INTO booking_commercials VALUES
('q34r-3q4o8-q34u','bk-001','bl-001','2021-09-23 12:03:22','itm-a9e8-q8fu',3),
('q3o4-ahf32-o2u4','bk-001','bl-001','2021-09-23 12:03:22','itm-a07vh-aer8',1),
('134lr-oyfo8-3qk4','bk-002','bl-002','2021-10-05 13:20:10','itm-w978-23u4',2),
('34qj-k3q4h-q34k','bk-003','bl-003','2021-11-12 15:10:00','itm-x123-abcd',2),
('98as-12qw-er45','bk-003','bl-003','2021-11-12 15:10:00','itm-a9e8-q8fu',4);
INSERT INTO booking_commercials VALUES
('77gh-56ty-ui89','bk-004','bl-004','2021-11-20 11:00:00','itm-a07vh-aer8',3),

('11zx-22cv-33bn','bk-005','bl-005','2021-12-01 16:00:00','itm-w978-23u4',1),
('44nm-55lk-66jh','bk-005','bl-005','2021-12-01 16:00:00','itm-x123-abcd',2);

# 1. For every user in the system, get the user_id and last booked room_no

SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) t
ON b.user_id = t.user_id 
AND b.booking_date = t.last_booking;

# 2. Get booking_id and total billing amount of every booking created in November, 2021

SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i 
    ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;

# 3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount >1000

SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i 
    ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

# 4. Determine the most ordered and least ordered item of each month of year 2021

WITH item_orders AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        i.item_name,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), i.item_name
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
    FROM item_orders
)
SELECT month, item_name, total_qty
FROM ranked
WHERE max_rank = 1 OR min_rank = 1;

# 5. Find the customers with the second highest bill value of each month of year 2021

WITH monthly_bills AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        b.user_id,
        SUM(bc.item_quantity * i.item_rate) AS total_bill
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), b.user_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
    FROM monthly_bills
)
SELECT month, user_id, total_bill
FROM ranked
WHERE rnk = 2;