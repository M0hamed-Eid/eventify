import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newEvent,
  reminder,
  confirmation,
}

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? eventId;
  final DateTime dateTime;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    required this.dateTime,
    required this.isRead,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.newEvent,
      ),
      isRead: data['isRead'] ?? false,
      eventId: data['eventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'eventId': eventId,
    };
  }
}