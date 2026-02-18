import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../widgets/subscription_tile.dart';
import 'add_subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  double getTotalMonthly() {
    double total = 0;
    for (var sub in subscriptions) {
      if (sub.billingCycle == "monthly") {
        total += sub.amount;
      } else {
        total += sub.amount / 12;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subscriptions")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Total Monthly: ₹${getTotalMonthly().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                return SubscriptionTile(
                  subscription: sub,
                  onDelete: () async {
                    await StorageService.deleteSubscription(sub.id);
                    loadSubscriptions();
                  },
                );
              },
            ),
          ),
        ],
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
