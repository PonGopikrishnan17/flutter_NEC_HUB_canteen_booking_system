import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../services/app_state.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: orders.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Orders',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    const Center(
                        child: Icon(Icons.receipt_long_outlined,
                            size: 82, color: Color(0xFF1B8A5A))),
                    const SizedBox(height: 18),
                    const Center(
                        child: Text('No orders yet',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900))),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Place your first canteen order and track it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black.withOpacity(.6)),
                      ),
                    ),
                    const Spacer(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Orders',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('Track every order from kitchen prep to pickup.',
                        style: TextStyle(color: Colors.black.withOpacity(.6))),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) =>
                            _OrderTile(order: orders[index]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd MMM, hh:mm a').format(order.createdAt);
    final currentStep = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.accepted => 1,
      OrderStatus.ready => 2,
      OrderStatus.completed => 3,
      OrderStatus.cancelled => 0,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderId,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(time,
                        style: TextStyle(color: Colors.black.withOpacity(.55))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  order.status.displayName,
                  style: TextStyle(
                      color: order.statusColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
              'Code ${order.pickupCode}  •  Token #${order.tokenNumber}  •  ${order.canteenDepartment}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            order.items
                .map((item) => '${item.itemName} x${item.quantity}')
                .join(', '),
            style: TextStyle(color: Colors.black.withOpacity(.65)),
          ),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.cancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'This order was cancelled by admin. Any demo payment entry remains only for testing.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            _TrackLine(currentStep: currentStep),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Total Rs.${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Color(0xFF1B8A5A))),
              const Spacer(),
              Text(
                  '${order.paymentStatus} • ETA ${order.estimatedWaitTime} min',
                  style: TextStyle(
                      color: Colors.black.withOpacity(.55),
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackLine extends StatelessWidget {
  final int currentStep;

  const _TrackLine({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Pending', 'Taken', 'Ready', 'Completed'];
    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          final active = index ~/ 2 < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              color: active ? const Color(0xFF1B8A5A) : const Color(0xFFE5E8EA),
            ),
          );
        }
        final step = index ~/ 2;
        final active = step <= currentStep;
        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  active ? const Color(0xFF1B8A5A) : const Color(0xFFE5E8EA),
              child: Icon(Icons.check_rounded,
                  size: 15, color: active ? Colors.white : Colors.transparent),
            ),
            const SizedBox(height: 6),
            Text(labels[step],
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        );
      }),
    );
  }
}
