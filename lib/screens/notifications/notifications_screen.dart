import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/notification_item.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../events/event_details_screen.dart';
import 'notification_tile.dart';


class NotificationsScreen extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _databaseService = DatabaseService();

  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(context, userId),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _databaseService.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorView(context, snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return _buildEmptyView();
          }

          return _buildNotificationsList(context, notifications);
        },
      ),
    );
  }

  Widget _buildNotificationsList(
      BuildContext context,
      List<NotificationItem> notifications,
      ) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) => _confirmDelete(context),
          onDismissed: (_) => _deleteNotification(context, notification),
          child: NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(context, notification),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading notifications:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Refresh the screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(
      BuildContext context,
      NotificationItem notification,
      ) async {
    // Mark as read
    await _databaseService.markNotificationAsRead(notification.id);

    // Handle navigation based on notification type
    if (notification.type == 'event' && notification.eventId != null) {
      final event = await _databaseService.getEvent(notification.eventId!);
      if (event != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteNotification(
      BuildContext context,
      NotificationItem notification,
      ) async {
    try {
      await _databaseService.deleteNotification(notification.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notification: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead(BuildContext context, String userId) async {
    try {
      await _databaseService.markAllNotificationsAsRead(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notifications as read: $e')),
        );
      }
    }
  }
}