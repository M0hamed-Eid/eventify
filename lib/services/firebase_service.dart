import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/contact_message.dart';
import '../models/event.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Events
  Future<List<Event>> getEvents() async {
    final snapshot = await _firestore.collection('events').get();
    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

/*  // Users
  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return UserProfile.fromFirestore(doc);
  }*/

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Notifications
  Stream<List<NotificationItem>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationItem.fromFirestore(doc, isRead: false)).toList());
  }

  // Contact Messages
  Future<void> submitContactMessage(ContactMessage message) async {
    await _firestore.collection('contactMessages').add(message.toMap());
  }

  // Storage
  Future<String> uploadEventImage(String eventId, File image) async {
    final ref = _storage.ref().child('events/$eventId/cover.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }


}