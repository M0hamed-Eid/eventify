import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import '../models/workshop.dart';
import 'package:intl/intl.dart';

import 'notification_service.dart';


class DatabaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  // Add this method to send notifications to all users
  Future<void> _sendEventNotification(Event event) async {
    try {
      // Create notification message
      final message = _createEventNotificationMessage(event);

      // Send push notification
      await _notificationService.sendCustomNotification(
        title: 'New Event: ${event.title}',
        body: message,
        data: {
          'type': 'event',
          'eventId': event.id,
          'action': 'view_event',
        },
      );

      // Create notifications in Firestore for all users
      await _createEventNotificationsForUsers(event, message);

      // Update event with notification status
      await _firestore
          .collection('events')
          .doc(event.id)
          .update({
        'notificationSent': true,
        'notificationSentAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      _logger.e('Error sending event notification: $e');
      throw 'Error sending event notification: $e';
    }
  }

  String _createEventNotificationMessage(Event event) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final date = dateFormat.format(event.dateTime);

    String message = 'Join us on $date for ${event.title}. ';

    if (event.isOnline) {
      message += 'This event will be held online via Zoom. ';
    } else {
      message += 'This event will be held at ${event.location}. ';
    }

    if (event.isAccMembersOnly) {
      message += 'This event is exclusive to ACC members. ';
    }

    message += 'Time: ${event.timeRange}';

    return message;
  }


  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw 'Profile not found';
      }

      // Get saved events
      final savedEventsSnapshot = await _firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
          .get();

      final savedEventIds = savedEventsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      // Convert Firestore Timestamps to DateTime or String
      final profileData = doc.data()!;
      final convertedData = {
        ...profileData,
        'created_at': profileData['created_at'] is Timestamp
            ? (profileData['created_at'] as Timestamp).toDate().toString() // Convert to String
            : profileData['created_at'].toString(), // Fallback to String
        'updated_at': profileData['updated_at'] is Timestamp
            ? (profileData['updated_at'] as Timestamp).toDate().toString() // Convert to String
            : profileData['updated_at'].toString(), // Fallback to String
        'id': doc.id,
        'saved_events': savedEventIds,
      };

      return UserProfile.fromJson(convertedData);
    } catch (e) {
      _logger.e('Error fetching user profile: $e');
      throw 'Error fetching user profile: $e';
    }
  }

  Stream<UserProfile> getUserProfileStream(String userId) {
    return _firestore
        .collection('profiles')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        throw 'Profile not found';
      }

      // Get saved events
      final savedEventsSnapshot = await _firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
          .get();

      final savedEventIds = savedEventsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      // Convert Firestore Timestamps to DateTime or String
      final profileData = doc.data()!;
      final convertedData = {
        ...profileData,
        'created_at': profileData['created_at'] is Timestamp
            ? (profileData['created_at'] as Timestamp).toDate().toString() // Convert to String
            : profileData['created_at'].toString(), // Fallback to String
        'updated_at': profileData['updated_at'] is Timestamp
            ? (profileData['updated_at'] as Timestamp).toDate().toString() // Convert to String
            : profileData['updated_at'].toString(), // Fallback to String
        'id': doc.id,
        'saved_events': savedEventIds,
      };

      return UserProfile.fromJson(convertedData);
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('profiles')
          .doc(userId)
          .update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());      _logger.e('Error updating profile: $e');
      throw 'Error updating profile: $e';
    }
  }

  Future<String> uploadProfilePicture(String userId, XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = 'avatar.$fileExt';
      final filePath = 'avatars/$userId/$fileName';

      // Upload to Supabase storage
      await _supabase.storage
          .from('avatars')
          .uploadBinary(filePath, bytes);

      // Get the public URL
      final imageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update profile with new image URL
      await updateUserProfile(userId, {'avatar_url': imageUrl});

      return imageUrl;
    } catch (e) {
      _logger.e('Error uploading profile picture: $e');
      throw 'Error uploading profile picture: $e';
    }
  }

  Future<void> createUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('profiles')
          .doc(userId)
          .set({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Error creating user profile: $e');
      throw 'Error creating user profile: $e';
    }
  }

  Future<void> removeSavedEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      _logger.e('Error removing saved event: $e');
      throw 'Error removing saved event: $e';
    }
  }

  Future<void> saveEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('saved_events')
          .add({
        'userId': userId,
        'eventId': eventId,
        'saved_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Error saving event: $e');
      throw 'Error saving event: $e';
    }
  }

  // Helper method to delete profile picture
  Future<void> deleteProfilePicture(String userId, String fileName) async {
    try {
      await _supabase.storage
          .from('avatars')
          .remove(['avatars/$userId/$fileName']);
    } catch (e) {
      _logger.e('Error deleting profile picture: $e');
      throw 'Error deleting profile picture: $e';
    }
  }

  Future<Event> createEvent(Event event) async {
  try {
  // Create the event
  final docRef = await _firestore.collection('events').add(event.toMap());
  final doc = await docRef.get();
  final createdEvent = Event.fromFirestore(doc);

  // Send notification
  await _sendEventNotification(createdEvent);

  return createdEvent;
  } catch (e) {
  _logger.e('Error creating event: $e');
  throw 'Error creating event: $e';
  }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _firestore.collection('events').doc(eventId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<List<Event>> getEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch events: $e';
    }
  }

  Stream<List<Event>> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Event Registrations
  Future<void> registerForEvent(String eventId, String userId) async {
    final registrationData = {
      'eventId': eventId,
      'userId': userId,
      'status': 'confirmed',
      'registeredAt': FieldValue.serverTimestamp(),
      'attendanceStatus': null,
    };

    WriteBatch batch = _firestore.batch();

    // Create registration
    final registrationRef = _firestore.collection('registrations').doc();
    batch.set(registrationRef, registrationData);

    // Update event participants count
    final eventRef = _firestore.collection('events').doc(eventId);
    batch.update(eventRef, {
      'currentParticipants': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Notifications
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'eventId': eventId,
      'dateTime': FieldValue.serverTimestamp(), // Use server timestamp
      'isRead': false,
    });
  }

  // Contact Messages
  Future<void> submitContactMessage(Map<String, dynamic> messageData) async {
    await _firestore.collection('contactMessages').add({
      ...messageData,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'new',
    });
  }

/*
  Stream<List<String>> getCategories() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['name'] as String).toList());
  }
*/

  // Get categories as a stream
  Stream<List<String>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc['name'] as String).toList());
  }




  Future<void> _createEventNotificationsForUsers(Event event, String message) async {
    try {
      // Create single notification for all users
      await _firestore
          .collection('notifications')
          .add({
        'title': 'New Event: ${event.title}',
        'message': message,
        'type': 'event',
        'eventId': event.id,
        'dateTime': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'action': 'view_event',
          'eventId': event.id,
        },
        'readBy': [], // Array to track which users have read the notification
      });
    } catch (e) {
      _logger.e('Error creating notifications: $e');
      throw 'Error creating notifications: $e';
    }
  }

  Stream<List<NotificationItem>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        return NotificationItem.fromFirestore(
          doc,
          isRead: readBy.contains(userId), // Check if current user has read it
        );
      }).toList();
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
      'readBy': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]), // Add user to readBy array
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final notifications = await _firestore
        .collection('notifications')
        .get();

    final batch = _firestore.batch();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }

    await batch.commit();
  }

  Future<void> toggleNotificationRead(String notificationId) async {
    final doc = await _firestore.collection('notifications').doc(notificationId).get();
    final currentState = doc.data()?['isRead'] ?? false;
    await doc.reference.update({'isRead': !currentState});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<Event?> getEvent(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    return doc.exists ? Event.fromFirestore(doc) : null;
  }



  // ------------------------------------------------------
// lib/services/database_service.dart

  Stream<List<Event>> getTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('events')
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThan: endOfDay)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Stream<List<Event>> getUpcomingEvents() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startOfTomorrow = DateTime(
        tomorrow.year, tomorrow.month, tomorrow.day);

    return _firestore
        .collection('events')
        .where('dateTime', isGreaterThanOrEqualTo: startOfTomorrow)
        .orderBy('dateTime')
        .limit(5)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Stream<List<Workshop>> getWorkshops() {
    return _firestore
        .collection('workshops')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Workshop.fromFirestore(doc)).toList());
  }

  Future<List<Event>> searchEvents(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final snapshot = await _firestore.collection('events').get();

    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) =>
    event.title.toLowerCase().contains(queryLower) ||
        event.description.toLowerCase().contains(queryLower))
        .toList();
  }

}