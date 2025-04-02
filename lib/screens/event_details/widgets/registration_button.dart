import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/event.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../utils/dialog_utils.dart';

class RegistrationButton extends StatefulWidget {
  final Event event;
  final bool isRegistered;
  final Function(bool) onRegistrationChanged;
  final AuthService authService;
  final DatabaseService databaseService;

  const RegistrationButton({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onRegistrationChanged,
    required this.authService,
    required this.databaseService,
  });

  @override
  State<RegistrationButton> createState() => _RegistrationButtonState();
}

class _RegistrationButtonState extends State<RegistrationButton> {
  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    final userId = widget.authService.currentUser?.uid;
    if (userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isRegistered) {
        await _handleUnregistration(userId);
      } else {
        await _handleNewRegistration(userId);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnregistration(String userId) async {
    final confirm = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Unregister from Event',
      content: 'Are you sure you want to unregister from ${widget.event.title}?',
      confirmText: 'Unregister',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      await widget.databaseService.unregisterFromEvent(
        widget.event.id,
        userId,
      );
      widget.onRegistrationChanged(false);
      _showSuccessMessage('Successfully unregistered from the event');
    }
  }

  Future<void> _handleNewRegistration(String userId) async {
    // Check registration eligibility
    final eligibilityStatus = await _checkRegistrationEligibility(userId);

    switch (eligibilityStatus) {
      case RegistrationEligibility.eligible:
        await _processRegistration(userId);
        break;
      case RegistrationEligibility.eventFull:
        _showWaitlistDialog();
        break;
      case RegistrationEligibility.membersOnly:
        _showMembersOnlyDialog();
        break;
      case RegistrationEligibility.alreadyRegistered:
        _showAlreadyRegisteredDialog();
        break;
    }
  }

  Future<RegistrationEligibility> _checkRegistrationEligibility(String userId) async {
    try {
      // Check if already registered
      final registrationStatus = await widget.databaseService.checkEventRegistrationStatus(
        widget.event.id,
        userId,
      );
      if (registrationStatus['isRegistered'] == true) {
        return RegistrationEligibility.alreadyRegistered;
      }

      // Check event capacity
      final currentRegistrations = await widget.databaseService.getCurrentRegistrationsCount(widget.event.id);
      if (currentRegistrations >= widget.event.maxParticipants) {
        return RegistrationEligibility.eventFull;
      }

      // Check membership requirement
      if (widget.event.isAccMembersOnly) {
        final isMember = await widget.databaseService.checkMemberStatus(userId);
        if (!isMember) {
          return RegistrationEligibility.membersOnly;
        }
      }

      return RegistrationEligibility.eligible;
    } catch (e) {
      _handleError(e);
      return RegistrationEligibility.eligible; // Default to eligible in case of error
    }
  }

  Future<void> _processRegistration(String userId) async {
    await widget.databaseService.registerForEvent(
      widget.event.id,
      userId,
    );
    widget.onRegistrationChanged(true);
    _showSuccessMessage('Successfully registered for the event');
  }

  Future<void> _joinWaitlist(String userId) async {
    try {
      await widget.databaseService.addToWaitlist(
        widget.event.id,
        userId,
      );
      _showSuccessMessage('Successfully added to the waitlist');
    } catch (e) {
      _handleError(e);
    }
  }

  void _showLoginRequiredDialog() {
    DialogUtils.showAlertDialog(
      context: context,
      title: 'Login Required',
      content: 'Please log in to register for events.',
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
    );
  }

  void _showWaitlistDialog() {
    DialogUtils.showAlertDialog(
      context: context,
      title: 'Event Full',
      content: '${widget.event.title} is currently full. Would you like to join the waitlist?',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _joinWaitlist(widget.authService.currentUser!.uid);
          },
          child: const Text('Join Waitlist'),
        ),
      ],
    );
  }

  void _showMembersOnlyDialog() {
    DialogUtils.showAlertDialog(
      context: context,
      title: 'Members Only Event',
      content: '${widget.event.title} is only available to ACC members.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to membership page
            // Navigator.pushNamed(context, '/membership');
          },
          child: const Text('Learn About Membership'),
        ),
      ],
    );
  }

  void _showAlreadyRegisteredDialog() {
    DialogUtils.showAlertDialog(
      context: context,
      title: 'Already Registered',
      content: 'You are already registered for this event.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${error.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isRegistered
              ? [Colors.red[400]!, Colors.red[700]!]
              : [Colors.blue[600]!, Colors.blue[900]!],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isRegistered ? Icons.remove_circle : Icons.add_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              widget.isRegistered ? 'Unregister' : 'Register Now',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.9, end: 1.0);
  }
}

enum RegistrationEligibility {
  eligible,
  eventFull,
  membersOnly,
  alreadyRegistered,
}