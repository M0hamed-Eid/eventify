  import 'dart:async';
  
  import 'package:eventify/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import '../../models/event.dart';
  import '../../models/user_profile.dart';
  import '../../services/database_service.dart';
  import '../../services/auth_service.dart';
  import '../event_details/event_details_screen.dart';
  import '../help/help_screen.dart';
  import '../profile/edit_profile_screen.dart';
  import '../settings/notification_settings_screen.dart';
  import '../settings/settings_screen.dart';
import 'membership_screen.dart';
  
  class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});
  
    @override
    _ProfileScreenState createState() => _ProfileScreenState();
  }
  
  class _ProfileScreenState extends State<ProfileScreen> {
    final DatabaseService _databaseService = DatabaseService();
    final AuthService _authService = AuthService();
    StreamSubscription<User?>? _authSubscription;
    StreamSubscription<UserProfile?>? _userSubscription;

    bool _isLoading = true;
    UserProfile? _user;
    bool _isAuthenticated = false;

    @override
    void initState() {
      super.initState();
      _setupAuthListener();
    }

    void _setupAuthListener() {
      _authSubscription = _authService.authStateChanges.listen((User? user) {
        if (mounted) {
          setState(() {
            _isAuthenticated = user != null;
          });
          if (user != null) {
            _loadUserProfile();
            _setupUserListener();
          } else {
            setState(() {
              _user = null;
              _isLoading = false;
            });
          }
        }
      });
    }

    void _setupUserListener() {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        _userSubscription?.cancel();
        _userSubscription = _databaseService
            .getUserProfileStream(userId)
            .listen((userProfile) {
          if (mounted) {
            setState(() {
              _user = userProfile;
              _isLoading = false;
            });
          }
        }, onError: (error) {
          _showErrorSnackBar('Error updating profile: $error');
          setState(() => _isLoading = false);
        });
      }
    }
    Future<void> _loadUserProfile() async {
      setState(() => _isLoading = true);
      try {
        final userId = _authService.currentUser?.uid;
        if (userId != null) {
          // Use Future instead of Stream
          final userProfile = await _databaseService.getUserProfile(userId);
          if (mounted) {
            setState(() {
              _user = userProfile;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _user = null;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Error loading profile: $e');
        }
      }
    }
  
    void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  
    @override
    Widget build(BuildContext context) {
      if (_isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!_isAuthenticated) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please sign in to view your profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        );
      }
  
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _navigateToSettings(context),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadUserProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildMembershipCard(),
                _buildSavedEvents(),
                _buildActionButtons(),
              ],
            ),
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
                  backgroundImage: _user?.photoURL != null
                      ? NetworkImage(_user!.photoURL!)
                      : null,
                  child: _user?.photoURL == null
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
                      onPressed: _updateProfilePicture,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _user?.displayName ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
  
    // Add these methods to _ProfileScreenState
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
              _user?.membershipStatus ?? 'Non-Member',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _manageMembership(),
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
          if (_user?.savedEvents.isEmpty ?? true)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No saved events'),
              ),
            )
          else
            FutureBuilder<List<Event>>(
              future: _fetchSavedEvents(_user!.savedEvents),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No saved events'));
                } else {
                  final events = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
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
                            onPressed: () => _removeSavedEvent(event),
                          ),
                          onTap: () => _navigateToEventDetails(event),
                        ),
                      );
                    },
                  );
                }
              },
            ),
        ],
      );
    }

    Future<List<Event>> _fetchSavedEvents(List<String> eventIds) async {
      try {
        final events = await _databaseService.getEventsByIds(eventIds);
        return events;
      } catch (e) {
        throw 'Failed to fetch saved events: $e';
      }
    }

    Future<void> _removeSavedEvent(Event event) async {
      try {
        await _databaseService.removeSavedEvent(_user!.uid, event.id);
        await _loadUserProfile(); // Reload profile to update saved events
      } catch (e) {
        _showErrorSnackBar('Failed to remove event: $e');
      }
    }
  
    Widget _buildActionButtons() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => _navigateToEditProfile(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Preferences'),
              onTap: () => _navigateToNotificationSettings(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () => _navigateToHelp(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      );
    }
  
    Future<void> _signOut() async {
      try {
        await _authService.signOut();
        // Navigate to login screen or handle sign out
      } catch (e) {
        _showErrorSnackBar('Error signing out: $e');
      }
    }
  
    String _formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    Future<void> _updateProfilePicture() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
  
        if (image != null && _user != null) {
          await _databaseService.uploadProfilePicture(_user!.uid, image);
          await _loadUserProfile();
        }
      } catch (e) {
        _showErrorSnackBar('Failed to update profile picture: $e');
      }
    }

    Future<void> _manageMembership() async {
      try {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MembershipScreen(),
          ),
        );
        if (result == true) {
          await _loadUserProfile(); // Reload profile if membership was updated
        }
      } catch (e) {
        _showErrorSnackBar('Error managing membership: $e');
      }
    }


    void _navigateToEventDetails(Event event) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(event: event),
        ),
      );
    }
  
    Future<void> _navigateToEditProfile(BuildContext context) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: _user!),
        ),
      );
      if (result == true) {
        await _loadUserProfile(); // Reload profile if it was updated
      }
    }
  
    void _navigateToNotificationSettings(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationSettingsScreen(),
        ),
      );
    }
  
    void _navigateToHelp(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HelpScreen(),
        ),
      );
    }
  
    void _navigateToSettings(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        ),
      );
    }

    @override
    void dispose() {
      _authSubscription?.cancel();
      _userSubscription?.cancel();
      super.dispose();
    }
  }