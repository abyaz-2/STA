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
                value: billingCycle,
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
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
                child: Text("Due Date: ${_formatDate(selectedDate)}"),
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
                  );

                  await StorageService.addSubscription(sub);
                  await NotificationService.scheduleRenewalReminder(sub);
                  Navigator.pop(context);
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
