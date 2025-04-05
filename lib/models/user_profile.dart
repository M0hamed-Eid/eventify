import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String membershipStatus;
  final List<String> savedEvents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? bio; // New field
  final List<String> following; // New field
  final List<String> followers; // New field

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.membershipStatus,
    required this.savedEvents,
    required this.createdAt,
    this.updatedAt,
    this.bio,
    List<String>? following,
    List<String>? followers,
  })  : following = following ?? [],
        followers = followers ?? [];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['id'] ?? json['uid'],
      email: json['email'] ?? '',
      displayName: json['full_name'] ?? '',
      photoURL: json['avatar_url'],
      membershipStatus: json['membership_status'] ?? 'Non-Member',
      savedEvents: List<String>.from(json['savedEvents'] ?? []),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      bio: json['bio'],
      following: List<String>.from(json['following'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'membershipStatus': membershipStatus,
      'savedEvents': savedEvents,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'bio': bio,
      'following': following,
      'followers': followers,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? membershipStatus,
    List<String>? savedEvents,
    String? bio,
    List<String>? following,
    List<String>? followers,
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
      bio: bio ?? this.bio,
      following: following ?? this.following,
      followers: followers ?? this.followers,
    );
  }
}