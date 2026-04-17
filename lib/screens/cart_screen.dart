import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (appState.cartItems.isNotEmpty)
            TextButton(
              onPressed: () => context.read<AppState>().clearCart(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: appState.cartItems.isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.pop(context))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: appState.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = appState.cartItems[index];
                      return Dismissible(
                        key: ValueKey(item.cartId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => context
                            .read<AppState>()
                            .removeCartItem(item.cartId),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(22)),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.05),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 82,
                                  height: 82,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 82,
                                    height: 82,
                                    color: const Color(0xFFF4F4F4),
                                    child: const Icon(Icons.fastfood_rounded),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(item.category,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(.55))),
                                    const SizedBox(height: 10),
                                    Text(
                                        'Rs.${(item.currentPrice * item.quantity).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1B8A5A))),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  _StepButton(
                                      icon: Icons.add_rounded,
                                      onTap: () => context
                                          .read<AppState>()
                                          .updateCartQuantity(
                                              item.cartId, item.quantity + 1)),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  _StepButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () => context
                                          .read<AppState>()
                                          .updateCartQuantity(
                                              item.cartId, item.quantity - 1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: 'Items total',
                          value: 'Rs.${appState.cartTotal.toStringAsFixed(0)}'),
                      const SizedBox(height: 10),
                      const _SummaryRow(label: 'Delivery', value: 'Free'),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Wallet balance',
                        value:
                            'Rs.${appState.walletBalance.toStringAsFixed(0)}',
                        highlight: true,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF28C28),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () async {
                            final result =
                                await context.read<AppState>().placeOrder();
                            final success = result.isSuccess;
                            final order = result.order;
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                backgroundColor: success
                                    ? const Color(0xFF1B8A5A)
                                    : Colors.redAccent,
                              ),
                            );
                            if (!success || order == null) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderConfirmationScreen(order: order),
                              ),
                            );
                          },
                          child: Text(
                              'Place Order  Rs.${appState.cartTotal.toStringAsFixed(0)}'),
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

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 88, color: Color(0xFF1B8A5A)),
            const SizedBox(height: 18),
            const Text('Your cart is empty',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
                'Add something delicious from the menu to place your first order.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withOpacity(.6))),
            const SizedBox(height: 20),
            FilledButton(onPressed: onBrowse, child: const Text('Browse Food')),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: highlight ? FontWeight.w900 : FontWeight.w600,
      color: highlight ? const Color(0xFF1B8A5A) : Colors.black87,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
