CREATE DATABASE IF NOT EXISTS canteenbooking;
USE canteenbooking;

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    role ENUM('student','admin') DEFAULT 'student',
    department VARCHAR(50),
    year VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CANTEENS TABLE (Single simple canteen)
CREATE TABLE IF NOT EXISTS canteens (
    canteen_id INT AUTO_INCREMENT PRIMARY KEY,
    canteen_name VARCHAR(100),
    location VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active'
);

-- MENU ITEMS TABLE - SIMPLIFIED FOR SNACKS/FAST FOOD/JUICES ONLY
CREATE TABLE IF NOT EXISTS menu_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    canteen_id INT,
    item_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    image_url TEXT,
    rating DECIMAL(3,1) DEFAULT 4.0,
    distance_km DECIMAL(4,2) DEFAULT 0.10,
    availability BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (canteen_id) REFERENCES canteens(canteen_id)
);

-- CART TABLE
CREATE TABLE IF NOT EXISTS cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    item_id INT,
    quantity INT DEFAULT 1,
    price DECIMAL(10,2),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
    UNIQUE KEY unique_cart_item (user_id, item_id)
);

-- ORDERS TABLE
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    canteen_id INT,
    total_amount DECIMAL(10,2),
    status ENUM('Preparing','Ready','Collected') DEFAULT 'Preparing',
    payment_method VARCHAR(50) DEFAULT 'Card',
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (canteen_id) REFERENCES canteens(canteen_id)
);

-- ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- TOKENS TABLE (Unique code for student tracking)
CREATE TABLE IF NOT EXISTS tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    token_number INT UNIQUE,
    unique_code VARCHAR(50),
    status ENUM('Preparing','Ready','Collected') DEFAULT 'Preparing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(100),
    message TEXT,
    status ENUM('unread', 'read') DEFAULT 'unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- OFFERS TABLE (Simple offers for juices/snacks)
CREATE TABLE IF NOT EXISTS offers (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    discount_percentage INT,
    image_url TEXT,
    offer_message TEXT,
    valid_until DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- SAMPLE DATA SETUP

-- Canteens (Single simple canteen)
DELETE FROM canteens;
INSERT INTO canteens (canteen_id, canteen_name, location, status) VALUES 
(1, 'Quick Bites Canteen', 'Campus Food Court', 'active');

-- SIMPLIFIED MENU: Snacks, Fast Food, Juices ONLY
DELETE FROM menu_items;
INSERT INTO menu_items (canteen_id, item_name, category, price, image_url, rating, availability) VALUES 
-- Snacks
(1, 'Crispy Samosa', 'Snacks', 25.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400', 4.5, TRUE),
(1, 'Vada Pav', 'Snacks', 35.00, 'https://images.unsplash.com/photo-1621996346565-e3adc5a3a84e?w=400', 4.7, TRUE),
(1, 'Vegetable Sandwich', 'Snacks', 45.00, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400', 4.2, TRUE),
(1, 'Onion Bhaji', 'Snacks', 30.00, 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400', 4.4, TRUE),
(1, 'Cheese Balls', 'Snacks', 50.00, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', 4.6, TRUE),

-- Fast Food
(1, 'Veggie Burger', 'Fast Food', 70.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 4.3, TRUE),
(1, 'Chicken Burger', 'Fast Food', 85.00, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400', 4.5, TRUE),
(1, 'French Fries', 'Fast Food', 45.00, 'https://images.unsplash.com/photo-1621996346565-e3adc5a3a84e?w=400', 4.1, TRUE),
(1, 'Paneer Wrap', 'Fast Food', 65.00, 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400', 4.4, TRUE),
(1, 'Hot Dog', 'Fast Food', 55.00, 'https://images.unsplash.com/photo-1541599468178-a9eacc9258e4?w=400', 4.0, TRUE),

-- Juices
(1, 'Fresh Mango Juice', 'Juices', 40.00, 'https://images.unsplash.com/photo-1553530666-ba11a90654f3?w=400', 4.8, TRUE),
(1, 'Orange Juice', 'Juices', 35.00, 'https://images.unsplash.com/photo-1546782558-e4ee86a7990a?w=400', 4.6, TRUE),
(1, 'Lemon Juice', 'Juices', 25.00, 'https://images.unsplash.com/photo-1625682823295-2f48c503fffb?w=400', 4.3, TRUE);

-- Users
DELETE FROM users;
INSERT INTO users (user_id, name, email, password, role, department, year) VALUES 
(1, 'Admin User', 'admin@canteen.com', 'admin123', 'admin', 'Admin', 'N/A'),
(2, 'Test Student', 'student@test.com', 'student123', 'student', 'CSE', '3rd Year');

-- Sample Offers
DELETE FROM offers;
INSERT INTO offers (offer_id, title, discount_percentage, image_url, offer_message, valid_until, is_active) VALUES 
(1, 'Juice Combo', 20, 'https://images.unsplash.com/photo-1553530666-ba11a90654f3?w=400', '20% off on any 2 juices', '2025-12-31', TRUE),
(2, 'Snack Deal', 15, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400', '15% off snacks under ₹40', '2025-12-31', TRUE);

SELECT 'Simple Snacks Canteen DB ready! Items: Snacks/FastFood/Juices. Run: sqlite3 canteen.db < database.sql' as setup_complete;
