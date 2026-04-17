import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/app_state.dart';
import 'landing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Profile',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF1B8A5A),
                      child: Icon(Icons.person_rounded,
                          color: Colors.white, size: 36)),
                  const SizedBox(height: 14),
                  Text(user.fullName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(user.email,
                      style: TextStyle(color: Colors.black.withOpacity(.6))),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF8F1),
                        borderRadius: BorderRadius.circular(18)),
                    child: Text(
                      'Role: ${user.role == UserRole.admin ? 'Admin' : 'Student'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B8A5A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...const [
              ('Edit Profile', Icons.edit_outlined),
              ('Saved Addresses', Icons.location_on_outlined),
              ('Payment Methods', Icons.payments_outlined),
              ('Notifications', Icons.notifications_none_rounded),
              ('Help & Support', Icons.help_outline_rounded),
              ('About', Icons.info_outline_rounded),
            ].map((item) => _ProfileTile(title: item.$1, icon: item.$2)),
            const SizedBox(height: 18),
            FilledButton.tonal(
              onPressed: () async {
                await context.read<AppState>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFF1E5),
                foregroundColor: const Color(0xFFF28C28),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ProfileTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEEF8F1),
          child: Icon(icon, color: const Color(0xFF1B8A5A)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon')),
          );
        },
      ),
    );
  }
}
