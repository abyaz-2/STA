import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../services/category_service.dart';
import '../features/categories/category_selection_dialog.dart';
import '../features/categories/category_widgets.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({required this.subscription, super.key});

  @override
  State<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  late Subscription _subscription;
  final CategoryService _categoryService = CategoryService();
  Category? _category;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
    _nameController = TextEditingController(text: _subscription.name);
    _amountController = TextEditingController(text: _subscription.amount.toString());
    _loadCategory();
  }

  void _loadCategory() async {
    if (_subscription.category != null) {
      final category = await _categoryService.getCategoryById(_subscription.category!);
      setState(() => _category = category);
    }
  }

  void _changeCategory() {
    showDialog(
      context: context,
      builder: (context) => CategorySelectionDialog(
        selectedCategoryId: _subscription.category,
        userId: 'current_user',
        onCategorySelected: (category) async {
          setState(() {
            _category = category;
            _subscription = _subscription.copyWith(category: category.id);
          });
          // Note: Add copyWith to Subscription model if not present
          // For now, we'll update it directly in storage
          await StorageService.addSubscription(_subscription);
        },
      ),
    );
  }

  void _save() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Create updated subscription using copyWith
    final updated = _subscription.copyWith(
      name: _nameController.text,
      amount: double.parse(_amountController.text),
    );

    await StorageService.addSubscription(updated);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription updated!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subscription Name
              if (_isEditing)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subscription.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Amount
              if (_isEditing)
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_subscription.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Billing Cycle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Cycle',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subscription.billingCycle.toUpperCase(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  if (_category != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryWidget(category: _category!),
                        if (_isEditing)
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Change'),
                            onPressed: _changeCategory,
                          )
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _changeCategory,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Add Category'),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 24),

              // Next Billing Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Billing Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(_subscription.nextBillingDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Shared Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shared'),
                  Chip(
                    label: Text(_subscription.isShared ? 'Yes' : 'No'),
                    backgroundColor: _subscription.isShared ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              if (_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: _save,
                  child: const Text('Save Changes'),
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
