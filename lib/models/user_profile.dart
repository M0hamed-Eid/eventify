import 'package:eventify/models/event.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String membershipStatus;
  final List<Event> savedEvents;
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
      uid: json['id'],
      email: json['email'] ?? '',
      displayName: json['full_name'] ?? '',
      photoURL: json['avatar_url'],
      membershipStatus: json['membership_status'] ?? 'Non-Member',
      savedEvents: List<Event>.from(json['saved_events'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': displayName,
      'avatar_url': photoURL,
      'membership_status': membershipStatus,
      'saved_events': savedEvents,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? membershipStatus,
    List<Event>? savedEvents,
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