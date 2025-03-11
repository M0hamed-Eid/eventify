import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/models/event.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String membershipStatus;
  final List<String> savedEvents; // Store event IDs instead of Event objects
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.membershipStatus,
    required this.savedEvents,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['id'] ?? json['uid'], // Use 'uid' or 'id' depending on your Firestore structure
      email: json['email'] ?? '',
      displayName: json['full_name'] ?? '',
      photoURL: json['avatar_url'],
      membershipStatus: json['membership_status'] ?? 'Non-Member',
      savedEvents: List<String>.from(json['savedEvents'] ?? []), // Store event IDs
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate() // Convert Firestore Timestamp to DateTime
          : DateTime.now(), // Default to current time if not provided
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate() // Convert Firestore Timestamp to DateTime
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'membershipStatus': membershipStatus,
      'savedEvents': savedEvents, // Store event IDs
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Firestore Timestamp
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!) // Convert DateTime to Firestore Timestamp
          : null,
    };
  }
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? membershipStatus,
    List<String>? savedEvents,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      savedEvents: savedEvents ?? this.savedEvents,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}