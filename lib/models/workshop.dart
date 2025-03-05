import 'package:cloud_firestore/cloud_firestore.dart';

class Workshop {
  final String id;
  final String title;
  final String status;
  final String schedule;

  Workshop({
    required this.id,
    required this.title,
    required this.status,
    required this.schedule,
  });

  factory Workshop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workshop(
      id: doc.id,
      title: data['title'] ?? '',
      status: data['status'] ?? '',
      schedule: data['schedule'] ?? '',
    );
  }
}