import 'package:flutter/material.dart';

import '../models/event.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];
  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    // Fetch events from Firebase
    notifyListeners();
  }

  Future<void> saveEvent(Event event) async {
    // Save event to user's saved events
    notifyListeners();
  }
}