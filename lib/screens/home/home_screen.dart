import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../widgets/event_card/event_card.dart';
import '../../widgets/program_info_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/acc_logo.png', // Add your logo
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text('ACC Events'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add ProgramInfoCard at the top of the home screen
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProgramInfoCard(),
            ),
            _buildTodayEvents(),
            _buildUpcomingEvents(),
            _buildWorkshopsAndMore(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3C8F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRAM INFO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(Icons.video_call, 'Online program via Zoom'),
          _buildInfoItem(Icons.location_on, 'In-person program at location listed'),
          _buildInfoItem(Icons.people_outline, 'Open to the Public'),
          _buildInfoItem(Icons.card_membership, 'ACC Members Only Programs'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEvents() {
    final List<Event> todayEvents = [
      Event(
        id: '1',
        title: 'Stay Safe Online',
        description: 'Learn about online safety and security',
        dateTime: DateTime.now(),
        location: 'Online via Zoom',
        isOnline: true,
        isAccMembersOnly: false,
        timeRange: '1:00 - 2:30 p.m.',
        guidelines: [],
        registrationLink: 'bit.ly/MediaLit25',
      ),
      // Add more events here
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Today's Events",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todayEvents.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: todayEvents[index],
              featured: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    final List<Event> upcomingEvents = [
      Event(
        id: '2',
        title: 'English Conversation Club',
        description: 'Famous People from the American South',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'ACC',
        isOnline: false,
        isAccMembersOnly: true,
        timeRange: '2:00 - 3:00 p.m.',
        guidelines: [],
      ),
      // Add more events here
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingEvents.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: upcomingEvents[index],
              featured: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWorkshopsAndMore() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workshops and More',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildWorkshopItem(
            'Business English Program',
            'Registration Closed',
            'Sundays & Wednesday',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopItem(String title, String status, String schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(status),
        Text('Date: $schedule'),
      ],
    );
  }
}