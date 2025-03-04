import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample user data - Replace with actual user data
  final UserProfile user = UserProfile(
    name: 'John Doe',
    email: 'john.doe@example.com',
    membershipStatus: 'ACC Member',
    profileImage: null,
    savedEvents: [
      Event(
        id: '1',
        title: 'Stay Safe Online',
        description: 'Learn about online safety and security',
        dateTime: DateTime.now(),
        location: 'Online via Zoom',
        isOnline: true,
        isAccMembersOnly: false,
        timeRange: '1:00 - 2:30 p.m.', guidelines: [],
      ),
      // Add more saved events...
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              _navigateToSettings();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildMembershipCard(),
            _buildSavedEvents(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18),
                    color: Colors.white,
                    onPressed: () {
                      // Handle profile picture update
                      _updateProfilePicture();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3C8F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membership Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.membershipStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle membership renewal or upgrade
              _manageMembership();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B3C8F),
            ),
            child: const Text('Manage Membership'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Saved Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.savedEvents.length,
          itemBuilder: (context, index) {
            final event = user.savedEvents[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  event.isOnline ? Icons.video_call : Icons.event,
                  color: const Color(0xFF1B3C8F),
                ),
                title: Text(event.title),
                subtitle: Text(
                  '${_formatDate(event.dateTime)} • ${event.timeRange}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // Handle removing saved event
                    _removeSavedEvent(event);
                  },
                ),
                onTap: () {
                  // Navigate to event details
                  _navigateToEventDetails(event);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              // Navigate to edit profile
              _navigateToEditProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Preferences'),
            onTap: () {
              // Navigate to notification settings
              _navigateToNotificationSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help & support
              _navigateToHelp();
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Customize date format as needed
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateProfilePicture() {
    // Implement profile picture update logic
  }

  void _manageMembership() {
    // Implement membership management logic
  }

  void _removeSavedEvent(Event event) {
    setState(() {
      user.savedEvents.remove(event);
    });
    // Implement actual event removal logic
  }

  void _navigateToEventDetails(Event event) {
    // Navigate to event details screen
  }

  void _navigateToEditProfile() {
    // Navigate to edit profile screen
  }

  void _navigateToNotificationSettings() {
    // Navigate to notification settings screen
  }

  void _navigateToHelp() {
    // Navigate to help & support screen
  }

  void _navigateToSettings() {
    // Navigate to settings screen
  }
}