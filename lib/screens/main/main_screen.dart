import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../calendar/event_calendar_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await _authService.getCurrentUserRole();
    if (mounted) {
      setState(() {
        _isAdmin = role == UserRole.admin;
        _isLoading = false;
      });
    }
  }

  List<NavigationItem> get _navigationItems {
    final commonItems = [
      NavigationItem(
        icon: Icons.home,
        label: 'Home',
        screen: const HomeScreen(),
      ),
      NavigationItem(
        icon: Icons.calendar_today,
        label: 'Calendar',
        screen: const EventCalendarScreen(),
      ),
      NavigationItem(
        icon: Icons.person,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];

    if (_isAdmin) {
      return [
        ...commonItems,
        NavigationItem(
          icon: Icons.admin_panel_settings,
          label: 'Admin',
          screen: const AdminDashboard(),
        ),
      ];
    }

    return commonItems;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navigationItems
            .map(
              (item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ),
        )
            .toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}