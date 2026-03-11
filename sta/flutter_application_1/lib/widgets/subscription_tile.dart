import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../screens/subscription_detail_screen.dart';

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onDelete;

  SubscriptionTile({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category?>(
      future: subscription.category != null
          ? CategoryService().getCategoryById(subscription.category!)
          : Future.value(null),
      builder: (context, snapshot) {
        final category = snapshot.data;

        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SubscriptionDetailScreen(subscription: subscription),
                ),
              );
            },
            title: Row(
              children: [
                Expanded(
                  child: Text(subscription.name),
                ),
                if (category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xff${category.color.substring(1)}')).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(int.parse('0xff${category.color.substring(1)}')),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(int.parse('0xff${category.color.substring(1)}')),
                      ),
                    ),
                  ),
                ],
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}
