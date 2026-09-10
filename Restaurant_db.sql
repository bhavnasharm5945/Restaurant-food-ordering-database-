-- Restaurant Food Ordering Database
-- BCA Final Year MySQL Project

DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db;
USE restaurant_db;

-- =========================
-- CUSTOMERS TABLE
-- =========================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100),
    address VARCHAR(255)
);

-- =========================
-- DINING TABLES
-- =========================
CREATE TABLE dining_tables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT UNIQUE NOT NULL,
    capacity INT NOT NULL,
    status ENUM('Available','Occupied','Reserved') DEFAULT 'Available'
);

-- =========================
-- STAFF TABLE
-- =========================
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    role ENUM('Manager','Chef','Waiter','Cashier') NOT NULL,
    phone VARCHAR(15),
    salary DECIMAL(10,2)
);

-- =========================
-- MENU TABLE
-- =========================
CREATE TABLE menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category ENUM('Starter','Main Course','Dessert','Drink'),
    price DECIMAL(10,2) NOT NULL,
    availability BOOLEAN DEFAULT TRUE
);

-- =========================
-- ORDERS TABLE
-- =========================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    table_id INT,
    waiter_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending','Preparing','Served','Completed','Cancelled')
        DEFAULT 'Pending',

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (table_id) REFERENCES dining_tables(table_id),
    FOREIGN KEY (waiter_id) REFERENCES staff(staff_id)
);

-- =========================
-- ORDER DETAILS TABLE
-- =========================
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    menu_id INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2),

    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES menu(menu_id)
);

-- =========================
-- BILLING TABLE
-- =========================
CREATE TABLE billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE,
    total_amount DECIMAL(10,2),
    payment_method ENUM('Cash','Card','UPI'),
    payment_status ENUM('Paid','Unpaid') DEFAULT 'Unpaid',

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =========================
-- SAMPLE DATA
-- =========================

INSERT INTO customers (customer_name, phone, email, address) VALUES
('Rahul Sharma','9876543210','rahul@gmail.com','Delhi'),
('Priya Singh','9876543211','priya@gmail.com','Ghaziabad'),
('Amit Kumar','9876543212','amit@gmail.com','Modinagar'),
('Neha Verma','9876543213','neha@gmail.com','Meerut'),
('Rohan Malik','9876543214','rohan@gmail.com','Noida');

INSERT INTO dining_tables (table_number, capacity, status) VALUES
(1,4,'Available'),
(2,2,'Reserved'),
(3,6,'Occupied'),
(4,4,'Available'),
(5,8,'Available');

INSERT INTO staff (staff_name, role, phone, salary) VALUES
('Rakesh','Manager','9991111111',40000),
('Vikas','Chef','9991111112',30000),
('Mohit','Waiter','9991111113',18000),
('Sohan','Cashier','9991111114',22000),
('Ankit','Waiter','9991111115',18000);

INSERT INTO menu (item_name, category, price) VALUES
('Paneer Tikka','Starter',250),
('Veg Biryani','Main Course',220),
('Butter Naan','Main Course',40),
('Dal Makhani','Main Course',180),
('Cold Coffee','Drink',120),
('Ice Cream','Dessert',90),
('Momos','Starter',150),
('Masala Dosa','Main Course',160);

INSERT INTO orders (customer_id, table_id, waiter_id, order_status) VALUES
(1,1,3,'Preparing'),
(2,2,3,'Served'),
(3,3,5,'Completed');

INSERT INTO order_details (order_id, menu_id, quantity, subtotal) VALUES
(1,1,2,500),
(1,3,4,160),
(2,2,1,220),
(2,5,2,240),
(3,4,2,360),
(3,6,1,90);

INSERT INTO billing (order_id, total_amount, payment_method, payment_status) VALUES
(1,660,'UPI','Paid'),
(2,460,'Cash','Paid'),
(3,450,'Card','Paid');

-- =========================
-- USEFUL PROJECT QUERIES
-- =========================

-- 1. Show all customers
SELECT * FROM customers;

-- 2. Show all menu items
SELECT * FROM menu;

-- 3. Available tables
SELECT * FROM dining_tables
WHERE status='Available';

-- 4. Orders with customer names
SELECT
o.order_id,
c.customer_name,
t.table_number,
s.staff_name AS waiter,
o.order_status,
o.order_date
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
JOIN dining_tables t ON o.table_id=t.table_id
JOIN staff s ON o.waiter_id=s.staff_id;

-- 5. Full order details
SELECT
o.order_id,
c.customer_name,
m.item_name,
od.quantity,
od.subtotal
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu m ON od.menu_id=m.menu_id
ORDER BY o.order_id;

-- 6. Billing report
SELECT
b.bill_id,
c.customer_name,
b.total_amount,
b.payment_method,
b.payment_status
FROM billing b
JOIN orders o ON b.order_id=o.order_id
JOIN customers c ON o.customer_id=c.customer_id;

-- 7. Total revenue
SELECT SUM(total_amount) AS total_revenue
FROM billing
WHERE payment_status='Paid';

-- 8. Top selling menu items
SELECT
m.item_name,
SUM(od.quantity) AS total_sold
FROM order_details od
JOIN menu m ON od.menu_id=m.menu_id
GROUP BY m.item_name
ORDER BY total_sold DESC;

-- 9. Count orders by status
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;

-- 10. Highest priced menu item
SELECT * FROM menu
ORDER BY price DESC
LIMIT 1;
