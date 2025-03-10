import 'package:flutter/material.dart';
import '../../models/notification_item.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../admin/admin_dashboard.dart';
import '../calendar/calendar_screen.dart';
import '../calendar/event_calendar_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
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
    final userId = _authService.currentUser?.uid;

    final commonItems = [
      NavigationItem(
        icon: Icons.home,
        label: 'Home',
        screen: const HomeScreen(),
      ),
      NavigationItem(
        icon: Icons.calendar_today,
        label: 'Calendar',
        screen: const CalendarScreen(),
      ),
      NavigationItem(
        icon: Icons.person,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
      NavigationItem(
        iconBuilder: (context, color) => Stack(
          children: [
            Icon(Icons.notifications, color: color),
            if (userId != null)
              StreamBuilder<List<NotificationItem>>(
                stream: DatabaseService().getUserNotifications(userId),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data
                      ?.where((n) => !n.isRead)
                      .length ?? 0;

                  if (unreadCount == 0) return const SizedBox();

                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        label: 'Notifications',
        screen: NotificationsScreen(),
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

    final items = _navigationItems;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: items.map((item) => item.screen).toList(),
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
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: item.iconBuilder != null
                ? item.iconBuilder!(context, Colors.grey)
                : Icon(item.icon),
            activeIcon: item.iconBuilder != null
                ? item.iconBuilder!(context, Theme.of(context).primaryColor)
                : Icon(item.icon, color: Theme.of(context).primaryColor),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData? icon;
  final Widget Function(BuildContext, Color)? iconBuilder;
  final String label;
  final Widget screen;

  NavigationItem({
    this.icon,
    this.iconBuilder,
    required this.label,
    required this.screen,
  }) : assert(icon != null || iconBuilder != null);
}