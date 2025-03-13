import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRegister,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isRegistered = false;
  bool _isSaved = false;
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkEventStatus();
  }

  Future<void> _checkEventStatus() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      // Check registration status
      final registrationStatus = await _databaseService.checkEventRegistrationStatus(
          widget.event.id,
          userId
      );

      // Check if event is saved
      final isSaved = await _databaseService.isEventSaved(userId, widget.event.id);

      if (mounted) {
        setState(() {
          _isRegistered = registrationStatus['isRegistered'] ?? false;
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      print('Error checking event status: $e');
    }
  }


  Future<void> _checkRegistrationAndSaveStatus() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Check registration status
      final registrationCheck = await _databaseService.checkEventRegistrationStatus(
        widget.event.id,
        userId,
      );

      // Check saved status
      final userProfile = await _databaseService.getUserProfile(userId);

      if (mounted) {
        setState(() {
          _isRegistered = registrationCheck['isRegistered'] ?? false;
          _isSaved = userProfile.savedEvents.contains(widget.event.id);
        });
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }
  Future<void> _handleRegistration() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (_isRegistered) {
        // Show unregister confirmation
        final confirm = await _showUnregisterConfirmationDialog();
        if (confirm!) {
          await _databaseService.unregisterFromEvent(
            widget.event.id,
            userId,
          );
          _showRegistrationStatusSnackBar('Unregistered from the event');
        }
      } else {
        // Check event capacity and registration eligibility
        final currentRegistrations = await _databaseService.getCurrentRegistrationsCount(widget.event.id);

        if (currentRegistrations >= widget.event.maxParticipants) {
          _showFullEventDialog();
          return;
        }

        // Check if event is members only
        if (widget.event.isAccMembersOnly) {
          final isMember = await _databaseService.checkMemberStatus(userId);
          if (!isMember) {
            _showMemberOnlyDialog();
            return;
          }
        }

        // Proceed with registration
        await _databaseService.registerForEvent(
          widget.event.id,
          userId,
        );
        _showRegistrationStatusSnackBar('Successfully registered for the event');
      }

      // Update registration status
      setState(() {
        _isRegistered = !_isRegistered;
      });

      // Call the onRegister callback if provided
      widget.onRegister?.call();
    } catch (e) {
      _showRegistrationStatusSnackBar('Failed to register: $e', isError: true);
    }
  }

  Future<void> _toggleSaveEvent() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (_isSaved) {
        // Remove from saved events
        await _databaseService.removeSavedEvent(userId, widget.event.id);
        _showSnackBar('Event removed from saved events');
      } else {
        // Save the event
        await _databaseService.saveEvent(userId, widget.event.id);
        _showSnackBar('Event saved successfully');
      }

      // Update local state
      setState(() {
        _isSaved = !_isSaved;
      });
    } catch (e) {
      _showSnackBar('Failed to save event: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showRegistrationStatusSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to perform this action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              // Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showFullEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Full'),
        content: Text('${widget.event.title} is currently full. Would you like to join the waitlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _joinWaitlist();
            },
            child: const Text('Join Waitlist'),
          ),
        ],
      ),
    );
  }

  void _showMemberOnlyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Members Only Event'),
        content: Text('${widget.event.title} is only available to ACC members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to membership information or upgrade page
              // Navigator.pushNamed(context, '/membership');
            },
            child: const Text('Learn About Membership'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinWaitlist() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _databaseService.addToWaitlist(widget.event.id, userId);
      _showRegistrationStatusSnackBar('Added to waitlist for ${widget.event.title}');
    } catch (e) {
      _showRegistrationStatusSnackBar('Failed to join waitlist: $e', isError: true);
    }
  }

  Future<bool?> _showUnregisterConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister from Event'),
        content: const Text('Are you sure you want to unregister from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );
  }



  Future<void> _checkRegistrationStatus() async {
    try {
      // Implement a method in your DatabaseService to check if the current user is registered for this event
      final isRegistered = await _databaseService.isUserRegisteredForEvent(
        eventId: widget.event.id,
        userId: 'currentUserId', // Replace with actual current user ID
      );

      if (mounted) {
        setState(() {
          _isRegistered = isRegistered;
        });
      }
    } catch (e) {
      print('Error checking registration status: $e');
    }
  }

  Future<void> _registerForEvent() async {
    try {
      await _databaseService.registerForEvent(
        widget.event.id,
        'currentUserId', // Replace with actual current user ID
      );

      if (mounted) {
        setState(() {
          _isRegistered = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for the event'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the onRegister callback if provided
        widget.onRegister?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unregisterFromEvent() async {
    try {
      await _databaseService.unregisterFromEvent(
        widget.event.id,
        'currentUserId', // Replace with actual current user ID
      );

      if (mounted) {
        setState(() {
          _isRegistered = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully unregistered from the event'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unregister: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: _buildEventBackground(),
              ),

              // Event Content
              _buildEventContent(context),

              // Save Button
              Positioned(
                top: 10,
                right: 10,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ).animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildSaveButton() {
    return IconButton(
      icon: Icon(
        _isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2.0, 2.0),
          ),
        ],
      ),
      onPressed: _toggleSaveEvent,
    );
  }


  Widget _buildEventBackground() {
    return widget.event.imageUrl != null
        ? CachedNetworkImage(
      imageUrl: widget.event.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.blue[100],
        child: const Icon(Icons.error),
      ),
    )
        : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.blue[300]!,
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildEventHeader(context),

          // Event Details
          _buildEventDetails(context),
        ],
      ),
    );
  }

  Widget _buildEventHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Icon(
            widget.event.isOnline ? Icons.videocam : Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.event.isAccMembersOnly)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Members Only',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Details
          _buildDetailRow(
            Icons.calendar_today,
            widget.event.timeRange,
            context,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_city,
            widget.event.location,
            context,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.event.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Action Buttons
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          child: const Text('View Details'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _handleRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRegistered ? Colors.green : Colors.black,
            foregroundColor: Colors.white,
          ),
          child: Text(
            _isRegistered ? 'Registered' : 'Register',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}