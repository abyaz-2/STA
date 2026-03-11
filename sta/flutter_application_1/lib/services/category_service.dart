import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';

class CategoryService {
  static const String _categoriesBoxName = 'categories';
  late Box<Map> _categoriesBox;

  static final CategoryService _instance = CategoryService._internal();

  CategoryService._internal();

  factory CategoryService() {
    return _instance;
  }

  Future<void> init() async {
    _categoriesBox = await Hive.openBox<Map>(_categoriesBoxName);
    
    // Initialize default categories if box is empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  /// Initialize with default categories
  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      Category(
        name: 'Entertainment',
        color: '#FF5733',
        icon: 'theaters',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Streaming',
        color: '#33FF57',
        icon: 'play_circle_outline',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Productivity',
        color: '#3357FF',
        icon: 'work_outline',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Fitness',
        color: '#FF33F5',
        icon: 'fitness_center',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Education',
        color: '#F5FF33',
        icon: 'school',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Cloud Storage',
        color: '#33FFF5',
        icon: 'cloud_upload',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'Music',
        color: '#FF8C33',
        icon: 'music_note',
        userId: 'system',
        isDefault: true,
      ),
      Category(
        name: 'News & Magazines',
        color: '#8C33FF',
        icon: 'newspaper',
        userId: 'system',
        isDefault: true,
      ),
    ];

    for (var category in defaultCategories) {
      await _categoriesBox.put(category.id, category.toMap());
    }
  }

  /// Create a new category
  Future<Category> createCategory({
    required String name,
    required String color,
    required String icon,
    required String userId,
  }) async {
    final category = Category(
      name: name,
      color: color,
      icon: icon,
      userId: userId,
    );

    await _categoriesBox.put(category.id, category.toMap());
    return category;
  }

  /// Get all categories (for a user + default categories)
  Future<List<Category>> getAllCategories({String? userId}) async {
    final categories = <Category>[];
    
    for (var value in _categoriesBox.values) {
      final category = Category.fromMap(Map<String, dynamic>.from(value));
      
      // Include default categories or categories owned by user
      if (category.isDefault || (userId != null && category.userId == userId)) {
        categories.add(category);
      }
    }
    
    return categories;
  }

  /// Get a specific category by ID
  Future<Category?> getCategoryById(String id) async {
    final value = _categoriesBox.get(id);
    if (value != null) {
      return Category.fromMap(Map<String, dynamic>.from(value));
    }
    return null;
  }

  /// Get categories by user ID
  Future<List<Category>> getCategoriesByUser(String userId) async {
    final categories = <Category>[];
    
    for (var value in _categoriesBox.values) {
      final category = Category.fromMap(Map<String, dynamic>.from(value));
      if (category.userId == userId || category.isDefault) {
        categories.add(category);
      }
    }
    
    return categories;
  }

  /// Update a category
  Future<void> updateCategory(Category category) async {
    await _categoriesBox.put(category.id, category.toMap());
  }

  /// Delete a custom category (not default)
  Future<bool> deleteCategory(String id) async {
    final value = _categoriesBox.get(id);
    if (value != null) {
      final category = Category.fromMap(Map<String, dynamic>.from(value));
      if (!category.isDefault) {
        await _categoriesBox.delete(id);
        return true;
      }
    }
    return false;
  }

  /// Get default categories
  Future<List<Category>> getDefaultCategories() async {
    final categories = <Category>[];
    
    for (var value in _categoriesBox.values) {
      final category = Category.fromMap(Map<String, dynamic>.from(value));
      if (category.isDefault) {
        categories.add(category);
      }
    }
    
    return categories;
  }

  /// Search categories by name
  Future<List<Category>> searchCategories(String query, {String? userId}) async {
    final categories = <Category>[];
    final lowerQuery = query.toLowerCase();
    
    for (var value in _categoriesBox.values) {
      final category = Category.fromMap(Map<String, dynamic>.from(value));
      
      if (category.name.toLowerCase().contains(lowerQuery) &&
          (category.isDefault || (userId != null && category.userId == userId))) {
        categories.add(category);
      }
    }
    
    return categories;
  }

  /// Clear all user categories (keep defaults)
  Future<void> clearUserCategories(String userId) async {
    final keysToDelete = <String>[];
    
    for (var entry in _categoriesBox.entries) {
      final category = Category.fromMap(Map<String, dynamic>.from(entry.value));
      if (category.userId == userId && !category.isDefault) {
        keysToDelete.add(entry.key);
      }
    }
    
    for (var key in keysToDelete) {
      await _categoriesBox.delete(key);
    }
  }
}
