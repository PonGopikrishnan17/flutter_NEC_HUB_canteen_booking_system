import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../services/app_state.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final total = widget.food.price * quantity;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    widget.food.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE9F3EC),
                      alignment: Alignment.center,
                      child: const Icon(Icons.fastfood_rounded,
                          size: 120, color: Color(0xFF1B8A5A)),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 18,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8F3),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(widget.food.name,
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900))),
                            Text('Rs.${widget.food.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B8A5A))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF28C28)),
                            const SizedBox(width: 4),
                            Text('${widget.food.rating}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_outlined,
                                color: Colors.black.withOpacity(.45)),
                            const SizedBox(width: 4),
                            Text(widget.food.distance),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(widget.food.description,
                            style: TextStyle(
                                color: Colors.black.withOpacity(.65),
                                height: 1.6)),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            _QtyButton(
                                icon: Icons.remove_rounded,
                                onTap: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Text('$quantity',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                            ),
                            _QtyButton(
                                icon: Icons.add_rounded,
                                onTap: () => setState(() => quantity++)),
                            const Spacer(),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B8A5A),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: () {
                                  context
                                      .read<AppState>()
                                      .addToCart(widget.food, quantity);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${widget.food.name} added to cart')),
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                    'Add to Cart  Rs.${total.toStringAsFixed(0)}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E6E8)),
        ),
        child: Icon(icon),
      ),
    );
  }
}
