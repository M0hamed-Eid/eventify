import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailsBottomSheet extends StatelessWidget {
  final Event event;
  final VoidCallback onRegister;

  const EventDetailsBottomSheet({
    Key? key,
    required this.event,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: event.isOnline ? Icons.video_call : Icons.location_on,
                text: event.location,
              ),
              _buildInfoRow(
                icon: Icons.access_time,
                text: event.timeRange,
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(event.description),
              if (event.registrationLink != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3C8F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Register Now'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}