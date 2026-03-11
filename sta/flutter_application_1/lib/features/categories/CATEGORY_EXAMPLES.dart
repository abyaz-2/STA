/// Example implementations of the Categories feature
/// 
/// This file shows practical examples of how to use the category system
/// in your subscription management app.

import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/subscription.dart';
import '../../services/category_service.dart';
import '../../services/storage_service.dart';
import 'category_selection_dialog.dart';
import 'category_widgets.dart';

/// Example 1: Category Selection in Subscription Form
class SubscriptionFormWithCategoryExample extends StatefulWidget {
  const SubscriptionFormWithCategoryExample({super.key});

  @override
  State<SubscriptionFormWithCategoryExample> createState() => _SubscriptionFormExampleState();
}

class _SubscriptionFormExampleState extends State<SubscriptionFormWithCategoryExample> {
  String? _selectedCategoryId;
  Category? _selectedCategory;

  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (context) => CategorySelectionDialog(
        selectedCategoryId: _selectedCategoryId,
        userId: 'current_user',
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
        ElevatedButton(
          onPressed: _showCategoryPicker,
          child: const Text('Select Category'),
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: 16),
          CategoryWidget(category: _selectedCategory!),
        ]
      ],
    );
  }
}

/// Example 2: Filter Subscriptions by Category
class SubscriptionsByCategoryExample {
  final CategoryService _categoryService = CategoryService();

  /// Get all subscriptions filtered by category
  Future<List<Subscription>> getSubscriptionsByCategory(String categoryId) async {
    final allSubscriptions = StorageService.getSubscriptions();
    return allSubscriptions.where((sub) => sub.category == categoryId).toList();
  }

  /// Get total spending for a category
  Future<double> getTotalSpendingByCategory(String categoryId) async {
    final subs = await getSubscriptionsByCategory(categoryId);
    return subs.fold<double>(0, (sum, sub) => sum + sub.amount);
  }

  /// Get category breakdown
  Future<Map<String, double>> getCategoryBreakdown() async {
    final categories = await _categoryService.getAllCategories();
    final breakdown = <String, double>{};

    for (var category in categories) {
      final spending = await getTotalSpendingByCategory(category.id);
      breakdown[category.name] = spending;
    }

    return breakdown;
  }
}

/// Example 3: Group Subscriptions by Category
class SubscriptionsGroupedByCategoryExample {
  final CategoryService _categoryService = CategoryService();

  /// Group subscriptions by category
  Future<Map<Category, List<Subscription>>> groupSubscriptionsByCategory() async {
    final allSubscriptions = StorageService.getSubscriptions();
    final groups = <Category, List<Subscription>>{};

    // Get all categories
    final categories = await _categoryService.getAllCategories();

    // Group subscriptions
    for (var category in categories) {
      final subs = allSubscriptions.where((sub) => sub.category == category.id).toList();
      if (subs.isNotEmpty) {
        groups[category] = subs;
      }
    }

    return groups;
  }

  /// Display grouped subscriptions in UI
  Future<void> displayGroupedSubscriptions(BuildContext context) async {
    final grouped = await groupSubscriptionsByCategory();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: grouped.entries.map((entry) {
            final category = entry.key;
            final subscriptions = entry.value;

            return ExpansionTile(
              leading: Icon(Icons.category),
              title: Text(category.name),
              subtitle: Text('${subscriptions.length} subscriptions'),
              children: subscriptions
                  .map((sub) => ListTile(
                        title: Text(sub.name),
                        subtitle: Text('\$${sub.amount}/${sub.billingCycle}'),
                      ))
                  .toList(),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Example 4: Category Statistics
class CategoryStatisticsExample {
  final CategoryService _categoryService = CategoryService();

  /// Get category usage statistics
  Future<Map<String, int>> getCategoryUsageStats() async {
    final allSubscriptions = StorageService.getSubscriptions();
    final stats = <String, int>{};

    for (var sub in allSubscriptions) {
      final categoryId = sub.category ?? 'Uncategorized';
      stats[categoryId] = (stats[categoryId] ?? 0) + 1;
    }

    return stats;
  }

  /// Get most expensive categories
  Future<List<(String, double)>> getMostExpensiveCategories() async {
    final allSubscriptions = StorageService.getSubscriptions();
    final categoryTotals = <String, double>{};

    for (var sub in allSubscriptions) {
      final categoryId = sub.category ?? 'Uncategorized';
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + sub.amount;
    }

    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => (e.key, e.value)).toList();
  }
}

/// Example 5: Search and Filter Categories
class CategorySearchExample {
  final CategoryService _categoryService = CategoryService();

  Future<void> searchAndDisplay(String query) async {
    final results = await _categoryService.searchCategories(query, userId: 'current_user');

    for (var category in results) {
      print('Found: ${category.name} - ${category.icon}');
    }
  }

  /// Find categories by icon type
  Future<List<Category>> getCategoriesByIconType(String iconName) async {
    final allCategories = await _categoryService.getAllCategories();
    return allCategories.where((cat) => cat.icon == iconName).toList();
  }
}

/// Example 6: Bulk Category Operations
class BulkCategoryOperationsExample {
  final CategoryService _categoryService = CategoryService();

  /// Create multiple categories at once
  Future<void> createBulkCategories() async {
    final newCategories = [
      ('Gifts', '#FF1744', 'card_giftcard'),
      ('Healthcare', '#00BCD4', 'local_hospital'),
      ('Transport', '#FF9800', 'directions_car'),
    ];

    for (var (name, color, icon) in newCategories) {
      await _categoryService.createCategory(
        name: name,
        color: color,
        icon: icon,
        userId: 'current_user',
      );
    }
  }

  /// Migrate subscriptions to new category
  Future<void> migrateCategorySubscriptions(String oldCategoryId, String newCategoryId) async {
    final allSubscriptions = StorageService.getSubscriptions();
    final toMigrate = allSubscriptions.where((sub) => sub.category == oldCategoryId).toList();

    for (var sub in toMigrate) {
      // Note: Subscription.copyWith or similar needed
      // This is a conceptual example
      print('Migrating ${sub.name} from $oldCategoryId to $newCategoryId');
    }
  }
}
