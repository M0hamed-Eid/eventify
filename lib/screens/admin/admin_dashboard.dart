import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../utils/route_guard.dart';
import '../events/event_screen.dart';
import '../home/home_screen.dart';
import 'manage_events_screen.dart';
import 'send_notification_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RouteGuard(
      allowedRoles: [UserRole.admin],
      fallbackRoute: const HomeScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              'Add Event',
              Icons.add_circle,
              Colors.blue,
                  () => _navigateToAddEvent(context),
            ),
            _buildDashboardCard(
              'Manage Events',
              Icons.event,
              Colors.green,
                  () => _navigateToManageEvents(context),
            ),
            _buildDashboardCard(
              'Send Notification',
              Icons.notifications,
              Colors.orange,
                  () => _navigateToSendNotification(context),
            ),
            _buildDashboardCard(
              'Analytics',
              Icons.analytics,
              Colors.purple,
                  () => _showAnalytics(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddEvent(BuildContext context) async {
    final Event? newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    );

    if (newEvent != null) {
      try {
        // Event was added successfully, send notification to users
        //await _notificationService.sendEventNotification(newEvent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added and notification sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send notification: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  void _showAnalytics(BuildContext context) {
    // Implement analytics view
  }
}