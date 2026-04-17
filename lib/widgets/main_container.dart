import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/admin_dashboard_screen.dart';
import '../screens/e_wallet_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/profile_screen.dart';
import '../services/app_state.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAdmin = appState.currentUser?.isAdmin ?? false;
    final pages = isAdmin
        ? const [
            AdminDashboardScreen(),
            _MessagesScreen(),
            ProfileScreen(),
          ]
        : const [
            HomeScreen(),
            MyOrdersScreen(),
            _MessagesScreen(),
            EWalletScreen(),
            ProfileScreen(),
          ];
    final destinations = isAdmin
        ? const [
            NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_rounded),
                label: 'Message'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ]
        : const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_rounded),
                label: 'Message'),
            NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'E-Wallet'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ];
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        height: 72,
        destinations: destinations,
      ),
    );
  }
}

class _MessagesScreen extends StatelessWidget {
  const _MessagesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Messages',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text(
                'Support and order updates from the canteen will show up here.',
                style: TextStyle(color: Colors.black.withOpacity(.65)),
              ),
              const SizedBox(height: 24),
              const _MessageTile(
                icon: Icons.support_agent_rounded,
                title: 'NEC Support',
                subtitle:
                    'Need help with pickup timing? We are online till 8 PM.',
                time: 'Now',
              ),
              const _MessageTile(
                icon: Icons.local_offer_rounded,
                title: 'Offer Bot',
                subtitle: 'Today only: free fries on orders above Rs.199.',
                time: '1h ago',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _MessageTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEEF8F1),
            child: Icon(icon, color: const Color(0xFF1B8A5A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.black.withOpacity(.62))),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(
                  color: Colors.black.withOpacity(.45), fontSize: 12)),
        ],
      ),
    );
  }
}
