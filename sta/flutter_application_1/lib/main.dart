import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/invite_service.dart';
import 'services/category_service.dart';
import 'services/profile_service.dart';
import 'screens/login_signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  await InviteService().init();
  await CategoryService().init();
  await ProfileService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.purpleAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final profileService = ProfileService();
    final isLoggedIn = profileService.isLoggedIn();
    return isLoggedIn ? const HomeScreen() : const LoginSignupScreen();
  }
}
