import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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



  // Lists for requirements and guidelines
  final List<String> _guidelines = [];
  final List<String> _technicalRequirements = [
    'Zoom account required',
    'Stable internet connection',
    'Working microphone and camera',
  ];
  final List<String> _programEtiquette = [
    'Be on time',
    'Keep microphone muted unless speaking',
    'Use chat for questions',
    'Maintain professional conduct',
  ];
  final List<String> _requirements = [];

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
      _certificateRequirementsController.text = widget.event!.certificateRequirements ?? '';
      _registrationLinkController.text = widget.event!.registrationLink ?? '';

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
      _requiresRegistration = widget.event!.registrationLink?.isNotEmpty ?? false;
      _isCertificateAvailable = widget.event!.isCertificateAvailable;

      // Set lists
      _guidelines.addAll(widget.event!.guidelines);
      _technicalRequirements.addAll(widget.event!.technicalRequirements);
      _programEtiquette.addAll(widget.event!.programEtiquette);
      _requirements.addAll(widget.event!.requirements);
    }
  });}

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInformation(),
              _buildDateTime(),
              _buildLocation(),
              _buildRegistrationDetails(),
              _buildAudienceAndRequirements(),
              if (_isOnline) _buildOnlineEventDetails(),
              _buildProgramEtiquette(),
              _buildCertificationDetails(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Information'),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Event Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter event title' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Event Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter event description' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
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
          validator: (value) => value == null ? 'Please select a category' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Series (Optional)',
            border: OutlineInputBorder(),
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
    );
  }

  Widget _buildDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Date and Time'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : '',
                ),
                onTap: () => _selectDate(),
                validator: (_) => _selectedDate == null ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                controller: TextEditingController(
                  text: _selectedTime?.format(context) ?? '',
                ),
                onTap: () => _selectTime(),
                validator: (_) => _selectedTime == null ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                controller: TextEditingController(
                  text: _selectedEndTime?.format(context) ?? '',
                ),
                onTap: () => _selectEndTime(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Location'),
        SwitchListTile(
          title: const Text('Online Event'),
          value: _isOnline,
          onChanged: (value) {
            setState(() {
              _isOnline = value;
            });
          },
        ),
        if (!_isOnline)
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            validator: (value) => !_isOnline && (value?.isEmpty ?? true)
                ? 'Please enter location'
                : null,
          ),
      ],
    );
  }

  Widget _buildOnlineEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Online Meeting Details'),
        TextFormField(
          controller: _meetingIdController,
          decoration: const InputDecoration(
            labelText: 'Meeting ID',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _isOnline && (value?.isEmpty ?? true)
              ? 'Please enter meeting ID'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passcodeController,
          decoration: const InputDecoration(
            labelText: 'Passcode',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _isOnline && (value?.isEmpty ?? true)
              ? 'Please enter passcode'
              : null,
        ),
        const SizedBox(height: 16),
        _buildRequirementsList(
          'Technical Requirements',
          _technicalRequirements,
          'Add Technical Requirement',
        ),
      ],
    );
  }

  Widget _buildRegistrationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Registration'),
        SwitchListTile(
          title: const Text('Requires Registration'),
          value: _requiresRegistration,
          onChanged: (value) {
            setState(() {
              _requiresRegistration = value;
            });
          },
        ),
        if (_requiresRegistration) ...[
          TextFormField(
            controller: _registrationLinkController,
            decoration: const InputDecoration(
              labelText: 'Registration Link',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Application Deadline',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: _applicationDeadline != null
                  ? '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}'
                  : '',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _applicationDeadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _applicationDeadline = date;
                });
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAudienceAndRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Audience and Requirements'),
        TextFormField(
          controller: _targetAudienceController,
          decoration: const InputDecoration(
            labelText: 'Target Audience',
            border: OutlineInputBorder(),
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
        ),
        _buildRequirementsList(
          'Requirements',
          _requirements,
          'Add Requirement',
        ),
      ],
    );
  }

  Widget _buildProgramEtiquette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Program Etiquette'),
        _buildRequirementsList(
          'Program Rules',
          _programEtiquette,
          'Add Rule',
        ),
      ],
    );
  }

  Widget _buildCertificationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Certification'),
        SwitchListTile(
          title: const Text('Certificate Available'),
          value: _isCertificateAvailable,
          onChanged: (value) {
            setState(() {
              _isCertificateAvailable = value;
            });
          },
        ),
        if (_isCertificateAvailable)
          TextFormField(
            controller: _certificateRequirementsController,
            decoration: const InputDecoration(
              labelText: 'Certificate Requirements',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
      ],
    );
  }

  Widget _buildRequirementsList(
      String title,
      List<String> items,
      String addLabel,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
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
            border: const OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                items.add(value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(widget.event == null
            ? 'Create Event'
            : 'Update Event'
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
          (_selectedTime?.replacing(hour: _selectedTime!.hour + 1) ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {

    if (_formKey.currentState!.validate()) {
      try {
        final event = Event(
          id: widget.event?.id ?? '', // Use existing ID if editing
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
          timeRange: '${_selectedTime!.format(context)} - ${_selectedEndTime?.format(context)}',
          registrationLink: _requiresRegistration ? _registrationLinkController.text : null,
          meetingId: _isOnline ? _meetingIdController.text : null,
          passcode: _isOnline ? _passcodeController.text : null,
          presenter: _presenterController.text.isEmpty ? null : _presenterController.text,
          presenterTitle: _presenterTitleController.text.isEmpty ? null : _presenterTitleController.text,
          guidelines: _guidelines,
          category: _selectedCategory,
          series: _selectedSeries == 'None' ? null : _selectedSeries,
          requirements: _requirements,
          technicalRequirements: _isOnline ? _technicalRequirements : [],
          programEtiquette: _programEtiquette,
          targetAudience: _targetAudienceController.text,
          isCertificateAvailable: _isCertificateAvailable,
          certificateRequirements: _isCertificateAvailable ? _certificateRequirementsController.text : null,
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
                : 'Event updated successfully'
            ),
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
            content: Text('Failed to 2 ${widget.event == null ? 'create' : 'update'} event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}