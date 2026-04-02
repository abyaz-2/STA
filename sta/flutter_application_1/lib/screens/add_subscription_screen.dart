import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../features/categories/category_selection_dialog.dart';
import '../features/categories/category_widgets.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String billingCycle = "monthly";
  DateTime selectedDate = DateTime.now();
  bool isShared = false;
  String? selectedCategoryId;
  Category? selectedCategory;
  int reminderDaysBefore = 1; // 1, 3, or 7 days before billing date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Subscription")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: billingCycle,
                decoration: const InputDecoration(
                  labelText: "Billing Cycle",
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),
              // Category Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(selectedCategory?.name ?? 'Select Category'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => CategorySelectionDialog(
                        selectedCategoryId: selectedCategoryId,
                        userId: 'current_user',
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategoryId = category.id;
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              if (selectedCategory != null) ...[
                const SizedBox(height: 12),
                CategoryWidget(category: selectedCategory!),
              ],
              const SizedBox(height: 16),
              // ── Reminder Picker ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Remind me before renewal',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 1,
                          label: Text('1 day'),
                          icon: Icon(Icons.notifications_active),
                        ),
                        ButtonSegment(
                          value: 3,
                          label: Text('3 days'),
                          icon: Icon(Icons.notifications),
                        ),
                        ButtonSegment(
                          value: 7,
                          label: Text('7 days'),
                          icon: Icon(Icons.schedule),
                        ),
                      ],
                      selected: {reminderDaysBefore},
                      onSelectionChanged: (Set<int> selection) {
                        setState(() {
                          reminderDaysBefore = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reminderDaysBefore == 7
                          ? 'You\'ll get notifications 7, 3 & 1 day before'
                          : reminderDaysBefore == 3
                          ? 'You\'ll get notifications 3 & 1 day before'
                          : 'You\'ll get a notification 1 day before',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Shared Subscription"),
                value: isShared,
                onChanged: (value) {
                  setState(() {
                    isShared = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Date Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text("Due Date: ${_formatDate(selectedDate)}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a name')),
                    );
                    return;
                  }
                  if (amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an amount')),
                    );
                    return;
                  }

                  final sub = Subscription(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    billingCycle: billingCycle,
                    nextBillingDate: selectedDate,
                    userId: 'mock_user123',
                    isShared: isShared,
                    category: selectedCategoryId,
                    reminderDaysBefore: reminderDaysBefore,
                  );

                  await StorageService.addSubscription(sub);
                  await NotificationService.scheduleRenewalReminder(sub);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Reminder set: $reminderDaysBefore day${reminderDaysBefore == 1 ? '' : 's'} before renewal',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save Subscription",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
