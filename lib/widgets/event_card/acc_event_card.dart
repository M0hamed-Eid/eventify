
import 'package:flutter/material.dart';

import '../../models/event.dart';

class AccEventCard extends StatelessWidget {
  final Event event;

  const AccEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header with Date
          Container(
            color: Color(0xFF1B3C8F), // ACC Blue color
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  event.isOnline ? Icons.video_call : Icons.location_on,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  event.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.isAccMembersOnly)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACC Members Only',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Event Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time: ${event.timeRange}',
                  style: TextStyle(fontSize: 14),
                ),
                if (event.isOnline && event.meetingId != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Meeting ID: ${event.meetingId}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Passcode: ${event.passcode}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
                SizedBox(height: 16),
                if (event.registrationLink != null)
                  ElevatedButton(
                    onPressed: () {
                      // Handle registration
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B3C8F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Register Now'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}