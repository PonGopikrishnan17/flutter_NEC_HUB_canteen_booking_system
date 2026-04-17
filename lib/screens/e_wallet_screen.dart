import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class EWalletScreen extends StatelessWidget {
  const EWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('E-Wallet',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1B8A5A), Color(0xFFF28C28)]),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('Rs.${appState.walletBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              context.read<AppState>().topUpWallet(200);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Rs.200 added to wallet')));
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('Top Up'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              context.read<AppState>().scanWallet();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Campus scan mode ready')));
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text('Scan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Transaction History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: appState.walletTransactions.length,
                  itemBuilder: (context, index) {
                    final item = appState.walletTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                        children: [
                          CircleAvatar(
                            backgroundColor: item.isCredit
                                ? const Color(0xFFEEF8F1)
                                : const Color(0xFFFFF1E5),
                            child: Icon(
                                item.isCredit
                                    ? Icons.south_west_rounded
                                    : Icons.north_east_rounded,
                                color: item.isCredit
                                    ? const Color(0xFF1B8A5A)
                                    : const Color(0xFFF28C28)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(
                                    DateFormat('dd MMM • hh:mm a')
                                        .format(item.createdAt),
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(.5),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            '${item.isCredit ? '+' : '-'}Rs.${item.amount.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              color: item.isCredit
                                  ? const Color(0xFF1B8A5A)
                                  : Colors.black87,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
