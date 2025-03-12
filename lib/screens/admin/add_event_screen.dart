import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event.dart';
import '../../providers/database_provider.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;

  const AddEventScreen({
    super.key,
    this.event,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _presenterController = TextEditingController();
  final _presenterTitleController = TextEditingController();
  final _meetingIdController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _locationController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _certificateRequirementsController = TextEditingController();
  final _registrationLinkController = TextEditingController();

  File? _imageFile;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      // Generate a unique filename
      final fileName = 'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = _imageFile!;

      // Upload to Supabase storage
      final response = await Supabase.instance.client.storage
          .from('event-covers') // Make sure this bucket exists
          .upload(
            fileName,
            file,
            fileOptions: FileOptions(
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('event-covers')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Lists for requirements and guidelines
  final List<String> _guidelines = [];
  final List<String> _technicalRequirements = [
    'Zoom account required',
    'Stable internet connection',
    'Working microphone and camera',
  ];
  final List<String> _requirements = [];

  // Update the _programEtiquette list in initState or class declaration
  final List<String> _programEtiquette = [
    'Technical Requirements',
    'Program Participation Guidelines',
    'Communication and Respect',
  ];

  // New controllers and variables
  final _minimumAgeController = TextEditingController();
  List<String> _entryGuidelines = [
    'Bring a valid national identity card, passport, or driver\'s license',
    'Arrive at least 1 hour before the program start time',
    'Clear security checkpoint',
  ];
  List<String> _securityRestrictions = [
    'No electronics allowed',
    'Only mobile phones can be checked at the gate',
    'No lighters, sharp objects, or large bags',
  ];
  bool _requireConfirmationEmail = true;
  bool _mediaConsent = true;


  // Method to show entry guidelines details
  void _showEntryGuidelinesDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Text(
                      'Guidelines for Entering ACC',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEtiquetteSection(
                    'General Guidelines',
                    _entryGuidelines,
                  ),
                  const SizedBox(height: 16),
                  _buildEtiquetteSection(
                    'Security Restrictions',
                    _securityRestrictions,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Add a new card for entry guidelines in your build method
  Widget _buildEntryGuidelinesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry Guidelines',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _showEntryGuidelinesDetails,
                  child: Text(
                    'View Details',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumAgeController,
              decoration: InputDecoration(
                labelText: 'Minimum Age Requirement',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Require Confirmation Email'),
              value: _requireConfirmationEmail,
              onChanged: (value) {
                setState(() {
                  _requireConfirmationEmail = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Media Consent'),
              subtitle: const Text('Allow photo/video recording'),
              value: _mediaConsent,
              onChanged: (value) {
                setState(() {
                  _mediaConsent = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }


// Add a new method to show detailed program etiquette
  void _showProgramEtiquetteDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Text(
                      'Guidelines for Online Programs',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEtiquetteSection(
                    'Technical Requirements',
                    [
                      'All online programs will be conducted via Zoom unless otherwise stated.',
                      'Log into the link provided in the confirmation email at least 15 minutes in advance.',
                      'Test connection, including audio and video capabilities.',
                      'If a computer is not available, log in using a mobile device.',
                      'Use the first and last name as registered for the program.',
                      'Your name and image will be visible to other participants during the session.',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEtiquetteSection(
                    'Program Participation Guidelines',
                    [
                      'Be on time and do not disrupt the session by joining late.',
                      'Follow instructions from the host on how and when to ask questions.',
                      'Microphones must stay muted unless asked to speak.',
                      'Give full attention to the speaker and avoid distractions.',
                      'Video can be turned off if the internet connection is unstable.',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEtiquetteSection(
                    'Communication and Respect',
                    [
                      'The ACC promotes open and respectful dialogue.',
                      'Interrupting speakers or participants is disruptive.',
                      'Disruptive behavior may lead to removal from the session without warning.',
                      'All opinions expressed are those of the speaker.',
                      'Opinions do not necessarily represent the American Center Cairo or U.S. Embassy.',
                      'English language programs are limited to participants who speak English as a second language.',
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper method to build etiquette sections
  Widget _buildEtiquetteSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildEtiquetteItem(item)),
      ],
    );
  }

// Helper method to build individual etiquette items
  Widget _buildEtiquetteItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramEtiquette() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Program Guidelines',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _showProgramEtiquetteDetails,
                  child: Text(
                    'View Full Guidelines',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequirementsList(
              'Key Guidelines',
              _programEtiquette,
              'Add Guideline',
            ),
          ],
        ),
      ),
    );
  }

  // Date and Time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;
  DateTime? _applicationDeadline;

  // Dropdown selections
  String _selectedCategory = '';
  String? _selectedSeries;
  String? _selectedProgramType;

  // Toggles
  bool _isOnline = true;
  bool _isAccMembersOnly = false;
  bool _requiresRegistration = false;
  bool _isCertificateAvailable = false;

  // Dropdown options
  final List<String> _categories = [
    'Education',
    'Career Development',
    'Language Learning',
    'Cultural Exchange',
    'Workshop',
    'Information Session',
  ];

  final List<String> _series = [
    'Future Focus',
    'English Conversation Club',
    'Study in the U.S.',
    'None',
  ];

  final List<String> _programTypes = [
    'Workshop',
    'Seminar',
    'Information Session',
    'Training',
    'Club Meeting',
    'Special Event',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.event != null) {
        // Populate the form with existing event data
        _titleController.text = widget.event!.title;
        _descriptionController.text = widget.event!.description;
        _presenterController.text = widget.event!.presenter ?? '';
        _presenterTitleController.text = widget.event!.presenterTitle ?? '';
        _meetingIdController.text = widget.event!.meetingId ?? '';
        _passcodeController.text = widget.event!.passcode ?? '';
        _locationController.text = widget.event!.location;
        _targetAudienceController.text = widget.event!.targetAudience ?? '';
        _certificateRequirementsController.text =
            widget.event!.certificateRequirements ?? '';
        _registrationLinkController.text = widget.event!.registrationLink ?? '';
        _uploadedImageUrl = widget.event!.imageUrl;

        // Set date and time
        _selectedDate = widget.event!.dateTime;
        _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime);

        // Parse end time from timeRange if available
        if (widget.event!.timeRange.contains('-')) {
          final endTimeStr = widget.event!.timeRange.split('-').last.trim();
          try {
            // Create a temporary date to parse the time
            final now = DateTime.now();
            final tempDate = '${now.month}/${now.day}/${now.year} $endTimeStr';
            final format = DateFormat('M/d/yyyy h:mm a');
            final dateTime = format.parse(tempDate);
            _selectedEndTime = TimeOfDay.fromDateTime(dateTime);
          } catch (e) {
            debugPrint('Error parsing end time: $e');
            // Set a default end time (1 hour after start time)
            _selectedEndTime = _selectedTime?.replacing(
              hour: (_selectedTime?.hour ?? 0) + 1,
            );
          }
        }

        // Set other fields
        _selectedCategory = widget.event!.category;
        _selectedSeries = widget.event!.series;
        _isOnline = widget.event!.isOnline;
        _isAccMembersOnly = widget.event!.isAccMembersOnly;
        _requiresRegistration =
            widget.event!.registrationLink?.isNotEmpty ?? false;
        _isCertificateAvailable = widget.event!.isCertificateAvailable;

        // Set lists
        _guidelines.addAll(widget.event!.guidelines);
        _technicalRequirements.addAll(widget.event!.technicalRequirements);
        _programEtiquette.addAll(widget.event!.programEtiquette);
        _requirements.addAll(widget.event!.requirements);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _presenterController.dispose();
    _presenterTitleController.dispose();
    _meetingIdController.dispose();
    _passcodeController.dispose();
    _locationController.dispose();
    _targetAudienceController.dispose();
    _certificateRequirementsController.dispose();
    _registrationLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add New Event' : 'Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildEventCoverSection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey, // Assign the form key here
                  child: Column(
                    children: [
                      _buildBasicInformationCard(),
                      const SizedBox(height: 16),
                      _buildDateTimeCard(),
                      const SizedBox(height: 16),
                      _buildLocationCard(),
                      const SizedBox(height: 16),
                      _buildRegistrationCard(),
                      const SizedBox(height: 16),
                      _buildProgramEtiquette(),
                      const SizedBox(height: 16),
                      _buildEntryGuidelinesCard(),
                      const SizedBox(height: 16),
                      _buildAdditionalDetailsCard(),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Add these methods to your _AddEventScreenState class
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ??
          (_selectedTime?.replacing(hour: (_selectedTime!.hour + 1) % 24) ??
              TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Widget _buildRegistrationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registration Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Requires Registration'),
              value: _requiresRegistration,
              onChanged: (value) {
                setState(() {
                  _requiresRegistration = value;
                });
              },
              activeColor: Colors.blue[700],
            ),
            if (_requiresRegistration) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationLinkController,
                decoration: InputDecoration(
                  labelText: 'Registration Link',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (_requiresRegistration &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter a registration link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _applicationDeadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _applicationDeadline = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Application Deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _applicationDeadline != null
                        ? '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}'
                        : 'Select Deadline',
                    style: TextStyle(
                      color: _applicationDeadline != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAudienceController,
              decoration: InputDecoration(
                labelText: 'Target Audience',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('ACC Members Only'),
              value: _isAccMembersOnly,
              onChanged: (value) {
                setState(() {
                  _isAccMembersOnly = value;
                });
              },
              activeColor: Colors.blue[700],
            ),
            const SizedBox(height: 16),
            _buildRequirementsList(
              'Event Requirements',
              _requirements,
              'Add Requirement',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Certificate Available'),
              value: _isCertificateAvailable,
              onChanged: (value) {
                setState(() {
                  _isCertificateAvailable = value;
                });
              },
              activeColor: Colors.blue[700],
            ),
            if (_isCertificateAvailable) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _certificateRequirementsController,
                decoration: InputDecoration(
                  labelText: 'Certificate Requirements',
                  prefixIcon: const Icon(Icons.workspace_premium),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

// Reuse the existing _buildRequirementsList method from the previous implementation
  Widget _buildRequirementsList(
    String title,
    List<String> items,
    String addLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    items.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: addLabel,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddItemDialog(title, items);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(String title, List<String> items) {
    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $title'),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(
              hintText: 'Enter item',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemController.text.isNotEmpty) {
                  setState(() {
                    items.add(itemController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date and Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Start Date',
                    date: _selectedDate,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePickerField(
                    label: 'Start Time',
                    time: _selectedTime,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerField(
                    label: 'End Time',
                    time: _selectedEndTime,
                    onTap: _selectEndTime,
                    isOptional: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Program Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedProgramType,
              items: _programTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgramType = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select Date',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time != null
              ? time.format(context)
              : (isOptional ? 'Optional' : 'Select Time'),
          style: TextStyle(
            color: time != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Online Event'),
              value: _isOnline,
              onChanged: (value) {
                setState(() {
                  _isOnline = value;
                });
              },
              activeColor: Colors.blue[700],
            ),
            const SizedBox(height: 16),
            if (!_isOnline)
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Physical Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (!_isOnline && (value == null || value.isEmpty)) {
                    return 'Please enter the event location';
                  }
                  return null;
                },
              ),
            if (_isOnline) ...[
              TextFormField(
                controller: _meetingIdController,
                decoration: InputDecoration(
                  labelText: 'Meeting ID',
                  prefixIcon: const Icon(Icons.video_call),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (_isOnline && (value == null || value.isEmpty)) {
                    return 'Please enter meeting ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passcodeController,
                decoration: InputDecoration(
                  labelText: 'Meeting Passcode',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (_isOnline && (value == null || value.isEmpty)) {
                    return 'Please enter meeting passcode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTechnicalRequirementsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalRequirementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Requirements',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _technicalRequirements.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_technicalRequirements[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _technicalRequirements.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Add Technical Requirement',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddRequirementDialog();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddRequirementDialog() {
    final TextEditingController requirementController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Technical Requirement'),
          content: TextField(
            controller: requirementController,
            decoration: const InputDecoration(
              hintText: 'Enter requirement',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (requirementController.text.isNotEmpty) {
                  setState(() {
                    _technicalRequirements.add(requirementController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCoverSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: _imageFile != null
              ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
              : (_uploadedImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_uploadedImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
        ),
        child: _imageFile == null && _uploadedImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 80,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Event Cover Image',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBasicInformationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Series (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedSeries,
              items: _series.map((series) {
                return DropdownMenuItem(
                  value: series,
                  child: Text(series),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeries = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ensure all required fields are filled
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select event date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select event start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate online event details if it's an online event
    if (_isOnline) {
      if (_meetingIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter meeting ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passcodeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter meeting passcode'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate location for non-online events
    if (!_isOnline && _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter event location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate registration details if registration is required
    if (_requiresRegistration && _registrationLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter registration link'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate certificate requirements if certificate is available
    if (_isCertificateAvailable &&
        _certificateRequirementsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter certificate requirements'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Upload image if a new one is selected
      String? imageUrl = _uploadedImageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage();
      }

      final event = Event(
        id: widget.event?.id ?? '',
        // Use existing ID if editing
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        location: _isOnline ? 'Online via Zoom' : _locationController.text,
        isOnline: _isOnline,
        isAccMembersOnly: _isAccMembersOnly,
        timeRange:
            '${_selectedTime!.format(context)} - ${_selectedEndTime?.format(context) ?? ''}',
        registrationLink:
            _requiresRegistration ? _registrationLinkController.text : null,
        meetingId: _isOnline ? _meetingIdController.text : null,
        passcode: _isOnline ? _passcodeController.text : null,
        presenter: _presenterController.text.isEmpty
            ? null
            : _presenterController.text,
        presenterTitle: _presenterTitleController.text.isEmpty
            ? null
            : _presenterTitleController.text,
        guidelines: _guidelines,
        category: _selectedCategory,
        series: _selectedSeries == 'None' ? null : _selectedSeries,
        requirements: _requirements,
        technicalRequirements: _isOnline ? _technicalRequirements : [],
        programEtiquette: _programEtiquette,
        targetAudience: _targetAudienceController.text,
        isCertificateAvailable: _isCertificateAvailable,
        certificateRequirements: _isCertificateAvailable
            ? _certificateRequirementsController.text
            : null,
        imageUrl: imageUrl,
        // Add the image URL
        applicationDeadline: _applicationDeadline,

        // New fields
        entryGuidelines: _entryGuidelines,
        minimumAge: int.tryParse(_minimumAgeController.text),
        securityRestrictions: _securityRestrictions,
        requireConfirmationEmail: _requireConfirmationEmail,
        mediaConsent: _mediaConsent,

      );
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Perform database operation
      if (widget.event == null) {
        await Provider.of<DatabaseProvider>(context, listen: false)
            .database
            .createEvent(event);
      } else {
        await Provider.of<DatabaseProvider>(context, listen: false)
            .database
            .updateEvent(event.id, event.toMap());
      }

      if (!mounted) return;

      // Pop the loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.event == null
              ? 'Event created successfully'
              : 'Event updated successfully'),
        ),
      );

      // Exit the screen
      if (mounted) {
        Navigator.of(context).pop(); // This will return to the previous screen
      }
    } catch (e) {
      if (!mounted) return;

      // Pop the loading dialog if it's showing
      Navigator.of(context).pop();

      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${widget.event == null ? 'create' : 'update'} event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
