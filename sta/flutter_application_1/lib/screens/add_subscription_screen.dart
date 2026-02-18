import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String billingCycle = "monthly";
  DateTime selectedDate = DateTime.now();
  bool reminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Subscription")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            DropdownButton<String>(
              value: billingCycle,
              items: const [
                DropdownMenuItem(value: "monthly", child: Text("Monthly")),
                DropdownMenuItem(value: "yearly", child: Text("Yearly")),
              ],
              onChanged: (value) {
                setState(() {
                  billingCycle = value!;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Enable Reminder"),
              value: reminderEnabled,
              onChanged: (value) {
                setState(() {
                  reminderEnabled = value;
                });
              },
            ),
            ElevatedButton(
              child: const Text("Pick Due Date"),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                final sub = Subscription(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  amount: double.parse(amountController.text),
                  billingCycle: billingCycle,
                  nextDueDate: selectedDate,
                  reminderEnabled: reminderEnabled,
                );

                await StorageService.addSubscription(sub);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
