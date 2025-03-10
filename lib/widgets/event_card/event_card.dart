import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/event.dart';
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
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
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

  Future<void> _handleRegistration() async {
    if (_isRegistered) {
      // Show dialog to confirm unregistration
      final confirmUnregister = await _showUnregisterConfirmationDialog();
      if (confirmUnregister == true) {
        await _unregisterFromEvent();
      }
    } else {
      await _registerForEvent();
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
            ],
          ),
        ),
      ).animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0),
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