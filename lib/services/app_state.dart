import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/food_item.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isNew;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isNew = true,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isNew,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isNew: isNew ?? this.isNew,
    );
  }
}

class WalletTransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;

  const WalletTransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
  });

  bool get isCredit => amount > 0;
}

class LoginResult {
  final bool isSuccess;
  final String message;

  const LoginResult({
    required this.isSuccess,
    required this.message,
  });
}

class OrderPlacementResult {
  final bool isSuccess;
  final String message;
  final OrderModel? order;

  const OrderPlacementResult({
    required this.isSuccess,
    required this.message,
    this.order,
  });
}

class AppState extends ChangeNotifier {
  static const _registeredUsersKey = 'nec_registered_users';
  static const _currentUserKey = 'nec_current_user';
  static const _ordersKey = 'nec_orders';
  static const _walletBalanceKey = 'nec_wallet_balance';
  static const _walletTransactionsKey = 'nec_wallet_transactions';
  static const _notificationsKey = 'nec_notifications';
  static const _orderSequenceKey = 'nec_order_sequence';

  final List<FoodItem> _foods = _buildFoods();
  final Set<String> _favorites = {};
  final List<CartItemModel> _cartItems = [];
  final List<OrderModel> _orders = [];
  final List<AppNotificationItem> _notifications = [
    AppNotificationItem(
      id: 'offer-1',
      title: 'New Offers',
      message: 'Flat 30% off on burger combos till 5 PM today.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AppNotificationItem(
      id: 'offer-2',
      title: 'Discount Guaranteed',
      message: 'Every wallet top up above Rs.300 unlocks a free drink coupon.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
  final Map<String, Map<String, dynamic>> _registeredUsers = {};

  UserModel? _currentUser;
  bool _initialized = false;
  double _walletBalance = 500;
  int _orderSequence = 1001;

  final List<WalletTransactionItem> _walletTransactions = [
    WalletTransactionItem(
      id: 'wallet-1',
      title: 'Wallet recharge',
      amount: 500,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  AppState() {
    _bootstrap();
  }

  bool get initialized => _initialized;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<FoodItem> get foods => List.unmodifiable(_foods);
  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);
  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<AppNotificationItem> get notifications =>
      List.unmodifiable(_notifications);
  List<WalletTransactionItem> get walletTransactions =>
      List.unmodifiable(_walletTransactions);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  double get walletBalance => _walletBalance;
  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get unreadNotificationCount =>
      _notifications.where((item) => item.isNew).length;
  double get cartTotal => _cartItems.fold(
      0, (sum, item) => sum + item.currentPrice * item.quantity);

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_registeredUsersKey);
    final currentUserJson = prefs.getString(_currentUserKey);

    if (usersJson != null && usersJson.isNotEmpty) {
      final decoded = jsonDecode(usersJson) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _registeredUsers[entry.key] =
            Map<String, dynamic>.from(entry.value as Map);
      }
    }

    if (currentUserJson != null && currentUserJson.isNotEmpty) {
      final current =
          Map<String, dynamic>.from(jsonDecode(currentUserJson) as Map);
      _currentUser = UserModel(
        id: current['id'] as String,
        email: current['email'] as String,
        studentId: current['studentId'] as String,
        fullName: current['fullName'] as String,
        department: current['department'] as String,
        year: current['year'] as String,
        role: (current['role'] as String) == 'admin'
            ? UserRole.admin
            : UserRole.student,
        createdAt: DateTime.parse(current['createdAt'] as String),
      );
    }

    _walletBalance = prefs.getDouble(_walletBalanceKey) ?? _walletBalance;
    _orderSequence = prefs.getInt(_orderSequenceKey) ?? _orderSequence;

    final walletTransactionsJson = prefs.getString(_walletTransactionsKey);
    if (walletTransactionsJson != null && walletTransactionsJson.isNotEmpty) {
      final decoded = jsonDecode(walletTransactionsJson) as List<dynamic>;
      _walletTransactions
        ..clear()
        ..addAll(decoded.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return WalletTransactionItem(
            id: map['id'] as String,
            title: map['title'] as String,
            amount: (map['amount'] as num).toDouble(),
            createdAt: DateTime.parse(map['createdAt'] as String),
          );
        }));
    }

    final notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson != null && notificationsJson.isNotEmpty) {
      final decoded = jsonDecode(notificationsJson) as List<dynamic>;
      _notifications
        ..clear()
        ..addAll(decoded.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return AppNotificationItem(
            id: map['id'] as String,
            title: map['title'] as String,
            message: map['message'] as String,
            createdAt: DateTime.parse(map['createdAt'] as String),
            isNew: map['isNew'] as bool? ?? true,
          );
        }));
    }

    final ordersJson = prefs.getString(_ordersKey);
    if (ordersJson != null && ordersJson.isNotEmpty) {
      final decoded = jsonDecode(ordersJson) as List<dynamic>;
      _orders
        ..clear()
        ..addAll(decoded.map((item) {
          return OrderModel.fromJson(Map<String, dynamic>.from(item as Map));
        }));
    }

    _initialized = true;
    notifyListeners();
  }

  Future<LoginResult> login({
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return const LoginResult(
          isSuccess: false, message: 'Enter a valid email address.');
    }
    if (trimmedPassword.length < 6) {
      return const LoginResult(
          isSuccess: false, message: 'Password must be at least 6 characters.');
    }

    final role = isAdmin ? UserRole.admin : UserRole.student;
    final existing = _registeredUsers[trimmedEmail];

    if (existing == null) {
      final generatedName = _nameFromEmail(trimmedEmail, isAdmin);
      final generatedId = isAdmin
          ? 'ADM-${DateTime.now().millisecondsSinceEpoch % 10000}'
          : 'NEC${DateTime.now().millisecondsSinceEpoch % 100000}';
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: trimmedEmail,
        studentId: generatedId,
        fullName: generatedName,
        department: isAdmin ? 'Administration' : 'CSE',
        year: isAdmin ? 'Staff' : 'III Year',
        role: role,
        createdAt: DateTime.now(),
      );
      _registeredUsers[trimmedEmail] = {
        'password': trimmedPassword,
        'user': _userToJson(user),
      };
      _currentUser = user;
      await _persistUsers();
      await _persistCurrentUser();
      notifyListeners();
      return LoginResult(
        isSuccess: true,
        message: 'Account created for ${user.fullName}. Welcome to NEC HUB!',
      );
    }

    if ((existing['password'] as String) != trimmedPassword) {
      return const LoginResult(
          isSuccess: false, message: 'Incorrect password. Try again.');
    }

    final storedUser = Map<String, dynamic>.from(existing['user'] as Map);
    final storedRole = (storedUser['role'] as String) == 'admin'
        ? UserRole.admin
        : UserRole.student;
    if (storedRole != role) {
      return LoginResult(
        isSuccess: false,
        message:
            'This account is registered as ${storedRole == UserRole.admin ? 'Admin' : 'Student'}.',
      );
    }

    _currentUser = UserModel(
      id: storedUser['id'] as String,
      email: storedUser['email'] as String,
      studentId: storedUser['studentId'] as String,
      fullName: storedUser['fullName'] as String,
      department: storedUser['department'] as String,
      year: storedUser['year'] as String,
      role: storedRole,
      createdAt: DateTime.parse(storedUser['createdAt'] as String),
    );
    await _persistCurrentUser();
    notifyListeners();
    return LoginResult(
        isSuccess: true, message: 'Welcome back, ${_currentUser!.fullName}!');
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    notifyListeners();
  }

  List<FoodItem> filteredFoods({
    required String category,
    required String query,
  }) {
    final lowerQuery = query.toLowerCase().trim();
    return _foods.where((food) {
      final categoryMatch = category == 'All' || food.category == category;
      final queryMatch = lowerQuery.isEmpty ||
          food.name.toLowerCase().contains(lowerQuery) ||
          food.description.toLowerCase().contains(lowerQuery) ||
          food.category.toLowerCase().contains(lowerQuery);
      return categoryMatch && queryMatch;
    }).toList();
  }

  List<FoodItem> get specialOffers =>
      _foods.where((food) => food.isOffer).toList();

  void toggleFavorite(String foodId) {
    if (_favorites.contains(foodId)) {
      _favorites.remove(foodId);
    } else {
      _favorites.add(foodId);
    }
    notifyListeners();
  }

  bool isFavorite(String foodId) => _favorites.contains(foodId);

  void addToCart(FoodItem food, int quantity) {
    final index =
        _cartItems.indexWhere((item) => item.itemId.toString() == food.id);
    if (index >= 0) {
      final existing = _cartItems[index];
      _cartItems[index] = CartItemModel(
        cartId: existing.cartId,
        userId: 0,
        itemId: existing.itemId,
        quantity: existing.quantity + quantity,
        price: existing.price,
        addedAt: existing.addedAt,
        itemName: existing.itemName,
        imageUrl: existing.imageUrl,
        currentPrice: existing.currentPrice,
        category: existing.category,
      );
    } else {
      _cartItems.add(
        CartItemModel(
          cartId: DateTime.now().millisecondsSinceEpoch,
          userId: 0,
          itemId: int.tryParse(food.id) ?? _cartItems.length + 1,
          quantity: quantity,
          price: food.price,
          addedAt: DateTime.now(),
          itemName: food.name,
          imageUrl: food.imageUrl,
          currentPrice: food.price,
          category: food.category,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartQuantity(int cartId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.cartId == cartId);
    if (index == -1) return;
    if (quantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      final existing = _cartItems[index];
      _cartItems[index] = CartItemModel(
        cartId: existing.cartId,
        userId: existing.userId,
        itemId: existing.itemId,
        quantity: quantity,
        price: existing.price,
        addedAt: existing.addedAt,
        itemName: existing.itemName,
        imageUrl: existing.imageUrl,
        currentPrice: existing.currentPrice,
        category: existing.category,
      );
    }
    notifyListeners();
  }

  void removeCartItem(int cartId) {
    _cartItems.removeWhere((item) => item.cartId == cartId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<OrderPlacementResult> placeOrder() async {
    if (_cartItems.isEmpty) {
      return const OrderPlacementResult(
        isSuccess: false,
        message: 'Your cart is empty.',
      );
    }
    if (_currentUser == null) {
      return const OrderPlacementResult(
        isSuccess: false,
        message: 'Please log in first.',
      );
    }
    if (_walletBalance < cartTotal) {
      return const OrderPlacementResult(
        isSuccess: false,
        message: 'Insufficient wallet balance. Top up to continue.',
      );
    }

    _walletBalance -= cartTotal;
    final paymentReference = _generatePaymentReference();
    _walletTransactions.insert(
      0,
      WalletTransactionItem(
        id: paymentReference,
        title: 'Demo money sent to Main Canteen',
        amount: -cartTotal,
        createdAt: DateTime.now(),
      ),
    );

    final order = OrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      orderId: 'NEC${_orderSequence++}',
      tokenNumber: _nextTokenNumber(),
      userId: _currentUser!.id,
      userName: _currentUser!.fullName,
      studentId: _currentUser!.studentId,
      department: _currentUser!.department,
      canteenDepartment: 'Main Canteen',
      items: List<CartItemModel>.from(_cartItems),
      totalPrice: cartTotal,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      paymentMethod: 'Demo Wallet',
      paymentStatus: 'Paid',
      paymentReference: paymentReference,
      pickupCode: _generatePickupCode(),
      estimatedWaitTime: 18,
      queuePosition:
          _orders.where((order) => !_isClosedStatus(order.status)).length + 1,
    );

    _orders.insert(0, order);
    _cartItems.clear();
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order Successful',
        message:
            'Your order ${order.orderId} was placed. Pickup code: ${order.pickupCode}.',
        createdAt: DateTime.now(),
      ),
    );
    await _persistOrderState();
    notifyListeners();
    return OrderPlacementResult(
      isSuccess: true,
      message: 'Order placed successfully. Demo payment completed.',
      order: order,
    );
  }

  Future<void> markNotificationsSeen() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isNew: false);
    }
    await _persistNotifications();
    notifyListeners();
  }

  Future<void> topUpWallet(double amount) async {
    _walletBalance += amount;
    _walletTransactions.insert(
      0,
      WalletTransactionItem(
        id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Wallet recharge',
        amount: amount,
        createdAt: DateTime.now(),
      ),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Wallet Updated',
        message: 'Rs.${amount.toStringAsFixed(0)} added to your wallet.',
        createdAt: DateTime.now(),
      ),
    );
    await _persistWalletState();
    await _persistNotifications();
    notifyListeners();
  }

  void scanWallet() {
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Scan Ready',
        message: 'Campus scan mode opened for quick pickup payments.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final existing = _orders[index];
    _orders[index] = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      completedAt: status == OrderStatus.completed ? DateTime.now() : null,
      cancelledAt: status == OrderStatus.cancelled ? DateTime.now() : null,
      estimatedWaitTime: _etaForStatus(status),
    );
    _recalculateQueuePositions();
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order ${status.displayName}',
        message: _statusMessage(_orders[index]),
        createdAt: DateTime.now(),
      ),
    );
    await _persistOrderState();
    notifyListeners();
  }

  double get dailyRevenue => _orders
      .where((order) => order.status == OrderStatus.completed)
      .fold(0.0, (sum, order) => sum + order.totalPrice);

  List<OrderModel> get adminOrders {
    final sorted = List<OrderModel>.from(_orders);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  int get activeOrderCount =>
      _orders.where((order) => !_isClosedStatus(order.status)).length;

  String _nameFromEmail(String email, bool isAdmin) {
    final base =
        email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (base.isEmpty) return isAdmin ? 'NEC Admin' : 'NEC Student';
    return base
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredUsersKey, jsonEncode(_registeredUsers));
  }

  Future<void> _persistCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser == null) {
      await prefs.remove(_currentUserKey);
      return;
    }
    await prefs.setString(
        _currentUserKey, jsonEncode(_userToJson(_currentUser!)));
  }

  Future<void> _persistOrderState() async {
    await _persistOrders();
    await _persistWalletState();
    await _persistNotifications();
  }

  Future<void> _persistOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey,
      jsonEncode(_orders.map(_orderToJson).toList()),
    );
    await prefs.setInt(_orderSequenceKey, _orderSequence);
  }

  Future<void> _persistWalletState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_walletBalanceKey, _walletBalance);
    await prefs.setString(
      _walletTransactionsKey,
      jsonEncode(_walletTransactions.map(_walletTransactionToJson).toList()),
    );
  }

  Future<void> _persistNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey,
      jsonEncode(_notifications.map(_notificationToJson).toList()),
    );
  }

  Map<String, dynamic> _walletTransactionToJson(WalletTransactionItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'amount': item.amount,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _notificationToJson(AppNotificationItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'message': item.message,
      'createdAt': item.createdAt.toIso8601String(),
      'isNew': item.isNew,
    };
  }

  Map<String, dynamic> _orderToJson(OrderModel order) {
    return {
      'id': order.id,
      'orderId': order.orderId,
      'tokenNumber': order.tokenNumber,
      'userId': order.userId,
      'userName': order.userName,
      'studentId': order.studentId,
      'department': order.department,
      'canteenDepartment': order.canteenDepartment,
      'items': order.items.map((item) => item.toJson()).toList(),
      'totalPrice': order.totalPrice,
      'status': order.status.name,
      'createdAt': order.createdAt.toIso8601String(),
      'updatedAt': order.updatedAt?.toIso8601String(),
      'completedAt': order.completedAt?.toIso8601String(),
      'cancelledAt': order.cancelledAt?.toIso8601String(),
      'paymentMethod': order.paymentMethod,
      'paymentStatus': order.paymentStatus,
      'paymentReference': order.paymentReference,
      'pickupCode': order.pickupCode,
      'estimatedWaitTime': order.estimatedWaitTime,
      'queuePosition': order.queuePosition,
    };
  }

  int _nextTokenNumber() {
    if (_orders.isEmpty) return 101;
    return _orders.map((order) => order.tokenNumber).reduce(max) + 1;
  }

  String _generatePaymentReference() {
    return 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  }

  String _generatePickupCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    const prefix = 'BU';
    final middle = List.generate(3, (_) => random.nextInt(10)).join();
    final suffix = chars[random.nextInt(chars.length)];
    return '$prefix$middle$suffix';
  }

  int _etaForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 18;
      case OrderStatus.accepted:
        return 10;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return 0;
    }
  }

  bool _isClosedStatus(OrderStatus status) {
    return status == OrderStatus.completed || status == OrderStatus.cancelled;
  }

  void _recalculateQueuePositions() {
    final activeOrders = _orders
        .where((order) => !_isClosedStatus(order.status))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (var i = 0; i < _orders.length; i++) {
      final current = _orders[i];
      final activeIndex =
          activeOrders.indexWhere((order) => order.id == current.id);
      _orders[i] = current.copyWith(
        queuePosition: activeIndex == -1 ? 0 : activeIndex + 1,
      );
    }
  }

  String _statusMessage(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return '${order.orderId} is waiting for admin confirmation.';
      case OrderStatus.accepted:
        return '${order.orderId} was taken by the canteen. Preparing now.';
      case OrderStatus.ready:
        return '${order.orderId} is ready for pickup. Show ${order.pickupCode} at the counter.';
      case OrderStatus.completed:
        return '${order.orderId} was completed and handed over offline.';
      case OrderStatus.cancelled:
        return '${order.orderId} was cancelled by the admin.';
    }
  }

  Map<String, dynamic> _userToJson(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'studentId': user.studentId,
      'fullName': user.fullName,
      'department': user.department,
      'year': user.year,
      'role': user.role == UserRole.admin ? 'admin' : 'student',
      'createdAt': user.createdAt.toIso8601String(),
    };
  }

  static List<FoodItem> _buildFoods() {
    return [
      FoodItem(
        id: '1',
        name: 'Campus Zinger Burger',
        description:
            'Crispy chicken patty, lettuce, campus sauce, and cheddar in a toasted bun.',
        price: 129,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900',
        category: 'Burger',
        rating: 4.7,
        distance: '110 m',
        isOffer: true,
        discount: '20% OFF',
      ),
      FoodItem(
        id: '2',
        name: 'Margherita Pizza',
        description:
            'Stone-baked pizza loaded with mozzarella, basil, and tomato sauce.',
        price: 189,
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=900',
        category: 'Pizza',
        rating: 4.5,
        distance: '140 m',
        isOffer: true,
        discount: '15% OFF',
      ),
      FoodItem(
        id: '3',
        name: 'Veg Hakka Noodles',
        description:
            'Wok-tossed noodles with crunchy vegetables and spicy college-style seasoning.',
        price: 99,
        imageUrl:
            'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=900',
        category: 'Noodles',
        rating: 4.4,
        distance: '90 m',
      ),
      FoodItem(
        id: '4',
        name: 'Paneer Rice Bowl',
        description:
            'Jeera rice topped with paneer tikka, grilled peppers, and mint dip.',
        price: 139,
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=900',
        category: 'Rice',
        rating: 4.6,
        distance: '100 m',
      ),
      FoodItem(
        id: '5',
        name: 'Cold Coffee',
        description:
            'Creamy chilled coffee topped with froth for a perfect between-class boost.',
        price: 59,
        imageUrl:
            'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=900',
        category: 'Drinks',
        rating: 4.8,
        distance: '70 m',
        isOffer: true,
        discount: 'BUY 1 GET 1',
      ),
      FoodItem(
        id: '6',
        name: 'Veg Loaded Wrap',
        description:
            'Soft tortilla wrapped with crunchy veggies, fries, and peri-peri mayo.',
        price: 89,
        imageUrl:
            'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=900',
        category: 'Wraps',
        rating: 4.3,
        distance: '120 m',
      ),
      FoodItem(
        id: '7',
        name: 'Chocolate Brownie Shake',
        description: 'Rich brownie blended into a chilled chocolate shake.',
        price: 79,
        imageUrl:
            'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=900',
        category: 'Dessert',
        rating: 4.9,
        distance: '150 m',
      ),
      FoodItem(
        id: '8',
        name: 'Spicy Chicken Fried Rice',
        description:
            'Fast, filling fried rice tossed with chicken chunks and spring onion.',
        price: 149,
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=900',
        category: 'Rice',
        rating: 4.5,
        distance: '95 m',
      ),
    ];
  }
}
