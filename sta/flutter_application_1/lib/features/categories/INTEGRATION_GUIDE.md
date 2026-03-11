# Categories Integration Guide

This guide shows how to integrate the categories feature into your existing subscription management system.

## Step 1: Add Category to Subscription Form

When creating/editing subscriptions, add a category selector.

### In your subscription form widget:

```dart
import 'package:flutter/material.dart';
import '../features/categories/category_selection_dialog.dart';
import '../features/categories/category_widgets.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class SubscriptionFormScreen extends StatefulWidget {
  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  String? _selectedCategoryId;
  Category? _selectedCategory;
  final CategoryService _categoryService = CategoryService();

  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (context) => CategorySelectionDialog(
        selectedCategoryId: _selectedCategoryId,
        userId: 'current_user', // Replace with actual user ID
        onCategorySelected: (category) {
          setState(() {
            _selectedCategoryId = category.id;
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... other form fields ...
        
        // Category selector
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory?.name ?? 'Select Category',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedCategory != null ? Colors.white : Colors.grey,
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        
        // Show selected category
        if (_selectedCategory != null) ...[
          SizedBox(height: 12),
          CategoryWidget(category: _selectedCategory!),
        ],
        
        // Save button
        ElevatedButton(
          onPressed: () {
            // Create subscription with category
            final subscription = Subscription(
              id: DateTime.now().toString(),
              userId: 'current_user',
              name: _nameController.text,
              amount: double.parse(_amountController.text),
              billingCycle: _selectedCycle,
              nextBillingDate: _selectedDate,
              category: _selectedCategoryId, // Add category here
            );
            
            StorageService.addSubscription(subscription);
            Navigator.pop(context);
          },
          child: Text('Save Subscription'),
        ),
      ],
    );
  }
}
```

## Step 2: Display Category in Subscription List

Show category badges next to subscription names:

```dart
class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category?>(
      future: _categoryService.getCategoryById(subscription.category ?? ''),
      builder: (context, snapshot) {
        final category = snapshot.data;

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.subscription)),
            title: Row(
              children: [
                Expanded(child: Text(subscription.name)),
                if (category != null) ...[
                  SizedBox(width: 8),
                  CategoryBadge(category: category),
                ]
              ],
            ),
            subtitle: Text('\$${subscription.amount}/${subscription.billingCycle}'),
            trailing: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }
}
```

## Step 3: Filter Subscriptions by Category

Add a filter dropdown on your subscription list screen:

```dart
class SubscriptionListWithFilter extends StatefulWidget {
  @override
  State<SubscriptionListWithFilter> createState() => _SubscriptionListWithFilterState();
}

class _SubscriptionListWithFilterState extends State<SubscriptionListWithFilter> {
  String? _filterCategoryId;
  final CategoryService _categoryService = CategoryService();

  List<Subscription> _getFilteredSubscriptions() {
    final allSubs = StorageService.getSubscriptions();
    
    if (_filterCategoryId == null) return allSubs;
    
    return allSubs
        .where((sub) => sub.category == _filterCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter dropdown
        FutureBuilder<List<Category>>(
          future: _categoryService.getAllCategories(),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            
            return Padding(
              padding: EdgeInsets.all(8),
              child: DropdownButton<String?>(
                value: _filterCategoryId,
                hint: Text('Filter by Category'),
                items: [
                  DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...categories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        CategoryWidget(category: cat),
                      ],
                    ),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _filterCategoryId = value);
                },
              ),
            );
          },
        ),
        
        // Filtered subscription list
        Expanded(
          child: ListView.builder(
            itemCount: _getFilteredSubscriptions().length,
            itemBuilder: (context, index) {
              final sub = _getFilteredSubscriptions()[index];
              return SubscriptionTile(subscription: sub);
            },
          ),
        ),
      ],
    );
  }
}
```

## Step 4: Group Subscriptions by Category

Organize subscriptions in an expandable list grouped by category:

```dart
class SubscriptionsGroupedByCategory extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  Future<Map<Category, List<Subscription>>> _groupSubscriptions() async {
    final allSubs = StorageService.getSubscriptions();
    final categories = await _categoryService.getAllCategories();
    final grouped = <Category, List<Subscription>>{};

    for (var category in categories) {
      final subs = allSubs
          .where((sub) => sub.category == category.id)
          .toList();
      
      if (subs.isNotEmpty) {
        grouped[category] = subs;
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Category, List<Subscription>>>(
      future: _groupSubscriptions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final grouped = snapshot.data ?? {};

        return ListView.builder(
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            final category = entry.key;
            final subscriptions = entry.value;

            return ExpansionTile(
              leading: CategoryAvatar(category: category),
              title: Text(category.name),
              subtitle: Text('${subscriptions.length} subscriptions'),
              children: subscriptions
                  .map((sub) => ListTile(
                        title: Text(sub.name),
                        subtitle: Text('\$${sub.amount}'),
                        trailing: Text(sub.billingCycle),
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
```

## Step 5: Show Category Statistics

Display spending by category:

```dart
class CategorySpendingStats extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  Future<Map<String, double>> _getCategoryTotals() async {
    final subs = StorageService.getSubscriptions();
    final totals = <String, double>{};

    for (var sub in subs) {
      final categoryId = sub.category ?? 'Uncategorized';
      totals[categoryId] = (totals[categoryId] ?? 0) + sub.amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _getCategoryTotals(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final totals = snapshot.data ?? {};

        return ListView.builder(
          itemCount: totals.length,
          itemBuilder: (context, index) {
            final entry = totals.entries.elementAt(index);
            final categoryId = entry.key;
            final total = entry.value;

            return ListTile(
              title: Text(categoryId),
              trailing: Text('\$${total.toStringAsFixed(2)}/month'),
            );
          },
        );
      },
    );
  }
}
```

## Complete Integration Checklist

- [ ] Import CategorySelectionDialog in subscription form
- [ ] Add category picker button to subscription form
- [ ] Save category ID with subscription
- [ ] Display category badge in subscription list
- [ ] Add category filter to list
- [ ] Show grouped view by category
- [ ] Display category icons/colors
- [ ] Add category spending stats
- [ ] Test category creation
- [ ] Test category deletion (custom only)

## Common Use Cases

### Show all subscriptions for a category
```dart
final categoryId = 'entertainment_id';
final subs = StorageService.getSubscriptions()
    .where((s) => s.category == categoryId)
    .toList();
```

### Calculate total for a category
```dart
final categoryId = 'streaming_id';
final total = StorageService.getSubscriptions()
    .where((s) => s.category == categoryId)
    .fold<double>(0, (sum, s) => sum + s.amount);
```

### Get category name from subscription
```dart
final category = await categoryService.getCategoryById(subscription.category ?? '');
print('Category: ${category?.name}');
```

### Update subscription category
```dart
// Note: You may need to add a copyWith method to Subscription
final updated = subscription.copyWith(category: newCategoryId);
// Then save...
```

## Tips & Best Practices

1. **Cache categories** - Store in a variable to avoid repeated queries
2. **Use CategoryWidget** - Reuse display components for consistency
3. **Handle null categories** - Provide fallback for uncategorized
4. **Protect defaults** - Never allow users to delete default categories
5. **Lazy load** - Use FutureBuilder for async category loads
6. **Type categories** - Use the Category model, not just strings
7. **Show in analytics** - Include category breakdown in dashboard

## Next Steps

After integrating categories:

1. **Add Analytics** - Show spending breakdown by category
2. **Category Rules** - Auto-assign categories based on keywords
3. **Category Budgets** - Set spending limits per category
4. **Export** - Export subscriptions organized by category
5. **Sharing** - Share category configurations with groups
