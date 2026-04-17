import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markNotificationsSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<AppState>().notifications;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
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
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEEF8F1),
                  child: Icon(_iconFor(item.title),
                      color: const Color(0xFF1B8A5A)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16))),
                          if (item.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF28C28),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('New',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.message,
                          style: TextStyle(
                              color: Colors.black.withOpacity(.66),
                              height: 1.45)),
                      const SizedBox(height: 8),
                      Text(
                          DateFormat('dd MMM • hh:mm a').format(item.createdAt),
                          style: TextStyle(
                              color: Colors.black.withOpacity(.45),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(String title) {
    if (title.toLowerCase().contains('cancel')) return Icons.cancel_outlined;
    if (title.toLowerCase().contains('offer')) {
      return Icons.local_offer_outlined;
    }
    return Icons.notifications_active_outlined;
  }
}
