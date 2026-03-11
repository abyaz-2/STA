import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class CategorySelectionDialog extends StatefulWidget {
  final String? selectedCategoryId;
  final String userId;
  final Function(Category) onCategorySelected;

  const CategorySelectionDialog({
    required this.selectedCategoryId,
    required this.userId,
    required this.onCategorySelected,
    super.key,
  });

  @override
  State<CategorySelectionDialog> createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _categoryService.getAllCategories(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final categories = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          category.id == widget.selectedCategoryId;

                      return GestureDetector(
                        onTap: () {
                          widget.onCategorySelected(category);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse('0xff${category.color.substring(1)}'),
                            ).withOpacity(0.2),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconData(category.icon),
                                size: 28,
                                color: Color(
                                  int.parse(
                                    '0xff${category.color.substring(1)}',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
