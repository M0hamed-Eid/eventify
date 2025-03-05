import 'package:cloud_firestore/cloud_firestore.dart';

import 'event.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String membershipStatus;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final NotificationSettings notificationSettings;
  final List<Event> savedEvents;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.membershipStatus,
    required this.createdAt,
    required this.lastLoginAt,
    required this.notificationSettings,
    required this.savedEvents,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      membershipStatus: data['membershipStatus'] ?? 'Non-Member',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      notificationSettings: NotificationSettings.fromMap(
          data['notificationSettings'] ?? {}),
      savedEvents: (data['savedEvents'] as List<dynamic>?)
          ?.map((e) => Event.fromFirestore(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'membershipStatus': membershipStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'notificationSettings': notificationSettings.toMap(),
      'savedEvents': savedEvents.map((e) => e.toMap()).toList(),
    };
  }

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    String? membershipStatus,
    DateTime? lastLoginAt,
    NotificationSettings? notificationSettings,
    List<Event>? savedEvents,
  }) {
    return UserProfile(
      uid: this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      savedEvents: savedEvents ?? this.savedEvents,
    );
  }

  // Add this to the UserProfile class
  factory UserProfile.create({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@')[0],
      photoURL: photoURL,
      membershipStatus: 'Non-Member',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      notificationSettings: NotificationSettings(
        emailNotifications: true,
        pushNotifications: true,
        eventReminders: true,
      ),
      savedEvents: [],
    );
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool eventReminders;

  NotificationSettings({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.eventReminders,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      eventReminders: map['eventReminders'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'eventReminders': eventReminders,
    };
  }

  NotificationSettings copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? eventReminders,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      eventReminders: eventReminders ?? this.eventReminders,
    );
  }

}

