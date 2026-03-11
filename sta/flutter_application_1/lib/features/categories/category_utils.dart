import 'package:flutter/material.dart';

class CategoryUtils {
  /// Convert hex color string to Color object
  static Color hexToColor(String hexColor) {
    try {
      return Color(int.parse('0xff${hexColor.substring(1)}'));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Get icon data from icon name
  static IconData getIconData(String iconName) {
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
      'sports': Icons.sports,
      'videogame_asset': Icons.videogame_asset,
      'kitchen': Icons.kitchen,
      'hotel': Icons.hotel,
      'volunteer_activism': Icons.volunteer_activism,
    };

    return icons[iconName] ?? Icons.category;
  }

  /// Predefined colors for categories
  static const List<String> defaultColors = [
    '#FF5733', // Red-Orange
    '#33FF57', // Green
    '#3357FF', // Blue
    '#FF33F5', // Magenta
    '#F5FF33', // Yellow
    '#33FFF5', // Cyan
    '#FF8C33', // Orange
    '#8C33FF', // Purple
  ];

  /// Predefined icons for categories
  static const List<String> defaultIcons = [
    'theaters',
    'play_circle_outline',
    'work_outline',
    'fitness_center',
    'school',
    'cloud_upload',
    'music_note',
    'newspaper',
    'shopping_cart',
    'local_restaurant',
    'directions_car',
    'home',
  ];

  /// Get a list of available icons for selection
  static List<String> getAvailableIcons() => defaultIcons;

  /// Get a list of available colors for selection
  static List<String> getAvailableColors() => defaultColors;

  /// Brightness detection for text color
  static Color getContrastingTextColor(String hexColor) {
    try {
      final color = Color(int.parse('0xff${hexColor.substring(1)}'));
      final luminance = color.computeLuminance();
      return luminance > 0.5 ? Colors.black : Colors.white;
    } catch (e) {
      return Colors.black;
    }
  }
}
