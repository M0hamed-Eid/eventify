import 'package:flutter/material.dart';

import '../../models/notification_item.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../events/event_details_screen.dart';
import '../settings/notification_settings_screen.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _databaseService.markAllNotificationsAsRead(userId);
      }
    } catch (e) {
      _showErrorSnackBar('Error marking notifications as read: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? null : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark',
              child: Text('Mark as read/unread'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'mark') {
              _toggleNotificationRead(notification);
            } else if (value == 'delete') {
              _deleteNotification(notification);
            }
          },
        ),
        onTap: () {
          // Handle notification tap
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Customize this based on your needs
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newEvent:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.confirmation:
        return Colors.green;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newEvent:
        return Icons.event_available;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.confirmation:
        return Icons.check_circle;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToNotificationSettings(context),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _databaseService.getUserNotifications(_authService.currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh will happen automatically with StreamBuilder
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
    );
  }

  // ... (keep your existing helper methods)

  Future<void> _toggleNotificationRead(NotificationItem notification) async {
    try {
      await _databaseService.toggleNotificationRead(notification.id);
    } catch (e) {
      _showErrorSnackBar('Error updating notification: $e');
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      await _databaseService.deleteNotification(notification.id);
    } catch (e) {
      _showErrorSnackBar('Error deleting notification: $e');
    }
  }

  Future<void> _handleNotificationTap(NotificationItem notification) async {
    try {
      if (!notification.isRead) {
        await _databaseService.markNotificationAsRead(notification.id);
      }

      if (notification.eventId != null) {
        final event = await _databaseService.getEvent(notification.eventId!);
        if (event != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error handling notification: $e');
    }
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }
}