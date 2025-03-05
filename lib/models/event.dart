import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final bool isOnline;
  final bool isAccMembersOnly;
  final String timeRange;
  final String? registrationLink;
  final String? meetingId;
  final String? passcode;
  final String? imageUrl;
  final String? presenter;
  final String? presenterTitle;
  final List<String> guidelines;
  final String category;
  final String? series;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.isOnline,
    required this.isAccMembersOnly,
    required this.timeRange,
    this.registrationLink,
    this.meetingId,
    this.passcode,
    this.imageUrl,
    this.presenter,
    this.presenterTitle,
    required this.guidelines,
    required this.category,
    this.series,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      isOnline: data['isOnline'] ?? false,
      isAccMembersOnly: data['isAccMembersOnly'] ?? false,
      timeRange: data['timeRange'] ?? '',
      registrationLink: data['registrationLink'],
      meetingId: data['meetingId'],
      passcode: data['passcode'],
      presenter: data['presenter'],
      presenterTitle: data['presenterTitle'],
      guidelines: data['guidelines'] != null
          ? List<String>.from(data['guidelines'])
          : [],
      category: data['category'] ?? '',
      series: data['series'],
    );
  }

  // Also update toMap method to match
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
      'meetingId': meetingId,
      'passcode': passcode,
      'presenter': presenter,
      'presenterTitle': presenterTitle,
      'guidelines': guidelines,
      'category': category,
      'series': series,
    };
  }

}