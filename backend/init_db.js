const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, 'canteen.db');

if (fs.existsSync(dbPath)) {
    fs.unlinkSync(dbPath);
}

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Error opening database', err.message);
    } else {
        console.log('Connected to the SQLite database.');
        db.serialize(() => {
            // USERS
            db.run(`CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT UNIQUE,
                password TEXT,
                role TEXT DEFAULT 'student',
                department TEXT,
                year TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )`);
            
            // CANTEENS
            db.run(`CREATE TABLE IF NOT EXISTS canteens (
                canteen_id INTEGER PRIMARY KEY AUTOINCREMENT,
                canteen_name TEXT,
                location TEXT,
                status TEXT DEFAULT 'active'
            )`);

            // MENU ITEMS
            db.run(`CREATE TABLE IF NOT EXISTS menu_items (
                item_id INTEGER PRIMARY KEY AUTOINCREMENT,
                canteen_id INTEGER,
                item_name TEXT,
                category TEXT,
                price REAL,
                image_url TEXT,
                rating REAL DEFAULT 4.0,
                distance_km REAL DEFAULT 0.50,
                availability BOOLEAN DEFAULT 1,
                FOREIGN KEY (canteen_id) REFERENCES canteens(canteen_id)
            )`);

            // CART
            db.run(`CREATE TABLE IF NOT EXISTS cart (
                cart_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                item_id INTEGER,
                quantity INTEGER DEFAULT 1,
                price REAL,
                added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id),
                FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
                UNIQUE (user_id, item_id)
            )`);

            // ORDERS
            db.run(`CREATE TABLE IF NOT EXISTS orders (
                order_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                canteen_id INTEGER,
                total_amount REAL,
                status TEXT DEFAULT 'Preparing',
                order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                payment_method TEXT DEFAULT 'Card',
                FOREIGN KEY (user_id) REFERENCES users(user_id),
                FOREIGN KEY (canteen_id) REFERENCES canteens(canteen_id)
            )`);

            // ORDER ITEMS
            db.run(`CREATE TABLE IF NOT EXISTS order_items (
                order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER,
                item_id INTEGER,
                quantity INTEGER,
                price REAL,
                FOREIGN KEY (order_id) REFERENCES orders(order_id),
                FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
            )`);

            // TOKENS (Keep this for the member code / token)
            db.run(`CREATE TABLE IF NOT EXISTS tokens (
                token_id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER,
                token_number INTEGER UNIQUE,
                unique_code TEXT,
                status TEXT DEFAULT 'Preparing',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (order_id) REFERENCES orders(order_id)
            )`);

            // NOTIFICATIONS
            db.run(`CREATE TABLE IF NOT EXISTS notifications (
                notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                title TEXT,
                message TEXT,
                status TEXT DEFAULT 'unread',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )`);

            // OFFERS
            db.run(`CREATE TABLE IF NOT EXISTS offers (
                offer_id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT,
                discount_percentage INTEGER,
                image_url TEXT,
                offer_message TEXT,
                valid_until DATE,
                is_active BOOLEAN DEFAULT 1
            )`);

            // Data insertion
            const insertCanteen = db.prepare(`INSERT INTO canteens (canteen_name, location) VALUES (?,?)`);
            insertCanteen.run('Main Canteen', 'Main Building');
            insertCanteen.run('Snacks Corner', 'Block B');
            insertCanteen.finalize();

            // Categories: Snacks, Fast Food, Juices
            const insertMenu = db.prepare(`INSERT INTO menu_items (canteen_id, item_name, category, price, image_url, availability) VALUES (?,?,?,?,?,?)`);
            insertMenu.run(1, 'Samosa', 'Snacks', 15.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400', 1);
            insertMenu.run(1, 'Puff', 'Snacks', 20.00, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400', 1);
            insertMenu.run(1, 'Burger', 'Fast Food', 60.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 1);
            insertMenu.run(1, 'French Fries', 'Fast Food', 40.00, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=400', 1);
            insertMenu.run(1, 'Apple Juice', 'Juices', 40.00, 'https://images.unsplash.com/photo-1622597467836-f38ec3b5bb2f?w=400', 1);
            insertMenu.run(1, 'Orange Juice', 'Juices', 40.00, 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=400', 1);
            
            insertMenu.run(2, 'Sandwich', 'Snacks', 30.00, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400', 1);
            insertMenu.run(2, 'Pizza Slice', 'Fast Food', 70.00, 'https://plus.unsplash.com/premium_photo-1673439304183-8840bd0dc1bf?w=400', 1);
            insertMenu.run(2, 'Mango Juice', 'Juices', 45.00, 'https://images.unsplash.com/photo-1553530666-ba11a90654f3?w=400', 1);
            insertMenu.finalize();

            const insertUser = db.prepare(`INSERT INTO users (name, email, password, role, department, year) VALUES (?,?,?,?,?,?)`);
            insertUser.run('Admin', 'admin@canteen.com', 'admin123', 'admin', 'Admin', 'N/A');
            insertUser.run('Student', 'student@student.com', 'student123', 'student', 'CSE', '1st Year');
            insertUser.finalize();

            console.log('Database initialized successfully with schema and sample data!');
        });
    }
});
