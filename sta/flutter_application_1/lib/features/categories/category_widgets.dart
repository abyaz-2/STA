import 'package:flutter/material.dart';
import '../../models/category.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final EdgeInsets padding;

  const CategoryWidget({
    required this.category,
    this.width = 80,
    this.height = 36,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xff${category.color.substring(1)}'));

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIconData(category.icon), size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              category.name,
              style:
                  textStyle ??
                  TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

class CategoryBadge extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryBadge({required this.category, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xff${category.color.substring(1)}'));

    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(_getIconData(category.icon), size: 14, color: color),
        label: Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(color: color, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
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

class CategoryAvatar extends StatelessWidget {
  final Category category;
  final double radius;

  const CategoryAvatar({required this.category, this.radius = 20, super.key});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xff${category.color.substring(1)}'));

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(_getIconData(category.icon), color: color),
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
