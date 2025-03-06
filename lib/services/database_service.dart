import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import '../models/workshop.dart';

class DatabaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Event> createEvent(Event event) async {
    final docRef = await _firestore.collection('events').add(event.toMap());
    final doc = await docRef.get();
    return Event.fromFirestore(doc);
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


  // Users
  Future<void> createUserProfile(UserProfile user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? UserProfile.fromFirestore(doc) : null;
  }

  // Add method to get user profile as stream if needed
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Future<void> removeSavedEvent(String userId, String eventId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'savedEvents': FieldValue.arrayRemove([eventId]),
      });
    } catch (e) {
      throw 'Failed to remove saved event: $e';
    }
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
      'createdAt': FieldValue.serverTimestamp(),
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


  Stream<List<NotificationItem>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationItem.fromFirestore(doc)).toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
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