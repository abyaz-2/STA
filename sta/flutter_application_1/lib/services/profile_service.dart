import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class ProfileService {
  static const String _usersBoxName = 'users';
  static const String _currentUserBoxName = 'current_user';
  late Box<Map> _usersBox;
  late Box<String> _currentUserBox;

  static final ProfileService _instance = ProfileService._internal();

  User? _currentUser;

  ProfileService._internal();

  factory ProfileService() {
    return _instance;
  }

  Future<void> init() async {
    _usersBox = await Hive.openBox<Map>(_usersBoxName);
    _currentUserBox = await Hive.openBox<String>(_currentUserBoxName);

    // Load current user if exists
    final currentUserId = _currentUserBox.get('userId');
    if (currentUserId != null) {
      _currentUser = await getUserById(currentUserId);
    }
  }

  /// Sign up a new user
  Future<User> signup({
    required String email,
    required String name,
    String? avatar,
  }) async {
    // Check if user already exists
    final existing = await getUserByEmail(email);
    if (existing != null) {
      throw Exception('User with this email already exists');
    }

    final user = User(
      email: email,
      name: name,
      avatar: avatar,
      isVerified: true,
    );

    await _usersBox.put(user.id, user.toMap());
    _currentUser = user;
    await _currentUserBox.put('userId', user.id);

    return user;
  }

  /// Login user
  Future<User?> login({required String email}) async {
    final user = await getUserByEmail(email);

    if (user != null) {
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      await _usersBox.put(user.id, updatedUser.toMap());
      _currentUser = updatedUser;
      await _currentUserBox.put('userId', user.id);
      return updatedUser;
    }

    return null;
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    final value = _usersBox.get(id);
    if (value != null) {
      return User.fromMap(Map<String, dynamic>.from(value));
    }
    return null;
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    for (var value in _usersBox.values) {
      final user = User.fromMap(Map<String, dynamic>.from(value));
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }

  /// Get current logged in user
  User? getCurrentUser() {
    return _currentUser;
  }

  /// Update user profile
  Future<void> updateUser(User user) async {
    await _usersBox.put(user.id, user.toMap());
    _currentUser = user;
  }

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
    await _currentUserBox.delete('userId');
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _currentUser != null;
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    final users = <User>[];
    for (var value in _usersBox.values) {
      users.add(User.fromMap(Map<String, dynamic>.from(value)));
    }
    return users;
  }

  /// Delete user account
  Future<bool> deleteUser(String userId) async {
    if (_currentUser?.id == userId) {
      await logout();
    }
    await _usersBox.delete(userId);
    return true;
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    return await getUserByEmail(email) != null;
  }
}
