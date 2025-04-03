import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

import '../../models/event.dart';
import '../../models/workshop.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../utils/route_guard.dart';
import '../home/home_screen.dart';
import 'add_event_screen.dart';
import 'add_workshop_screen.dart';
import 'manage_events_screen.dart';
import 'manage_workshop_screen.dart';
import 'send_notification_screen.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  // Dashboard statistics
  int _totalEvents = 0;
  int _totalUsers = 0;
  int _upcomingEvents = 0;

  int _totalWorkshops = 0;
  int _upcomingWorkshops = 0;



  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  void _navigateToAddWorkshop(BuildContext context) async {
    final Workshop? newWorkshop = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWorkshopScreen(),
      ),
    );

    if (newWorkshop != null) {
      _loadDashboardStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workshop added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToManageWorkshops(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageWorkshopsScreen(),
      ),
    );
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    try {
      final events = await _databaseService.getEvents();
      final workshops = await _databaseService.getWorkshops().first; // Use .first to get the first snapshot
      final users = await _databaseService.getTotalUsers();

      setState(() {
        _totalEvents = events.length;
        _totalWorkshops = workshops.length; // Now workshops is a List<Workshop>
        _totalUsers = users;
        _upcomingEvents = events.where((event) =>
            event.dateTime.isAfter(DateTime.now())).length;
        _upcomingWorkshops = workshops.where((workshop) =>
        workshop.dateTime?.isAfter(DateTime.now()) ?? false).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load dashboard stats: $e');
    }
  }

  // If you want real-time updates
  void _setupUserCountListener() {
    _databaseService.getTotalUsersStream().listen((count) {
      setState(() {
        _totalUsers = count;
      });
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteGuard(
      allowedRoles: [UserRole.admin],
      fallbackRoute: const HomeScreen(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildDashboardContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardStats,
        ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStatsSection(),
              const SizedBox(height: 16),
              _buildAdminActionsGrid(),
              const SizedBox(height: 16),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatItem('Total Events', _totalEvents.toString(), Icons.event),
              const SizedBox(width: 24),
              _buildStatItem('Total Users', _totalUsers.toString(), Icons.people),
              const SizedBox(width: 24),
              _buildStatItem('Upcoming Events', _upcomingEvents.toString(), Icons.calendar_today),
              const SizedBox(width: 24),
              _buildStatItem('Total Workshops', _totalWorkshops.toString(), Icons.workspaces),
              const SizedBox(width: 24),
              _buildStatItem('Upcoming Workshops', _upcomingWorkshops.toString(), Icons.workspaces_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700], size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionsGrid() {
    final actions = [
      AdminAction(
        title: 'Add Event',
        icon: Icons.add_circle,
        color: Colors.blue,
        onTap: () => _navigateToAddEvent(context),
      ),
      AdminAction(
        title: 'Manage Events',
        icon: Icons.event,
        color: Colors.green,
        onTap: () => _navigateToManageEvents(context),
      ),
      AdminAction(
        title: 'Add Workshop',
        icon: Icons.workspaces,
        color: Colors.blue,
        onTap: () => _navigateToAddWorkshop(context),
      ),
      AdminAction(
        title: 'Manage Workshops',
        icon: Icons.workspaces_outlined,
        color: Colors.green,
        onTap: () => _navigateToManageWorkshops(context),
      ),
      AdminAction(
        title: 'Send Notification',
        icon: Icons.notifications,
        color: Colors.orange,
        onTap: () => _navigateToSendNotification(context),
      ),
      AdminAction(
        title: 'User Management',
        icon: Icons.people_alt,
        color: Colors.purple,
        onTap: () => _navigateToUserManagement(context),
      ),
      AdminAction(
        title: 'Analytics',
        icon: Icons.analytics,
        color: Colors.red,
        onTap: () => _navigateToAnalytics(context),
      ),
      AdminAction(
        title: 'Settings',
        icon: Icons.settings,
        color: Colors.teal,
        onTap: () => _navigateToAdminSettings(context),
      ),
    ];

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildAdminActionCard(actions[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminActionCard(AdminAction action) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              size: 36,
              color: action.color,
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Implement recent activity list or placeholder
        const Card(
          child: ListTile(
            leading: Icon(Icons.event),
            title: Text('No recent activity'),
            subtitle: Text('Check back later for updates'),
          ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToAddEvent(BuildContext context) async {
    final Event? newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    );

    if (newEvent != null) {
      _loadDashboardStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToManageEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageEventsScreen(),
      ),
    );
  }

  void _navigateToSendNotification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SendNotificationScreen(),
      ),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _navigateToAdminSettings(BuildContext context) {
    // Implement admin settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin Settings Coming Soon')),
    );
  }
}

class AdminAction {
  final String title; 
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  AdminAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}