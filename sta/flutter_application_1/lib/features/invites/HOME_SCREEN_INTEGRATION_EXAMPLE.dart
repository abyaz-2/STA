import 'package:flutter/material.dart';
import '../invites/invite_management_screen.dart';
import '../invites/invite_utils.dart';

/// Example: How to add Invites tab to Home Screen
/// 
/// This file shows how to integrate the InviteManagementScreen into your
/// HomeScreen navigation. You can use this as a guide for updating your
/// home_screen.dart file.

class HomeScreenWithInvitesExample extends StatefulWidget {
  const HomeScreenWithInvitesExample({super.key});

  @override
  State<HomeScreenWithInvitesExample> createState() => _HomeScreenWithInvitesExampleState();
}

class _HomeScreenWithInvitesExampleState extends State<HomeScreenWithInvitesExample> {
  int _currentIndex = 0;
  int _pendingInvitesCount = 0;

  // Example list of screens - add InviteManagementScreen here
  final List<Widget> _screens = [
    // const DashboardScreen(),
    // const SubscriptionListScreen(),
    // const GroupsScreen(),
    // const AnalyticsScreen(),
    const InviteManagementScreen(),  // Add this line
  ];

  @override
  void initState() {
    super.initState();
    _updateInvitesCount();
  }

  void _updateInvitesCount() async {
    final count = await InviteUtils.getPendingInvitesCount('current_user@example.com');
    setState(() => _pendingInvitesCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh invites count when navigating to invites tab
          if (index == 4) {
            _updateInvitesCount();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Subscriptions',
          ),
          const NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          const NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          // Add this destination for Invites
          NavigationDestination(
            icon: _pendingInvitesCount > 0
                ? Badge(
                    label: Text('$_pendingInvitesCount'),
                    child: const Icon(Icons.mail_outlined),
                  )
                : const Icon(Icons.mail_outlined),
            selectedIcon: _pendingInvitesCount > 0
                ? Badge(
                    label: Text('$_pendingInvitesCount'),
                    child: const Icon(Icons.mail),
                  )
                : const Icon(Icons.mail),
            label: 'Invites',
          ),
        ],
      ),
    );
  }
}
