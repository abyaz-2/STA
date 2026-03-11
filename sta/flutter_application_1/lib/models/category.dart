import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String color; // Hex color code (e.g., '#FF5733')
  final String icon; // Material icon name (e.g., 'shopping_cart')
  final String userId;
  final DateTime createdAt;
  final bool isDefault;

  Category({
    String? id,
    required this.name,
    required this.color,
    required this.icon,
    required this.userId,
    DateTime? createdAt,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      userId: map['userId'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    String? userId,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, color: $color, icon: $icon)';
}
