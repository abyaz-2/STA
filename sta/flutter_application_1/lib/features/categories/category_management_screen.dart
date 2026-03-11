import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/profile_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final currentUser = ProfileService().getCurrentUser();
    final userId = currentUser?.id;
    setState(() {
      _categories = _categoryService.getAllCategories(userId: userId);
    });
  }

  void _showCreateCategoryDialog() {
    final nameController = TextEditingController();
    String selectedColor = '#FF5733';
    String selectedIcon = 'theaters';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Color'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                                '#FF5733',
                                '#33FF57',
                                '#3357FF',
                                '#FF33F5',
                                '#F5FF33',
                                '#33FFF5',
                                '#FF8C33',
                                '#8C33FF',
                              ]
                              .map(
                                (color) => GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedColor = color),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse('0xff${color.substring(1)}'),
                                      ),
                                      border: Border.all(
                                        color: selectedColor == color
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final currentUser = ProfileService().getCurrentUser();
                      final userId = currentUser?.id ?? 'system';
                      await _categoryService.createCategory(
                        name: nameController.text,
                        color: selectedColor,
                        icon: selectedIcon,
                        userId: userId,
                      );
                      _loadCategories();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category created!')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    final success = await _categoryService.deleteCategory(categoryId);
    if (success) {
      _loadCategories();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete default category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];
          final defaultCategories = categories
              .where((c) => c.isDefault)
              .toList();
          final customCategories = categories
              .where((c) => !c.isDefault)
              .toList();

          return ListView(
            children: [
              if (defaultCategories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Default Categories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...defaultCategories.map(
                  (category) => _buildCategoryTile(category, isDefault: true),
                ),
              ],
              if (customCategories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your Categories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...customCategories.map(
                  (category) => _buildCategoryTile(category, isDefault: false),
                ),
              ],
              if (categories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No categories found'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryTile(Category category, {required bool isDefault}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(
              int.parse('0xff${category.color.substring(1)}'),
            ).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconData(category.icon),
            color: Color(int.parse('0xff${category.color.substring(1)}')),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(isDefault ? 'Default' : 'Custom'),
        trailing: isDefault
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteCategory(category.id),
              ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final icons = {
      'theaters': Icons.theaters,
      'play_circle_outline': Icons.play_circle_outline,
      'work_outline': Icons.work_outline,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'cloud_upload': Icons.cloud_upload,
      'music_note': Icons.music_note,
      'newspaper': Icons.newspaper,
      'shopping_cart': Icons.shopping_cart,
      'local_restaurant': Icons.local_restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
    };

    return icons[iconName] ?? Icons.category;
  }
}
