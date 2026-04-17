# Canteen Booking App Project Report

## Title Page

**Project Title:** NEC HUB - Canteen Booking Application  
**Domain:** Mobile Application Development  
**Technology Stack:** Flutter, Dart, Provider, SharedPreferences, Node.js, Express.js, SQLite  
**Submitted By:** [Your Name]  
**Register Number:** [Your Register Number]  
**Department:** [Your Department]  
**Institution:** [Your College Name]  
**Academic Year:** [Academic Year]  

---

## Abstract

NEC HUB is a mobile-based canteen booking application designed to make campus food ordering faster, simpler, and more organized. Traditional canteen ordering often involves long queues, manual token handling, delayed communication, and difficulty tracking order status. This project solves these issues by providing a digital platform where students can browse food items, add items to a cart, place orders through a demo wallet, receive a pickup code, and track order progress.

The application also includes an admin dashboard for canteen staff to view orders, monitor revenue, and update order status. The frontend is developed using Flutter, which supports a smooth cross-platform mobile experience. The application state is managed using Provider and local persistence is handled using SharedPreferences. A backend service built with Node.js, Express.js, and SQLite is included for API-based user, menu, order, token, and offer management.

The final system improves the canteen ordering workflow by reducing manual effort, improving transparency for students, and providing better order control for administrators.

---

## Table of Contents

1. Introduction  
2. Existing System  
3. Proposed System  
4. Objectives  
5. Scope of the Project  
6. System Requirements  
7. Software Architecture  
8. Module Description  
9. Database Design  
10. Implementation Details  
11. Testing  
12. Advantages  
13. Limitations  
14. Future Enhancements  
15. Conclusion  
16. References  

---

## 1. Introduction

College canteens usually serve many students within a short break time. During peak hours, students may spend more time waiting in queues than eating. Manual ordering also creates difficulties for canteen staff because they must handle orders, payments, tokens, and delivery status at the same time.

The Canteen Booking App, named NEC HUB in this project, is developed to digitize this process. Students can log in, view food categories, search for items, add selected food to the cart, pay using a demo wallet, and receive a pickup code with a QR code. Admin users can monitor orders and update order status from pending to completed.

This project demonstrates how mobile technology can improve daily campus services through a simple, practical, and user-friendly application.

---

## 2. Existing System

In the existing manual canteen system, students usually visit the canteen, stand in a queue, select food, make payment, collect a token, and wait until the food is ready. This process has several drawbacks:

- Students waste time in long queues.
- Order status is not clearly visible to students.
- Staff members must manually manage payments and tokens.
- There is a chance of token loss or order confusion.
- Canteen staff have limited visibility of active and completed orders.
- Offers and menu updates are difficult to communicate quickly.

Because of these limitations, a digital system is useful for improving speed, accuracy, and convenience.

---

## 3. Proposed System

The proposed system is a mobile canteen booking application where students can order food before reaching the counter. The app provides menu browsing, cart management, wallet payment, token generation, order tracking, notifications, and profile management.

For administrators, the system provides a dashboard where all student orders can be viewed. Admins can filter orders by status and update the progress of each order. This makes the entire order lifecycle easier to manage.

The application is designed with two main user roles:

- **Student:** Can browse food items, add items to cart, place orders, view wallet transactions, and track order status.
- **Admin:** Can view orders, check active orders and completed revenue, filter orders, and update order status.

---

## 4. Objectives

The main objectives of this project are:

- To reduce waiting time in college canteens.
- To provide a simple mobile interface for ordering food.
- To allow students to track orders using token numbers and pickup codes.
- To provide a demo wallet for cashless payment simulation.
- To help canteen admins manage student orders efficiently.
- To maintain order history and transaction history.
- To improve communication through notifications and status updates.

---

## 5. Scope of the Project

The scope of the project includes the design and development of a mobile application for student canteen ordering. The app covers the complete flow from login to order confirmation.

Included features:

- Student and admin login.
- Food menu display with categories.
- Search and filtering.
- Cart management.
- Demo wallet balance and transaction history.
- Order placement.
- Token number and pickup code generation.
- QR code display for pickup verification.
- Student order tracking.
- Admin order dashboard.
- Order status update.
- Notification display.
- User profile screen.

The project is suitable for college-level canteen automation and can be extended into a production system with real payment gateway integration and live backend synchronization.

---

## 6. System Requirements

### 6.1 Hardware Requirements

- Processor: Intel i3 or above / Apple Silicon / equivalent
- RAM: Minimum 4 GB, recommended 8 GB
- Storage: Minimum 2 GB free space
- Device: Android emulator, iOS simulator, or physical mobile device

### 6.2 Software Requirements

- Operating System: Windows, macOS, or Linux
- Flutter SDK: Dart SDK 3.0 compatible
- IDE: Android Studio / Visual Studio Code
- Backend Runtime: Node.js
- Database: SQLite
- Browser or emulator for testing

### 6.3 Flutter Dependencies

The Flutter app uses the following major packages:

- `provider` for state management
- `shared_preferences` for local data storage
- `intl` for date and time formatting
- `qr_flutter` for QR code generation
- `http` for API communication support
- `firebase_core` and `cloud_firestore` are included for possible Firebase integration

### 6.4 Backend Dependencies

The backend uses:

- `express` for API routing
- `sqlite3` and `sqlite` for database operations
- `cors` for cross-origin access
- `body-parser` for JSON request handling

---

## 7. Software Architecture

The application follows a layered architecture:

### 7.1 Presentation Layer

This layer contains the Flutter screens and widgets. It is responsible for user interaction and visual display.

Main screens include:

- Splash screen
- Landing screen
- Login screen
- Home screen
- Food detail screen
- Cart screen
- Order confirmation screen
- My orders screen
- E-wallet screen
- Notifications screen
- Profile screen
- Admin dashboard screen

### 7.2 State Management Layer

The `AppState` service manages the main application data, including:

- Current logged-in user
- Food list
- Cart items
- Orders
- Wallet balance
- Wallet transactions
- Notifications
- Favorites

Provider is used to make this state available across the Flutter widget tree.

### 7.3 Model Layer

The model classes define structured data used in the app:

- `UserModel`
- `FoodItem`
- `CartItemModel`
- `OrderModel`

These models help keep the code organized and make JSON conversion easier.

### 7.4 Backend Layer

The Node.js backend exposes REST API endpoints for:

- Login
- Signup
- Users
- Menu items
- Canteens
- Offers
- Orders
- Order status updates
- Pickup code lookup

### 7.5 Database Layer

SQLite is used to store structured backend data such as users, menu items, orders, order items, tokens, and offers.

---

## 8. Module Description

### 8.1 Login Module

The login module allows users to continue as either Student or Admin. On first login, the app creates a local account automatically. Existing users must enter the correct password. Role validation prevents a student account from being used as an admin account and vice versa.

### 8.2 Home and Menu Module

The home screen displays food items, special offers, categories, and recommended items. Students can search for food and filter by categories such as Burger, Pizza, Rice, Noodles, Drinks, and Dessert. Each food item can be opened in detail before adding it to the cart.

### 8.3 Cart Module

The cart module allows students to:

- View selected food items
- Increase or decrease item quantity
- Remove items
- Clear the cart
- View total price
- Place the final order

### 8.4 Wallet Module

The e-wallet module simulates digital payment. Students start with a demo wallet balance and can top up the wallet inside the app. When an order is placed, the order amount is deducted from the wallet and a transaction entry is added.

### 8.5 Order Module

When a student places an order, the app generates:

- Order ID
- Token number
- Pickup code
- Payment reference
- Estimated waiting time
- Queue position

The order is saved locally and can be tracked from the My Orders screen.

### 8.6 QR Code Module

The order confirmation screen displays a QR code containing order information. This QR code can be used as a digital proof for pickup verification.

### 8.7 Notification Module

The notification module shows order updates, wallet updates, and offer-related messages. New notifications are counted and displayed through the notification icon badge.

### 8.8 Admin Dashboard Module

The admin dashboard provides canteen staff with an overview of:

- Completed revenue
- Active orders
- Total orders
- Order list
- Order filters
- Order status controls

Admins can update order status through the order lifecycle: Pending, Taken, Ready, Completed, or Cancelled.

### 8.9 Backend API Module

The backend server supports REST API operations. It includes schema creation, default data setup, user lookup, menu retrieval, order creation, token generation, and order status updates.

---

## 9. Database Design

The backend database contains the following main tables.

### 9.1 Users Table

Stores student and admin account details.

| Field | Description |
|---|---|
| user_id | Unique user ID |
| name | Name of the user |
| email | User email |
| password | User password |
| role | Student or admin |
| department | Department name |
| year | Academic year |
| student_id | Student identification number |
| created_at | Account creation date |

### 9.2 Canteens Table

Stores canteen information.

| Field | Description |
|---|---|
| canteen_id | Unique canteen ID |
| canteen_name | Name of the canteen |
| location | Canteen location |
| status | Active or inactive status |

### 9.3 Menu Items Table

Stores available food items.

| Field | Description |
|---|---|
| item_id | Unique item ID |
| canteen_id | Related canteen |
| item_name | Food item name |
| category | Food category |
| price | Item price |
| image_url | Image URL |
| rating | Item rating |
| distance_km | Display distance |
| availability | Availability status |

### 9.4 Orders Table

Stores order details.

| Field | Description |
|---|---|
| order_id | Unique order ID |
| user_id | Student who placed the order |
| canteen_id | Canteen receiving the order |
| total_amount | Total order amount |
| status | Current order status |
| order_time | Order date and time |
| payment_method | Payment method |
| payment_status | Paid or unpaid status |
| payment_reference | Payment reference number |
| updated_at | Last status update time |
| completed_at | Completion time |
| cancelled_at | Cancellation time |

### 9.5 Order Items Table

Stores the individual food items in each order.

| Field | Description |
|---|---|
| order_item_id | Unique order item ID |
| order_id | Related order |
| item_id | Ordered food item |
| quantity | Quantity ordered |
| price | Item price |

### 9.6 Tokens Table

Stores pickup token information.

| Field | Description |
|---|---|
| token_id | Unique token ID |
| order_id | Related order |
| token_number | Numeric token number |
| unique_code | Pickup code |
| status | Token status |
| created_at | Token creation time |

### 9.7 Offers Table

Stores canteen offers.

| Field | Description |
|---|---|
| offer_id | Unique offer ID |
| title | Offer title |
| discount_percentage | Discount value |
| image_url | Offer image |
| offer_message | Offer description |
| valid_until | Offer expiry date |
| is_active | Offer active status |

---

## 10. Implementation Details

### 10.1 Frontend Implementation

The frontend is implemented using Flutter. The main application starts from `main.dart`, where a `ChangeNotifierProvider` provides `AppState` to the complete app. The app uses Material 3 styling and a clean green-orange visual theme suitable for a food ordering system.

Navigation is handled using Flutter's `Navigator` and a bottom `NavigationBar`. Student users see Home, Orders, Message, E-Wallet, and Profile tabs. Admin users see Dashboard, Message, and Profile tabs.

### 10.2 State Persistence

SharedPreferences is used to store:

- Registered users
- Current user session
- Orders
- Wallet balance
- Wallet transactions
- Notifications
- Order sequence

This allows the app to retain important demo data even after restarting.

### 10.3 Order Placement Logic

When a student places an order, the app checks:

1. Cart should not be empty.
2. User should be logged in.
3. Wallet balance should be sufficient.

After validation, the wallet balance is reduced, a wallet transaction is created, an order is generated, the cart is cleared, and a notification is added.

### 10.4 Backend Implementation

The backend server is implemented using Express.js. It initializes the SQLite schema automatically and exposes endpoints under `/api`. The server supports creating orders, retrieving orders, updating order status, and finding orders by pickup code.

Important backend endpoints include:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/health` | Check backend health |
| POST | `/api/login` | User login |
| POST | `/api/signup` | User registration |
| GET | `/api/users` | Fetch users |
| GET | `/api/menu` | Fetch menu items |
| GET | `/api/canteens` | Fetch canteens |
| GET | `/api/offers` | Fetch active offers |
| POST | `/api/orders` | Create order |
| GET | `/api/orders` | Fetch all orders |
| GET | `/api/orders/user/:identifier` | Fetch user orders |
| GET | `/api/orders/code/:code` | Find order by pickup code |
| PUT | `/api/orders/:orderId/status` | Update order status |

---

## 11. Testing

Testing was performed manually by checking the main user workflows.

### 11.1 Test Cases

| Test Case | Input / Action | Expected Result | Status |
|---|---|---|---|
| Student login | Enter valid email and password | Student account is created or logged in | Passed |
| Admin login | Select Admin and enter credentials | Admin dashboard opens | Passed |
| Invalid email | Enter email without `@` | Validation message is shown | Passed |
| Add to cart | Select food and quantity | Item appears in cart | Passed |
| Update quantity | Increase or decrease quantity | Total price updates | Passed |
| Place order | Cart has items and wallet balance is enough | Order is created successfully | Passed |
| Insufficient balance | Cart total greater than wallet balance | Error message is shown | Passed |
| QR code display | Confirm order | QR code and pickup code are shown | Passed |
| Track order | Open Orders screen | Order progress is displayed | Passed |
| Admin filter | Select order status filter | Matching orders are displayed | Passed |
| Update order status | Admin changes order status | Student order status is updated | Passed |
| Wallet top up | Tap Top Up | Wallet balance increases | Passed |

### 11.2 Validation Testing

The login form validates empty fields, invalid email format, and short passwords. Order placement validates cart availability, login status, and wallet balance.

### 11.3 UI Testing

The app was checked across main screens to ensure navigation, buttons, lists, cards, and status labels display correctly.

---

## 12. Advantages

- Reduces canteen queue time.
- Provides simple food browsing and ordering.
- Gives students clear order status.
- Supports pickup verification through code and QR display.
- Simulates digital wallet payment.
- Helps admin users manage active and completed orders.
- Stores order and wallet history locally.
- Uses a scalable backend structure for future API integration.

---

## 13. Limitations

- The current Flutter app mainly uses local state for demo flow.
- Real payment gateway integration is not implemented.
- Real-time order synchronization is limited.
- User authentication is simplified for project demonstration.
- Push notifications are simulated inside the app.
- Production-level password hashing and security measures are not yet implemented.

---

## 14. Future Enhancements

The project can be improved with the following enhancements:

- Real payment gateway integration.
- Firebase or WebSocket-based real-time order updates.
- Push notifications for order status.
- Admin menu management from the app.
- Canteen staff QR scanner for pickup verification.
- Student feedback and rating system.
- Multiple canteen support.
- Analytics dashboard for sales and popular items.
- Secure authentication with password hashing and tokens.
- Cloud database deployment.

---

## 15. Conclusion

The NEC HUB Canteen Booking Application successfully demonstrates a digital solution for college canteen ordering. It provides an easy-to-use interface for students and a practical dashboard for admins. Students can browse food, manage their cart, make demo wallet payments, receive pickup codes, and track their orders. Admins can monitor orders, filter them, and update their progress.

The project reduces manual canteen workload and improves convenience for students. Although some features are implemented as a demo, the project has a strong foundation and can be extended into a full production-ready canteen management system.

---

## 16. References

- Flutter Documentation: https://docs.flutter.dev/
- Dart Documentation: https://dart.dev/guides
- Provider Package: https://pub.dev/packages/provider
- SharedPreferences Package: https://pub.dev/packages/shared_preferences
- QR Flutter Package: https://pub.dev/packages/qr_flutter
- Express.js Documentation: https://expressjs.com/
- SQLite Documentation: https://www.sqlite.org/docs.html

---

## Appendix A: Suggested Screenshots

Add screenshots of the following screens before final submission:

1. Landing screen
2. Login screen
3. Student home screen
4. Food detail screen
5. Cart screen
6. Order confirmation with QR code
7. My orders screen
8. E-wallet screen
9. Admin dashboard
10. Profile screen

## Appendix B: Suggested Viva Questions

1. What problem does the Canteen Booking App solve?
2. Why did you choose Flutter for this project?
3. What is Provider used for?
4. How is order status managed?
5. What is the purpose of the pickup code?
6. How does the wallet module work?
7. What tables are used in the database?
8. How can this project be improved in the future?
