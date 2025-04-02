import 'package:flutter/material.dart';
import 'widgets/event_app_bar.dart';
import 'widgets/event_details_body.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isRegistered = false;
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      final status = await _databaseService.checkEventRegistrationStatus(
        widget.event.id,
        userId,
      );

      setState(() {
        _isRegistered = status['isRegistered'] ?? false;
      });
    } catch (e) {
      print('Error checking registration status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          EventAppBar(event: widget.event),
          EventDetailsBody(
            event: widget.event,
            isRegistered: _isRegistered,
            onRegistrationChanged: (bool registered) {
              setState(() {
                _isRegistered = registered;
              });
            },
            authService: _authService,
            databaseService: _databaseService,
          ),
        ],
      ),
    );
  }
}