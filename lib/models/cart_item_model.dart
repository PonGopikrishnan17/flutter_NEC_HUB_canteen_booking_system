import '../models/food_item.dart';

class CartItemModel {
  final int cartId;
  final int userId;
  final int itemId;
  final int quantity;
  final double price;
  final DateTime addedAt;
  final String itemName;
  final String imageUrl;
  final double currentPrice;
  final String category;
  FoodItem? food;

  CartItemModel({
    required this.cartId,
    required this.userId,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.addedAt,
    required this.itemName,
    required this.imageUrl,
    required this.currentPrice,
    required this.category,
    this.food,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: json['cart_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      addedAt: DateTime.parse(json['added_at'] ?? DateTime.now().toIso8601String()),
      itemName: json['item_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      currentPrice: double.tryParse(json['current_price']?.toString() ?? '0') ?? 0.0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'user_id': userId,
      'item_id': itemId,
      'quantity': quantity,
      'price': price,
      'added_at': addedAt.toIso8601String(),
      'item_name': itemName,
      'image_url': imageUrl,
      'current_price': currentPrice,
      'category': category,
    };
  }
}
