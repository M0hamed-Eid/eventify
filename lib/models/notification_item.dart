import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? eventId;
  final DateTime dateTime;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    required this.dateTime,
    required this.isRead,
    this.data,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc, {required bool isRead}) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      eventId: data['eventId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'eventId': eventId,
      'dateTime': Timestamp.fromDate(dateTime),
      'isRead': isRead,
      'data': data,
    };
  }
}