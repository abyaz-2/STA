import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/subscriptions/subscription_list_screen.dart';
import '../features/groups/groups_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../services/profile_service.dart';
import '../screens/add_subscription_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ProfileService _profileService = ProfileService();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SubscriptionListScreen(),
    const GroupsScreen(),
    const AnalyticsScreen(),
  ];

  static const _accent = Color(0xFF8BC34A);

  @override
  Widget build(BuildContext context) {
    final user = _profileService.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F3),
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddSubscriptionScreen(),
                  ),
                );
                setState(() {}); // Refresh to show new subscription
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  currentIndex: _currentIndex,
                  onTap: _setIndex,
                  accent: _accent,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Subs',
                  index: 1,
                  currentIndex: _currentIndex,
                  onTap: _setIndex,
                  accent: _accent,
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  activeIcon: Icons.group,
                  label: 'Groups',
                  index: 2,
                  currentIndex: _currentIndex,
                  onTap: _setIndex,
                  accent: _accent,
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Analytics',
                  index: 3,
                  currentIndex: _currentIndex,
                  onTap: _setIndex,
                  accent: _accent,
                ),
                // Avatar nav item
                GestureDetector(
                  onTap: () {
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: user),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _accent,
                        child: Text(
                          user != null ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int i) => setState(() => _currentIndex = i);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accent;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? accent : const Color(0xFF9E9E9E),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? accent : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
