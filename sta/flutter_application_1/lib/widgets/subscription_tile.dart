import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../screens/subscription_detail_screen.dart';
import '../features/categories/category_widgets.dart';

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onDelete;
  final CategoryService _categoryService = CategoryService();

  SubscriptionTile({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category?>(
      future: subscription.category != null
          ? _categoryService.getCategoryById(subscription.category!)
          : Future.value(null),
      builder: (context, snapshot) {
        final category = snapshot.data;

        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionDetailScreen(subscription: subscription),
                ),
              );
            },
            title: Row(
              children: [
                Expanded(child: Text(subscription.name)),
                if (category != null) ...[
                  const SizedBox(width: 8),
                  CategoryBadge(category: category),
                ]
              ],
            ),
            subtitle: Text(
              "${subscription.billingCycle.toUpperCase()} • Due: ${subscription.nextBillingDate.toLocal().toString().split(' ')[0]}",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
            leading: Text(
              "\$${subscription.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
