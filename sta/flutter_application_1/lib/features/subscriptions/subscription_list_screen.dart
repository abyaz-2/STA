import 'package:flutter/material.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/subscription_tile.dart';
import '../../screens/add_subscription_screen.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<Subscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  void loadSubscriptions() {
    setState(() {
      subscriptions = StorageService.getSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Subscriptions")),
      body: subscriptions.isEmpty
          ? const Center(child: Text("No subscriptions yet.\nAdd one to track your spending!"))
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                return SubscriptionTile(
                  subscription: sub,
                  onDelete: () async {
                    await StorageService.deleteSubscription(sub.id);
                    await NotificationService.cancelReminder(sub.id);
                    loadSubscriptions();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
          );
          loadSubscriptions();
        },
      ),
    );
  }
}
