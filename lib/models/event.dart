import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;
  final bool isOnline;
  final bool isAccMembersOnly;
  final String timeRange;
  final String? registrationLink;
  final String category; // Add this field

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    required this.isOnline,
    required this.isAccMembersOnly,
    required this.timeRange,
    this.registrationLink,
    required this.category, // Add this parameter
  });

  // Update fromFirestore method
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'],
      imageUrl: data['imageUrl'],
      isOnline: data['isOnline'],
      isAccMembersOnly: data['isAccMembersOnly'],
      timeRange: data['timeRange'],
      registrationLink: data['registrationLink'],
      category: data['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'isAccMembersOnly': isAccMembersOnly,
      'timeRange': timeRange,
      'registrationLink': registrationLink,
      'category': category,
    };
  }
}