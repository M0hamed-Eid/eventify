import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../home/home_screen.dart';

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

  Future<void> _handleRegistration() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (_isRegistered) {
        // Show unregister confirmation
        final confirm = await _showUnregisterConfirmation();
        if (confirm) {
          await _databaseService.unregisterFromEvent(
            widget.event.id,
            userId,
          );
          setState(() {
            _isRegistered = false;
          });
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
        setState(() {
          _isRegistered = true;
        });
      }
    } catch (e) {
      _handleRegistrationError(e);
    }
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

  Future<void> _joinWaitlist() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _databaseService.addToWaitlist(widget.event.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to waitlist for ${widget.event.title}'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _handleRegistrationError(e);
    }
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

  void _handleRegistrationError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }


  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Registered'),
        content: Text('You are already registered for ${widget.event.title}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWaitlistDialog() {
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



  Future<void> _performEventRegistration(String userId) async {
    if (_isRegistered) {
      // Show unregister confirmation
      final confirm = await _showUnregisterConfirmation();
      if (confirm) {
        await _databaseService.unregisterFromEvent(
          widget.event.id,
          userId,
        );
        setState(() {
          _isRegistered = false;
        });
      }
    } else {
      final result = await _databaseService.registerForEvent(
        widget.event.id,
        userId,
      );

      setState(() {
        _isRegistered = true;
      });

      // Show registration confirmation
      _showRegistrationConfirmation(result);
    }
  }

  void _showRegistrationConfirmation(String result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result == 'confirmed'
            ? 'Successfully registered for the event!'
            : 'You have been added to the waitlist.'),
        backgroundColor: result == 'confirmed' ? Colors.green : Colors.orange,
      ),
    );
  }



  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to register for events.'),
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


  Future<RegistrationStatus> _checkEventRegistrationEligibility(String userId) async {
    // Check if already registered
    final registrationCheck = await _databaseService.checkEventRegistrationStatus(
      widget.event.id,
      userId,
    );
    if (registrationCheck['isRegistered'] == true) {
      return RegistrationStatus.alreadyRegistered;
    }

    // Check if event is members only
    if (widget.event.isAccMembersOnly) {
      final isMember = await _checkMemberStatus(userId);
      if (!isMember) {
        return RegistrationStatus.memberOnly;
      }
    }

    // Check event capacity
    final currentRegistrations = await _databaseService.getCurrentRegistrationsCount(widget.event.id);
    if (currentRegistrations >= widget.event.maxParticipants) {
      return RegistrationStatus.full;
    }

    return RegistrationStatus.available;
  }

  Future<bool> _checkMemberStatus(String userId) async {
    // Implement logic to check if user is a member
    return await _databaseService.checkMemberStatus(userId);
  }


  Future<bool> _showUnregisterConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister from Event'),
        content: const Text('Are you sure you want to unregister?'),
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
    ) ??
        false;
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(),
                  const SizedBox(height: 16),
                  _buildEventDetails(),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  _buildAdditionalDetails(),
                  if (widget.event.minimumAge != null)
                    _buildAgeRequirementSection(),
                  if (widget.event.entryGuidelines.isNotEmpty)
                    _buildEntryGuidelinesSection(),
                  if (widget.event.securityRestrictions.isNotEmpty)
                    _buildSecurityRestrictionsSection(),
                  const SizedBox(height: 24),
                  _buildRegistrationButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRequirementSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Icon(Icons.person, color: Colors.blue[700]),
          title: Text(
            'Age Requirement',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
          ),
          subtitle: Text(
            'Minimum age: ${widget.event.minimumAge} years',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryGuidelinesSection() {
    return ExpansionTile(
      title: Text(
        'Entry Guidelines',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.event.entryGuidelines.map((guideline) => _buildBulletPoint(guideline)),
              if (widget.event.allowedIdentificationTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Allowed Identification:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                ...widget.event.allowedIdentificationTypes
                    .map((id) => _buildBulletPoint(id)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityRestrictionsSection() {
    return ExpansionTile(
      title: Text(
        'Security Restrictions',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red[900],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.event.securityRestrictions
                  .map((restriction) => _buildBulletPoint(restriction)),
              if (widget.event.electronicRestrictions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Electronic Restrictions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                ...widget.event.electronicRestrictions
                    .map((electronic) => _buildBulletPoint(electronic)),
              ],
            ],
          ),
        ),
      ],
    );
  }


  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildEventImage(),
        title: Text(
          widget.event.title,
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return widget.event.imageUrl != null
        ? CachedNetworkImage(
      imageUrl: widget.event.imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error),
      ),
    )
        : Container(
      color: Colors.blue[100],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        _buildEventTags(),
      ],
    );
  }

  Widget _buildEventTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (widget.event.isOnline)
          _buildTag('Online', Icons.videocam, Colors.green),
        if (widget.event.isAccMembersOnly)
          _buildTag('Members Only', Icons.lock, Colors.red),
        _buildTag(widget.event.category, Icons.category, Colors.blue),
      ],
    );
  }

  Widget _buildTag(String label, IconData icon, Color color) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: color),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          Icons.calendar_today,
          'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(widget.event.dateTime)}',
        ),
        _buildDetailRow(
          Icons.access_time,
          'Time: ${widget.event.timeRange}',
        ),
        _buildDetailRow(
          widget.event.isOnline ? Icons.videocam : Icons.location_on,
          'Location: ${widget.event.location}',
        ),
        if (widget.event.presenter != null)
          _buildDetailRow(
            Icons.person,
            'Presenter: ${widget.event.presenter}',
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.description,
          style: TextStyle(color: Colors.grey[800], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing additional details
        ExpansionTile(
          title: const Text('Additional Information'),
          children: [
            if (widget.event.guidelines.isNotEmpty)
              _buildInfoSection('Guidelines', widget.event.guidelines),
            if (widget.event.requirements.isNotEmpty)
              _buildInfoSection('Requirements', widget.event.requirements),

            // New additional details
            if (widget.event.requireConfirmationEmail)
              _buildDetailRow(
                Icons.email,
                'Confirmation Email Required',
              ),
            if (widget.event.mediaConsent)
              _buildDetailRow(
                Icons.camera_alt,
                'Media Recording Consent Requested',
              ),
          ],
        ),
      ],
    );
  }

  // Optional: Add a method to show media consent details
  void _showMediaConsentDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media Consent'),
        content: const Text(
          'By participating in this event, you consent to being photographed or recorded. '
              'These materials may be used for future public information programs and activities. '
              'Content will not be used for commercial purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildBulletPoint(item)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: Colors.blue[700], fontSize: 16),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildRegistrationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRegistered ? Colors.red : Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isRegistered ? 'Unregister' : 'Register Now',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.9, end: 1.0);
  }
}