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



  Future<List<Event>> getEventsByIds(List<String> eventIds) async {
    try {
      if (eventIds.isEmpty) return [];

      final eventsSnapshot = await _firestore
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      return eventsSnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Error fetching events by IDs: $e');
      throw 'Failed to fetch events by IDs: $e';
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('profiles')
          .get();

      return usersSnapshot.docs
          .map((doc) => UserProfile.fromJson({
        ...doc.data(),
        'id': doc.id,
      }))
          .toList();
    } catch (e) {
      _logger.e('Error fetching users: $e');
      throw 'Failed to fetch users: $e';
    }
  }

  // Get event registration trends
  Future<Map<String, int>> getEventRegistrationTrends() async {
    try {
      final now = DateTime.now();
      final trends = <String, int>{};

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final eventsSnapshot = await _firestore
            .collection('events')
            .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
            .where('dateTime', isLessThan: endOfDay)
            .get();

        trends[DateFormat('MM-dd').format(date)] = eventsSnapshot.docs.length;
      }

      return trends;
    } catch (e) {
      _logger.e('Error fetching event registration trends: $e');
      throw 'Failed to fetch event registration trends: $e';
    }
  }

  // Get user registration trends
  Future<Map<String, int>> getUserRegistrationTrends() async {
    try {
      final now = DateTime.now();
      final trends = <String, int>{};

      // Last 7 days registration count
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final usersSnapshot = await _firestore
            .collection('profiles')
            .where('created_at', isGreaterThanOrEqualTo: startOfDay)
            .where('created_at', isLessThan: endOfDay)
            .get();

        trends[DateFormat('MM-dd').format(date)] = usersSnapshot.docs.length;
      }

      return trends;
    } catch (e) {
      _logger.e('Error fetching user registration trends: $e');
      throw 'Failed to fetch user registration trends: $e';
    }
  }

// Get user distribution by various attributes
  Future<Map<String, int>> getUserDistribution(String attribute) async {
    try {
      final usersSnapshot = await _firestore
          .collection('profiles')
          .get();

      final distribution = <String, int>{};

      for (var doc in usersSnapshot.docs) {
        final value = doc.data()[attribute];
        if (value != null) {
          distribution[value] = (distribution[value] ?? 0) + 1;
        }
      }

      return distribution;
    } catch (e) {
      _logger.e('Error fetching user distribution: $e');
      throw 'Failed to fetch user distribution: $e';
    }
  }

  Future<int> getTotalUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('profiles')
          .get();

      return usersSnapshot.docs.length;
    } catch (e) {
      _logger.e('Error fetching total users: $e');
      throw 'Failed to fetch total users: $e';
    }
  }

// Optional: If you want to get total users with additional filtering
  Future<int> getActiveUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('profiles')
          .where('status', isEqualTo: 'active') // Assuming you have a status field
          .get();

      return usersSnapshot.docs.length;
    } catch (e) {
      _logger.e('Error fetching active users: $e');
      throw 'Failed to fetch active users: $e';
    }
  }

// Optional: Get users by membership status
  Future<int> getUsersByMembershipStatus(String status) async {
    try {
      final usersSnapshot = await _firestore
          .collection('profiles')
          .where('membershipStatus', isEqualTo: status)
          .get();

      return usersSnapshot.docs.length;
    } catch (e) {
      _logger.e('Error fetching users by membership status: $e');
      throw 'Failed to fetch users by membership status: $e';
    }
  }

// Stream version for real-time updates
  Stream<int> getTotalUsersStream() {
    return _firestore
        .collection('profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<bool> isUserRegisteredForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final registrationSnapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return registrationSnapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking event registration: $e');
      return false;
    }
  }
  // Unregister from an event
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      // Start a batch write to ensure atomicity
      WriteBatch batch = _firestore.batch();

      // Find and delete the registration
      final registrationQuery = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      // Delete registration documents
      for (var doc in registrationQuery.docs) {
        batch.delete(doc.reference);
      }

      // Update event participants count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'currentParticipants': FieldValue.increment(-1),
      });

      // Commit the batch
      await batch.commit();

      // Create a notification about unregistration
      await createNotification(
        userId: userId,
        title: 'Event Unregistration',
        message: 'You have been unregistered from the event.',
        type: 'event_unregistration',
        eventId: eventId,
      );
    } catch (e) {
      _logger.e('Error unregistering from event: $e');
      throw 'Failed to unregister from event: $e';
    }
  }

  // Get registered events for a user
  Stream<List<Event>> getUserRegisteredEvents(String userId) {
    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .asyncMap((registrationsSnapshot) async {
      // Extract event IDs from registrations
      final eventIds = registrationsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      // If no registrations, return empty list
      if (eventIds.isEmpty) return [];

      // Fetch events for these IDs
      final eventsSnapshot = await _firestore
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      return eventsSnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    });
  }

// Get participants for an event
  Future<List<UserProfile>> getEventParticipants(String eventId) async {
    try {
      // First, get registration documents for this event
      final registrationsSnapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      // Extract user IDs
      final userIds = registrationsSnapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toList();

      // Fetch user profiles
      final participantsSnapshot = await _firestore
          .collection('profiles')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return participantsSnapshot.docs
          .map((doc) => UserProfile.fromJson({
        ...doc.data(),
        'id': doc.id,
      }))
          .toList();
    } catch (e) {
      _logger.e('Error fetching event participants: $e');
      throw 'Failed to fetch event participants: $e';
    }
  }
  // Check event registration status with more details
  Future<Map<String, dynamic>> checkEventRegistrationStatus(
      String eventId,
      String userId,
      ) async {
    try {
      final registrationSnapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      if (registrationSnapshot.docs.isEmpty) {
        return {
          'isRegistered': false,
          'status': null,
        };
      }

      final registrationData = registrationSnapshot.docs.first.data();
      return {
        'isRegistered': true,
        'status': registrationData['status'],
        'registeredAt': registrationData['registeredAt'],
      };
    } catch (e) {
      _logger.e('Error checking registration status: $e');
      throw 'Failed to check registration status: $e';
    }
  }



  // Add this method to send notifications to all users
  Future<void> _sendEventNotification(Event event) async {
    try {
      // Create notification message
      final message = _createEventNotificationMessage(event);

      // Send push notification
      await _notificationService.sendCustomNotification(
        title: event.title,
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
        throw 'Profile not found for userId: $userId';
      }

      // Get saved events
      final savedEventsSnapshot = await _firestore
          .collection('saved_events')
          .where('userId', isEqualTo: userId)
          .get();

      final savedEventIds = savedEventsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      // Convert Firestore Timestamps to DateTime or provide default values
      final profileData = doc.data()!;
      final convertedData = {
        ...profileData,
        'created_at': profileData['created_at'] != null
            ? (profileData['created_at'] as Timestamp).toDate().toString() // Convert to String
            : DateTime.now().toString(), // Default value if null
        'updated_at': profileData['updated_at'] != null
            ? (profileData['updated_at'] as Timestamp).toDate().toString() // Convert to String
            : DateTime.now().toString(), // Default value if null
        'id': doc.id,
        'saved_events': savedEventIds,
      };

      return UserProfile.fromJson(convertedData);
    } catch (e) {
      _logger.e('Error fetching user profile for userId: $userId: $e');
      throw 'Error fetching user profile for userId: $userId: $e';
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

  Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      // Update the profile
      await _firestore
          .collection('profiles')
          .doc(userId)
          .update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Fetch and return the updated profile
      final updatedDoc = await _firestore.collection('profiles').doc(userId).get();
      return updatedDoc.data() ?? {};
    } catch (e) {
      _logger.e('Error updating profile for userId: $userId: $e');
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

  Future<void> ensureUserProfileExists(String userId, Map<String, dynamic> initialData) async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc(userId)
          .get();

      if (!doc.exists) {
        await createUserProfile(userId, initialData);
        _logger.i('Created new profile for userId: $userId');
      }
    } catch (e) {
      _logger.e('Error ensuring user profile exists for userId: $userId: $e');
      throw 'Error ensuring user profile exists for userId: $userId: $e';
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
      await _firestore.collection('profiles').doc(userId).update({
        'savedEvents': FieldValue.arrayRemove([eventId]),
      });
    } catch (e) {
      _logger.e('Error removing saved event: $e');
      throw 'Failed to remove saved event: $e';
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

  // Enhanced register for event method with waitlist support
  Future<String> registerForEvent(String eventId, String userId) async {
    try {
      // Get the event details
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final eventData = eventDoc.data();

      if (eventData == null) {
        throw 'Event not found';
      }

      final maxParticipants = eventData['maxParticipants'] ?? 50;
      final currentParticipants = eventData['currentParticipants'] ?? 0;

      // Check if event is full
      if (currentParticipants >= maxParticipants) {
        // Add to waitlist
        return await _addToWaitlist(eventId, userId);
      }

      // Proceed with normal registration
      WriteBatch batch = _firestore.batch();

      // Create registration
      final registrationRef = _firestore.collection('registrations').doc();
      batch.set(registrationRef, {
        'eventId': eventId,
        'userId': userId,
        'status': 'confirmed',
        'registeredAt': FieldValue.serverTimestamp(),
        'attendanceStatus': null,
      });

      // Update event participants count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'currentParticipants': FieldValue.increment(1),
      });

      // Commit batch
      await batch.commit();

      // Create notification
      await createNotification(
        userId: userId,
        title: 'Event Registration',
        message: 'You have been registered for the event.',
        type: 'event_registration',
        eventId: eventId,
      );

      return 'confirmed';
    } catch (e) {
      _logger.e('Error registering for event: $e');
      throw 'Failed to register for event: $e';
    }
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

  // Add to waitlist if event is full
  Future<String> _addToWaitlist(String eventId, String userId) async {
    try {
      final waitlistRef = _firestore.collection('event_waitlists').doc();
      await waitlistRef.set({
        'eventId': eventId,
        'userId': userId,
        'status': 'waiting',
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Create notification about waitlist
      await createNotification(
        userId: userId,
        title: 'Waitlist Notification',
        message: 'You have been added to the waitlist for the event.',
        type: 'event_waitlist',
        eventId: eventId,
      );

      return 'waitlisted';
    } catch (e) {
      _logger.e('Error adding to waitlist: $e');
      throw 'Failed to add to waitlist: $e';
    }
  }

}