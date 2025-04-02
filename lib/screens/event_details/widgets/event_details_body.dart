import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/event.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import 'registration_button.dart';

class EventDetailsBody extends StatelessWidget {
  final Event event;
  final bool isRegistered;
  final Function(bool) onRegistrationChanged;
  final AuthService authService;
  final DatabaseService databaseService;

  const EventDetailsBody({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onRegistrationChanged,
    required this.authService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEnhancedEventDetails(),
              const SizedBox(height: 20),
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              _buildAdditionalInformationSection(),
              if (event.minimumAge != null) _buildAgeRequirementSection(),
              if (event.entryGuidelines.isNotEmpty) _buildEntryGuidelinesSection(),
              if (event.securityRestrictions.isNotEmpty)
                _buildSecurityRestrictionsSection(),
              const SizedBox(height: 30),
              RegistrationButton(
                event: event,
                isRegistered: isRegistered,
                onRegistrationChanged: onRegistrationChanged,
                authService: authService,
                databaseService: databaseService,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEventDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              DateFormat('EEEE, MMMM d, yyyy').format(event.dateTime),
            ),
            const Divider(),
            _buildDetailRow(
              Icons.access_time,
              'Time',
              event.timeRange,
            ),
            const Divider(),
            _buildDetailRow(
              event.isOnline ? Icons.videocam : Icons.location_on,
              'Location',
              event.location,
            ),
            if (event.presenter != null) ...[
              const Divider(),
              _buildDetailRow(
                Icons.person,
                'Presenter',
                event.presenter!,
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event.description,
          style: TextStyle(
            color: Colors.grey[800],
            height: 1.5,
            fontSize: 16,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildAdditionalInformationSection() {
    return ExpansionTile(
      title: Text(
        'Additional Information',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
          fontSize: 18,
        ),
      ),
      children: [
        if (event.guidelines.isNotEmpty)
          _buildInfoSection('Guidelines', event.guidelines),
        if (event.requirements.isNotEmpty)
          _buildInfoSection('Requirements', event.requirements),
        if (event.requireConfirmationEmail)
          _buildAdditionalInfoTile(
            Icons.email,
            'Confirmation Email Required',
            Colors.blue,
          ),
        if (event.mediaConsent)
          _buildAdditionalInfoTile(
            Icons.camera_alt,
            'Media Recording Consent',
            Colors.green,
          ),
      ],
    ).animate().fadeIn(duration: 300.ms);
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
            'Minimum age: ${event.minimumAge} years',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
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
              ...event.entryGuidelines.map((guideline) => _buildBulletPoint(guideline)),
              if (event.allowedIdentificationTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Allowed Identification:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                ...event.allowedIdentificationTypes
                    .map((id) => _buildBulletPoint(id)),
              ],
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
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
              ...event.securityRestrictions
                  .map((restriction) => _buildBulletPoint(restriction)),
              if (event.electronicRestrictions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Electronic Restrictions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                ...event.electronicRestrictions
                    .map((electronic) => _buildBulletPoint(electronic)),
              ],
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
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

  Widget _buildAdditionalInfoTile(IconData icon, String text, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}