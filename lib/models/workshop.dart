import 'package:cloud_firestore/cloud_firestore.dart';

class Workshop {
  final String id;
  final String title;
  final String status;
  final String schedule;
  final String? description;
  final String? location;
  final DateTime? dateTime;

  Workshop({
    required this.id,
    required this.title,
    required this.status,
    required this.schedule,
    this.description,
    this.location,
    this.dateTime,
  });

  factory Workshop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    print('Workshop Document Data: $data'); // Debug print

    return Workshop(
      id: doc.id,
      title: data['title'] ?? 'Untitled Workshop',
      status: data['status'] ?? 'Upcoming',
      schedule: data['schedule'] ?? 'TBD',
      description: data['description'],
      location: data['location'],
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'schedule': schedule,
      'description': description,
      'location': location,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
    };
  }
}