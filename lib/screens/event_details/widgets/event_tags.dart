import 'package:flutter/material.dart';

import '../../../models/event.dart';

class EventTags extends StatelessWidget {
  final Event event;

  const EventTags({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (event.isOnline) _buildTag('Online', Icons.videocam, Colors.green),
        if (event.isAccMembersOnly)
          _buildTag('Members Only', Icons.lock, Colors.red),
        _buildTag(event.category, Icons.category, Colors.blue),
      ],
    );
  }

  Widget _buildTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}