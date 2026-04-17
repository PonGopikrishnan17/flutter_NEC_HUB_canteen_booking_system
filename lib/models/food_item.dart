class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final String distance;
  final bool isOffer;
  final String? discount;
  final String department;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.0,
    this.distance = '0.5 km',
    this.isOffer = false,
    this.discount,
    this.department = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'distance': distance,
    };
  }
}

/// Simple cart item wrapping a FoodItem with quantity (used in OrderModel)
class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'foodId': food.id,
      'foodName': food.name,
      'price': food.price,
      'quantity': quantity,
      'imageUrl': food.imageUrl,
      'category': food.category,
    };
  }
}
