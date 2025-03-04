// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'New Event: Stay Safe Online',
      message: 'A new event has been added that matches your interests.',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.newEvent,
      isRead: false,
    ),
    NotificationItem(
      title: 'Event Reminder',
      message: 'Your registered event "English Conversation Club" starts in 1 hour.',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.reminder,
      isRead: true,
    ),
    NotificationItem(
      title: 'Registration Confirmed',
      message: 'Your registration for "Future Focus" has been confirmed.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.confirmation,
      isRead: true,
    ),
    // Add more notifications as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to notification settings
              _navigateToNotificationSettings();
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
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

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
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

  void _toggleNotificationRead(NotificationItem notification) {
    setState(() {
      notification.isRead = !notification.isRead;
    });
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      _notifications.remove(notification);
    });
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }
    // Navigate based on notification type
    // Implement navigation logic here
  }

  void _navigateToNotificationSettings() {
    // Implement navigation to settings
  }
}

enum NotificationType {
  newEvent,
  reminder,
  confirmation,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    required this.isRead,
  });
}