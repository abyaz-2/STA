# 📂 Categories Feature

A comprehensive category management system for organizing subscriptions. Users can create custom categories or use pre-built default categories to organize their subscriptions.

## Features

✅ **Default Categories** - 8 pre-built categories included
✅ **Custom Categories** - Create unlimited custom categories
✅ **Color Coding** - Each category has its own color
✅ **Icons** - Each category has an icon for visual identification
✅ **Search** - Find categories by name
✅ **Easy Selection** - Beautiful category picker dialog
✅ **Category Widgets** - Multiple display options (badge, chip, avatar)

## Architecture

### Models
- **Category Model** - Stores category metadata (id, name, color, icon, userId, createdAt, isDefault)

### Services
- **CategoryService** - Manages all category operations (CRUD, search, filtering)

### UI Components
- **CategorySelectionDialog** - Grid-based category picker
- **CategoryManagementScreen** - Full category management interface
- **CategoryWidget** - Horizontal category badge display
- **CategoryBadge** - Chip-based category display
- **CategoryAvatar** - Circle avatar display

### Utilities
- **CategoryUtils** - Helper functions for colors, icons, and formatting

## Default Categories

The system comes with 8 pre-built categories:

1. **Entertainment** - 🎭 Theaters (Red-Orange: #FF5733)
2. **Streaming** - ▶️ Play Circle (Green: #33FF57)
3. **Productivity** - 💼 Work (Blue: #3357FF)
4. **Fitness** - 🏋️ Fitness Center (Magenta: #FF33F5)
5. **Education** - 🎓 School (Yellow: #F5FF33)
6. **Cloud Storage** - ☁️ Cloud Upload (Cyan: #33FFF5)
7. **Music** - 🎵 Music Note (Orange: #FF8C33)
8. **News & Magazines** - 📰 Newspaper (Purple: #8C33FF)

## Usage Examples

### Create a Category
```dart
final categoryService = CategoryService();
final category = await categoryService.createCategory(
  name: 'Gaming',
  color: '#FF5733',
  icon: 'videogame_asset',
  userId: 'user123',
);
```

### Get All Categories
```dart
final categories = await categoryService.getAllCategories(userId: 'user123');
```

### Get Default Categories
```dart
final defaultCategories = await categoryService.getDefaultCategories();
```

### Update a Category
```dart
final updated = category.copyWith(name: 'Streaming Services');
await categoryService.updateCategory(updated);
```

### Delete a Category
```dart
// Only custom categories can be deleted
await categoryService.deleteCategory(categoryId);
```

### Search Categories
```dart
final results = await categoryService.searchCategories('music', userId: 'user123');
```

### Get Category by ID
```dart
final category = await categoryService.getCategoryById('category_id');
```

## UI Components

### Category Selection Dialog
```dart
showDialog(
  context: context,
  builder: (context) => CategorySelectionDialog(
    selectedCategoryId: currentCategoryId,
    userId: 'user123',
    onCategorySelected: (category) {
      print('Selected: ${category.name}');
    },
  ),
);
```

### Category Management Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
);
```

### Display Category Widget
```dart
CategoryWidget(
  category: category,
  width: 100,
  height: 40,
)
```

### Display Category Badge
```dart
CategoryBadge(
  category: category,
  onTap: () => print('Tapped: ${category.name}'),
)
```

### Display Category Avatar
```dart
CategoryAvatar(
  category: category,
  radius: 24,
)
```

## Integration with Subscriptions

### Add Category to Subscription Selection

In your subscription creation/editing screen:

```dart
// Show category selector
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

// Display selected category
if (_selectedCategory != null) {
  CategoryWidget(category: _selectedCategory!);
}
```

### Filter Subscriptions by Category

```dart
// Get all subscriptions from a specific category
final subscriptions = StorageService.getSubscriptions()
    .where((sub) => sub.category == selectedCategoryId)
    .toList();
```

### Group Subscriptions by Category

```dart
Map<String, List<Subscription>> groupSubscriptionsByCategory() {
  final subscriptions = StorageService.getSubscriptions();
  final grouped = <String, List<Subscription>>{};
  
  for (var sub in subscriptions) {
    final categoryId = sub.category ?? 'Other';
    grouped.putIfAbsent(categoryId, () => []).add(sub);
  }
  
  return grouped;
}
```

## Customization

### Add More Default Categories
In `category_service.dart`, add to `_initializeDefaultCategories()`:

```dart
Category(
  name: 'Gaming',
  color: '#9C33FF',
  icon: 'videogame_asset',
  userId: 'system',
  isDefault: true,
),
```

### Add More Icons
Add icon mappings in components:

```dart
final icons = {
  'theaters': Icons.theaters,
  'videogame_asset': Icons.videogame_asset,
  'sports': Icons.sports,
  // ... more icons
};
```

### Custom Color Palettes
Use `CategoryUtils.defaultColors` or add your own:

```dart
const List<String> customColors = [
  '#FF5733',
  '#33FF57',
  // ... more colors
];
```

## API Reference

### CategoryService Methods

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `init()` | - | `Future<void>` | Initialize and load default categories |
| `createCategory()` | name, color, icon, userId | `Future<Category>` | Create custom category |
| `getAllCategories()` | userId (optional) | `Future<List<Category>>` | Get all categories |
| `getCategoryById()` | id | `Future<Category?>` | Get specific category |
| `getCategoriesByUser()` | userId | `Future<List<Category>>` | Get user's categories |
| `updateCategory()` | category | `Future<void>` | Update existing category |
| `deleteCategory()` | id | `Future<bool>` | Delete custom category |
| `getDefaultCategories()` | - | `Future<List<Category>>` | Get default categories only |
| `searchCategories()` | query, userId (optional) | `Future<List<Category>>` | Search by name |
| `clearUserCategories()` | userId | `Future<void>` | Clear all user categories |

## File Structure

```
lib/
├── models/
│   └── category.dart
├── services/
│   └── category_service.dart
└── features/
    └── categories/
        ├── category_selection_dialog.dart
        ├── category_management_screen.dart
        ├── category_widgets.dart
        ├── category_utils.dart
        └── README.md
```

## Testing

1. Open Category Management screen
2. View default categories
3. Create a new category with custom color
4. Use Category Selection Dialog to select categories
5. Delete custom categories (default categories are protected)

## Next Steps

- [ ] Connect categories to subscription selection
- [ ] Filter/group subscriptions by category
- [ ] Show category stats (e.g., total spending per category)
- [ ] Category-based analytics
- [ ] Batch operations on categories
- [ ] Category icon upload/customization
