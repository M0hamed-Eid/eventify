import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../models/notification_item.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../admin/admin_dashboard.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _checkRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkRole() async {
    try {
      final role = await _authService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _isAdmin = role == UserRole.admin;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking user role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<NavigationItem> get _navigationItems {
    final userId = _authService.currentUser?.uid;

    final commonItems = [
      NavigationItem(
        icon: Icons.home_rounded,
        label: 'Home',
        screen: const HomeScreen(),
        activeColor: Colors.blue[700]!,
      ),
      NavigationItem(
        icon: Icons.calendar_today_rounded,
        label: 'Calendar',
        screen: const CalendarScreen(),
        activeColor: Colors.green[700]!,
      ),
      NavigationItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        screen: const ProfileScreen(),
        activeColor: Colors.purple[700]!,
      ),
      NavigationItem(
        iconBuilder: (context, color) => _buildNotificationIcon(userId, color),
        label: 'Notifications',
        screen: NotificationsScreen(),
        activeColor: Colors.orange[700]!,
      ),
    ];

    if (_isAdmin) {
      return [
        ...commonItems,
        NavigationItem(
          icon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
          screen: const AdminDashboard(),
          activeColor: Colors.red[700]!,
        ),
      ];
    }

    return commonItems;
  }

  Widget _buildNotificationIcon(String? userId, Color color) {
    if (userId == null) return Icon(Icons.notifications_rounded, color: color);

    return Stack(
      children: [
        Icon(Icons.notifications_rounded, color: color),
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
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
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
      bottomNavigationBar: _buildBottomNavigationBar(items),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildBottomNavigationBar(List<NavigationItem> items) {
    return SalomonBottomBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: items.map((item) {
        return SalomonBottomBarItem(
          icon: item.iconBuilder != null
              ? item.iconBuilder!(context, Colors.grey)
              : Icon(item.icon),
          title: Text(
            item.label,
            style: TextStyle(
              color: item.activeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          activeIcon: item.iconBuilder != null
              ? item.iconBuilder!(context, item.activeColor)
              : Icon(item.icon, color: item.activeColor),
        );
      }).toList(),
    );
  }
}

class NavigationItem {
  final IconData? icon;
  final Widget Function(BuildContext, Color)? iconBuilder;
  final String label;
  final Widget screen;
  final Color activeColor;

  NavigationItem({
    this.icon,
    this.iconBuilder,
    required this.label,
    required this.screen,
    required this.activeColor,
  }) : assert(icon != null || iconBuilder != null);
}