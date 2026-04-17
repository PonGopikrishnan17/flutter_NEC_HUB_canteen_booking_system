const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = 8080;
const dbPath = path.join(__dirname, 'canteen.db');
const db = new sqlite3.Database(dbPath);

app.use(cors({ origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'] }));
app.use(bodyParser.json());

function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function onRun(err) {
      if (err) {
        reject(err);
        return;
      }
      resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
}

function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(row);
    });
  });
}

function all(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(rows);
    });
  });
}

async function addColumnIfMissing(table, column, definition) {
  const columns = await all(`PRAGMA table_info(${table})`);
  const exists = columns.some((item) => item.name === column);
  if (!exists) {
    await run(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`);
  }
}

function normalizeStatus(status) {
  const value = String(status || 'Pending').toLowerCase();
  if (value === 'preparing' || value === 'taken' || value === 'accepted') {
    return 'Taken';
  }
  if (value === 'ready') {
    return 'Ready';
  }
  if (value === 'collected' || value === 'completed' || value === 'given') {
    return 'Completed';
  }
  if (value === 'cancelled' || value === 'canceled') {
    return 'Cancelled';
  }
  return 'Pending';
}

function statusForToken(status) {
  switch (normalizeStatus(status)) {
    case 'Taken':
      return 'Preparing';
    case 'Ready':
      return 'Ready';
    case 'Completed':
      return 'Collected';
    case 'Cancelled':
      return 'Cancelled';
    default:
      return 'Preparing';
  }
}

function buildPickupCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const middle = `${Math.floor(100 + Math.random() * 900)}`;
  return `BU${middle}${chars[Math.floor(Math.random() * chars.length)]}`;
}

async function ensureSchema() {
  await run(`CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT UNIQUE,
    password TEXT,
    role TEXT DEFAULT 'student',
    department TEXT,
    year TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  await run(`CREATE TABLE IF NOT EXISTS canteens (
    canteen_id INTEGER PRIMARY KEY AUTOINCREMENT,
    canteen_name TEXT,
    location TEXT,
    status TEXT DEFAULT 'active'
  )`);

  await run(`CREATE TABLE IF NOT EXISTS menu_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    canteen_id INTEGER,
    item_name TEXT,
    category TEXT,
    price REAL,
    image_url TEXT,
    rating REAL DEFAULT 4.0,
    distance_km REAL DEFAULT 0.50,
    availability BOOLEAN DEFAULT 1
  )`);

  await run(`CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    canteen_id INTEGER,
    total_amount REAL,
    status TEXT DEFAULT 'Pending',
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method TEXT DEFAULT 'Demo Wallet'
  )`);

  await run(`CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    item_id INTEGER,
    quantity INTEGER,
    price REAL
  )`);

  await run(`CREATE TABLE IF NOT EXISTS tokens (
    token_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    token_number INTEGER UNIQUE,
    unique_code TEXT,
    status TEXT DEFAULT 'Preparing',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  await run(`CREATE TABLE IF NOT EXISTS offers (
    offer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    discount_percentage INTEGER,
    image_url TEXT,
    offer_message TEXT,
    valid_until DATE,
    is_active BOOLEAN DEFAULT 1
  )`);

  await addColumnIfMissing('users', 'student_id', 'TEXT');
  await addColumnIfMissing('orders', 'payment_status', "TEXT DEFAULT 'Paid'");
  await addColumnIfMissing('orders', 'payment_reference', 'TEXT');
  await addColumnIfMissing('orders', 'updated_at', 'DATETIME');
  await addColumnIfMissing('orders', 'completed_at', 'DATETIME');
  await addColumnIfMissing('orders', 'cancelled_at', 'DATETIME');

  const canteen = await get('SELECT canteen_id FROM canteens LIMIT 1');
  if (!canteen) {
    await run(
      'INSERT INTO canteens (canteen_name, location, status) VALUES (?, ?, ?)',
      ['Main Canteen', 'Campus Food Court', 'active'],
    );
  }

  const offers = await get('SELECT offer_id FROM offers LIMIT 1');
  if (!offers) {
    await run(
      'INSERT INTO offers (title, discount_percentage, image_url, offer_message, valid_until, is_active) VALUES (?, ?, ?, ?, ?, ?)',
      [
        'Juice Combo',
        20,
        'https://images.unsplash.com/photo-1553530666-ba11a90654f3?w=400',
        '20% off on any 2 juices',
        '2027-12-31',
        1,
      ],
    );
  }
}

async function findOrCreateUser({ name, email, department, year, role = 'student', studentId }) {
  let user = await get('SELECT * FROM users WHERE LOWER(email) = LOWER(?)', [email]);
  if (user) {
    await run(
      `UPDATE users
       SET name = ?, department = ?, year = ?, role = ?, student_id = COALESCE(student_id, ?)
       WHERE user_id = ?`,
      [name, department, year, role, studentId, user.user_id],
    );
    user = await get('SELECT * FROM users WHERE user_id = ?', [user.user_id]);
    return user;
  }

  const result = await run(
    `INSERT INTO users (name, email, password, role, department, year, student_id)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [name, email, 'demo123', role, department, year, studentId],
  );
  return get('SELECT * FROM users WHERE user_id = ?', [result.lastID]);
}

async function nextTokenNumber() {
  const row = await get('SELECT MAX(token_number) AS maxToken FROM tokens');
  return (row?.maxToken || 100) + 1;
}

async function fetchOrderItems(orderId) {
  return all(
    `SELECT oi.order_item_id, oi.item_id, oi.quantity, oi.price,
            COALESCE(mi.item_name, 'Food Item') AS item_name,
            COALESCE(mi.image_url, '') AS image_url
     FROM order_items oi
     LEFT JOIN menu_items mi ON mi.item_id = oi.item_id
     WHERE oi.order_id = ?
     ORDER BY oi.order_item_id ASC`,
    [orderId],
  );
}

async function fetchOrderRow(orderId) {
  const row = await get(
    `SELECT o.order_id, o.total_amount, o.status, o.payment_method, o.payment_status,
            o.payment_reference, o.order_time, o.updated_at, o.completed_at, o.cancelled_at,
            u.user_id, u.name AS user_name, u.email AS user_email, u.student_id, u.department, u.year,
            c.canteen_name,
            t.token_number, t.unique_code
     FROM orders o
     LEFT JOIN users u ON u.user_id = o.user_id
     LEFT JOIN canteens c ON c.canteen_id = o.canteen_id
     LEFT JOIN tokens t ON t.order_id = o.order_id
     WHERE o.order_id = ?`,
    [orderId],
  );

  if (!row) {
    return null;
  }

  const items = await fetchOrderItems(orderId);
  return {
    id: String(row.order_id),
    orderId: `ORD-${row.order_id}`,
    order_id: row.order_id,
    tokenNumber: row.token_number || 0,
    token_number: row.token_number || 0,
    userId: String(row.user_id || ''),
    user_id: row.user_id,
    userName: row.user_name || 'Student',
    user_name: row.user_name || 'Student',
    userEmail: row.user_email || '',
    studentId: row.student_id || '',
    student_id: row.student_id || '',
    department: row.department || '',
    canteenDepartment: row.canteen_name || 'Main Canteen',
    canteen_department: row.canteen_name || 'Main Canteen',
    items: items.map((item) => ({
      cartId: item.order_item_id,
      cart_id: item.order_item_id,
      userId: row.user_id,
      user_id: row.user_id,
      itemId: item.item_id,
      item_id: item.item_id,
      quantity: item.quantity,
      price: item.price,
      addedAt: row.order_time,
      added_at: row.order_time,
      itemName: item.item_name,
      item_name: item.item_name,
      imageUrl: item.image_url,
      image_url: item.image_url,
      currentPrice: item.price,
      current_price: item.price,
      category: '',
    })),
    totalPrice: Number(row.total_amount || 0),
    total_price: Number(row.total_amount || 0),
    status: normalizeStatus(row.status),
    createdAt: row.order_time,
    created_at: row.order_time,
    updatedAt: row.updated_at,
    updated_at: row.updated_at,
    completedAt: row.completed_at,
    completed_at: row.completed_at,
    cancelledAt: row.cancelled_at,
    cancelled_at: row.cancelled_at,
    paymentMethod: row.payment_method || 'Demo Wallet',
    payment_method: row.payment_method || 'Demo Wallet',
    paymentStatus: row.payment_status || 'Paid',
    payment_status: row.payment_status || 'Paid',
    paymentReference: row.payment_reference || '',
    payment_reference: row.payment_reference || '',
    pickupCode: row.unique_code || '',
    pickup_code: row.unique_code || '',
  };
}

async function fetchOrders(whereSql = '', params = []) {
  const rows = await all(
    `SELECT o.order_id
     FROM orders o
     LEFT JOIN users u ON u.user_id = o.user_id
     ${whereSql}
     ORDER BY o.order_time DESC`,
    params,
  );
  const orders = [];
  for (const row of rows) {
    const order = await fetchOrderRow(row.order_id);
    if (order) {
      orders.push(order);
    }
  }
  return orders;
}

app.get('/api/health', async (req, res) => {
  try {
    await get('SELECT 1 AS ok');
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await get(
      'SELECT user_id, name, email, role, department, year, student_id FROM users WHERE LOWER(email) = LOWER(?) AND password = ?',
      [email, password],
    );
    if (!user) {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
      return;
    }
    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/signup', async (req, res) => {
  try {
    const { name, email, password, department, year, role = 'student', studentId } = req.body;
    const existing = await get('SELECT user_id FROM users WHERE LOWER(email) = LOWER(?)', [email]);
    if (existing) {
      res.status(409).json({ success: false, message: 'User already exists' });
      return;
    }
    const result = await run(
      'INSERT INTO users (name, email, password, role, department, year, student_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, email, password, role, department, year, studentId || null],
    );
    const user = await get(
      'SELECT user_id, name, email, role, department, year, student_id FROM users WHERE user_id = ?',
      [result.lastID],
    );
    res.status(201).json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/users', async (req, res) => {
  try {
    const users = await all(
      'SELECT user_id, name, email, role, department, year, student_id FROM users ORDER BY created_at DESC',
    );
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/menu', async (req, res) => {
  try {
    const items = await all(
      'SELECT * FROM menu_items WHERE availability = 1 ORDER BY item_id ASC',
    );
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/menu/canteen/:canteenId', async (req, res) => {
  try {
    const items = await all(
      'SELECT * FROM menu_items WHERE availability = 1 AND canteen_id = ? ORDER BY item_id ASC',
      [req.params.canteenId],
    );
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/canteens', async (req, res) => {
  try {
    const canteens = await all('SELECT * FROM canteens ORDER BY canteen_id ASC');
    res.json(canteens);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/offers', async (req, res) => {
  try {
    const offers = await all('SELECT * FROM offers WHERE is_active = 1 ORDER BY offer_id DESC');
    res.json(offers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/orders', async (req, res) => {
  try {
    const {
      user_name,
      user_email,
      student_id,
      department,
      year = '',
      canteen_id = 1,
      total_amount,
      payment_method = 'Demo Wallet',
      payment_status = 'Paid',
      payment_reference,
      pickup_code,
      items = [],
    } = req.body;

    if (!user_name || !user_email || !student_id || !total_amount || items.length === 0) {
      res.status(400).json({ error: 'Missing required order fields' });
      return;
    }

    const user = await findOrCreateUser({
      name: user_name,
      email: user_email,
      department,
      year,
      studentId: student_id,
    });

    const orderResult = await run(
      `INSERT INTO orders
       (user_id, canteen_id, total_amount, status, payment_method, payment_status, payment_reference, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`,
      [
        user.user_id,
        canteen_id,
        total_amount,
        'Pending',
        payment_method,
        payment_status,
        payment_reference || '',
      ],
    );

    for (const item of items) {
      await run(
        'INSERT INTO order_items (order_id, item_id, quantity, price) VALUES (?, ?, ?, ?)',
        [
          orderResult.lastID,
          item.item_id || item.itemId || null,
          item.quantity || 1,
          item.price || item.currentPrice || 0,
        ],
      );
    }

    const tokenNumber = await nextTokenNumber();
    await run(
      'INSERT INTO tokens (order_id, token_number, unique_code, status) VALUES (?, ?, ?, ?)',
      [
        orderResult.lastID,
        tokenNumber,
        (pickup_code || buildPickupCode()).toUpperCase(),
        'Preparing',
      ],
    );

    const order = await fetchOrderRow(orderResult.lastID);
    res.status(201).json({ success: true, order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/orders', async (req, res) => {
  try {
    const orders = await fetchOrders();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/orders/user/:identifier', async (req, res) => {
  try {
    const identifier = decodeURIComponent(req.params.identifier);
    const orders = await fetchOrders(
      'WHERE LOWER(u.email) = LOWER(?) OR CAST(u.user_id AS TEXT) = ? OR u.student_id = ?',
      [identifier, identifier, identifier],
    );
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/orders/code/:code', async (req, res) => {
  try {
    const code = req.params.code.toUpperCase();
    const row = await get('SELECT order_id FROM tokens WHERE UPPER(unique_code) = ?', [code]);
    if (!row) {
      res.status(404).json({ message: 'Order code not found' });
      return;
    }
    const order = await fetchOrderRow(row.order_id);
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/orders/:orderId/status', async (req, res) => {
  try {
    const { status } = req.body;
    const orderId = Number(req.params.orderId);
    const normalized = normalizeStatus(status);
    const completedAt = normalized === 'Completed' ? 'CURRENT_TIMESTAMP' : 'NULL';
    const cancelledAt = normalized === 'Cancelled' ? 'CURRENT_TIMESTAMP' : 'NULL';

    await run(
      `UPDATE orders
       SET status = ?, updated_at = CURRENT_TIMESTAMP,
           completed_at = ${completedAt},
           cancelled_at = ${cancelledAt}
       WHERE order_id = ?`,
      [normalized, orderId],
    );

    await run('UPDATE tokens SET status = ? WHERE order_id = ?', [
      statusForToken(normalized),
      orderId,
    ]);

    const order = await fetchOrderRow(orderId);
    res.json({ success: true, order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

ensureSchema()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log('Ready for testing: http://localhost:8080/api/health');
    });
  })
  .catch((error) => {
    console.error('Failed to initialize database schema:', error.message);
    process.exit(1);
  });
