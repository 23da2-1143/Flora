import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: AppColors.darkGray)),
        iconTheme: const IconThemeData(color: AppColors.darkGray),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.blushPink),
                  SizedBox(height: 16),
                  Text(
                    'No orders placed yet.',
                    style: TextStyle(color: AppColors.lightGray, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['id'] ?? '';
              final total = (order['total'] ?? 0.0).toDouble();
              final status = order['status'] ?? 'Processing';
              final createdAt = order['createdAt'];

              Color statusColor = AppColors.gold;
              if (status == 'Delivered') {
                statusColor = Colors.green;
              } else if (status == 'Shipped') {
                statusColor = Colors.blue;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(color: AppColors.lightGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rs ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

