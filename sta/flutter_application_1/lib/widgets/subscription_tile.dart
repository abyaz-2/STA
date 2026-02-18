import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onDelete;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Text(
          "${subscription.billingCycle.toUpperCase()} • Due: ${subscription.nextDueDate.toLocal().toString().split(' ')[0]}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("₹${subscription.amount.toStringAsFixed(2)}"),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
