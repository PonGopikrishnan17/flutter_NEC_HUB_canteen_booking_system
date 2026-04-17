import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../services/app_state.dart';
import 'cart_screen.dart';
import 'food_detail_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedCanteen;

  const HomeScreen({super.key, this.selectedCanteen});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final _chips = const ['All', 'Burger', 'Pizza', 'Rice', 'Noodles', 'Drinks'];
  final _categories = const [
    ('Burger', Icons.lunch_dining_rounded),
    ('Pizza', Icons.local_pizza_rounded),
    ('Noodles', Icons.ramen_dining_rounded),
    ('Drinks', Icons.local_drink_rounded),
    ('Rice', Icons.rice_bowl_rounded),
    ('Dessert', Icons.icecream_rounded),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final foods = appState.filteredFoods(
      category: _selectedFilter,
      query: _searchController.text,
    );
    final userName = appState.currentUser?.fullName ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hi, $userName',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(.55))),
                              const SizedBox(height: 6),
                              const Text('Deliver to Main Canteen',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        _IconBadge(
                          icon: Icons.notifications_none_rounded,
                          count: appState.unreadNotificationCount,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationsScreen()));
                          },
                        ),
                        const SizedBox(width: 10),
                        _IconBadge(
                          icon: Icons.shopping_bag_outlined,
                          count: appState.cartCount,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CartScreen()));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'What are you craving?',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.tune_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Special Offers',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 188,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: appState.specialOffers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) =>
                            _OfferCard(food: appState.specialOffers[index]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Food Categories',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () =>
                                setState(() => _selectedFilter = category.$1),
                            child: Ink(
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.04),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8)),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFEEF8F1),
                                    child: Icon(category.$2,
                                        color: const Color(0xFF1B8A5A)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(category.$1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1B8A5A), Color(0xFF2EB875)]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              color: Colors.white, size: 34),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Discount Guaranteed',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18)),
                                SizedBox(height: 4),
                                Text(
                                    'Use NEC Wallet and unlock extra offers on every combo order.',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Recommended For You',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _chips.map((chip) {
                        final selected = chip == _selectedFilter;
                        return ChoiceChip(
                          label: Text(chip),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = chip),
                          selectedColor: const Color(0xFFF28C28),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FoodCard(food: foods[index]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem food;

  const _FoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isFavorite = appState.isFavorite(food.id);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)));
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                food.imageUrl,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 104,
                  height: 104,
                  color: const Color(0xFFF4F4F4),
                  child: const Icon(Icons.fastfood_rounded, size: 38),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(food.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            context.read<AppState>().toggleFavorite(food.id),
                        icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color:
                                isFavorite ? Colors.redAccent : Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(food.category,
                      style: TextStyle(color: Colors.black.withOpacity(.55))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: Color(0xFFF28C28)),
                      const SizedBox(width: 4),
                      Text('${food.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.black.withOpacity(.45)),
                      const SizedBox(width: 4),
                      Text(food.distance,
                          style:
                              TextStyle(color: Colors.black.withOpacity(.45))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Rs.${food.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B8A5A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          context.read<AppState>().addToCart(food, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${food.name} added to cart')),
                          );
                        },
                        child: const Text('ADD'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final FoodItem food;

  const _OfferCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(food.imageUrl),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(.65), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF28C28),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(food.discount ?? 'HOT DEAL',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            Text(food.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('From Rs.${food.price.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _IconBadge({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF28C28),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }
}
