import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../services/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<String> _filters = const [
    'All',
    'Pending',
    'Taken',
    'Ready',
    'Completed',
    'Cancelled',
  ];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final orders = appState.adminOrders.where((order) {
      if (_selectedFilter == 'All') return true;
      return order.status.displayName == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFF28C28),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OverviewSection(
                revenue: appState.dailyRevenue,
                activeOrders: appState.activeOrderCount,
                totalOrders: appState.adminOrders.length,
              ),
              const SizedBox(height: 18),
              const Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filters.map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    selectedColor: const Color(0xFFF28C28),
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Student Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${orders.length} orders',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (orders.isEmpty)
                const _EmptyState()
              else
                ...orders.map((order) => _OrderCard(order: order)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final double revenue;
  final int activeOrders;
  final int totalOrders;

  const _OverviewSection({
    required this.revenue,
    required this.activeOrders,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.currency_rupee_rounded,
            label: 'Completed Revenue',
            value: revenue.toStringAsFixed(0),
            color: const Color(0xFF1B8A5A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag_rounded,
            label: 'Active Orders',
            value: '$activeOrders / $totalOrders',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateFormat('dd MMM • hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pickup code ${order.pickupCode}  •  Token #${order.tokenNumber}',
                      style: const TextStyle(
                        color: Color(0xFFF28C28),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.userName} • ${order.studentId}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      '${order.department} • $createdAt',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _StatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.payments_outlined,
                label: '${order.paymentMethod} • ${order.paymentStatus}',
              ),
              _InfoChip(
                icon: Icons.account_balance_wallet_outlined,
                label: order.paymentReference,
              ),
              _InfoChip(
                icon: Icons.timer_outlined,
                label: order.estimatedWaitTime == 0
                    ? 'No pending ETA'
                    : '${order.estimatedWaitTime} min ETA',
              ),
              if (order.queuePosition > 0)
                _InfoChip(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Queue ${order.queuePosition}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            order.items
                .map((item) => '${item.itemName} x${item.quantity}')
                .join(', '),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total ₹${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildActions(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.completed) {
      return const [];
    }

    final actions = <Widget>[];

    if (order.status == OrderStatus.pending) {
      actions.add(
        _ActionButton(
          label: 'Take Order',
          color: Colors.blue,
          onTap: () => context
              .read<AppState>()
              .updateOrderStatus(order.id, OrderStatus.accepted),
        ),
      );
    }

    if (order.status == OrderStatus.accepted) {
      actions.add(
        _ActionButton(
          label: 'Mark Ready',
          color: const Color(0xFFF28C28),
          onTap: () => context
              .read<AppState>()
              .updateOrderStatus(order.id, OrderStatus.ready),
        ),
      );
    }

    if (order.status == OrderStatus.ready) {
      actions.add(
        _ActionButton(
          label: 'Complete',
          color: const Color(0xFF1B8A5A),
          onTap: () => context
              .read<AppState>()
              .updateOrderStatus(order.id, OrderStatus.completed),
        ),
      );
    }

    actions.add(
      _ActionButton(
        label: 'Cancel',
        color: Colors.redAccent,
        onTap: () => context
            .read<AppState>()
            .updateOrderStatus(order.id, OrderStatus.cancelled),
      ),
    );

    return actions;
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.statusColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

extension on OrderStatus {
  Color get statusColor {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.ready:
        return const Color(0xFFF28C28);
      case OrderStatus.completed:
        return const Color(0xFF1B8A5A);
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.black38),
          SizedBox(height: 10),
          Text(
            'No orders found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'New student orders will appear here for admin action.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
