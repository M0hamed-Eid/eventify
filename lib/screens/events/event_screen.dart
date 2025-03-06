import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/database_provider.dart';
import '../../widgets/event_card/event_card.dart';
import 'event_details_screen.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _selectedCategory = 'All';
  bool _showOnlyMemberEvents = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filterEvents(List<Event> events) {
    return events.where((event) {
      // Category filter
      if (_selectedCategory != 'All' &&
          event.category != _selectedCategory) {
        return false;
      }

      // Members only filter
      if (_showOnlyMemberEvents && !event.isAccMembersOnly) {
        return false;
      }

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return event.title.toLowerCase().contains(searchTerm) ||
            event.description.toLowerCase().contains(searchTerm);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder<List<String>>(
        stream: Provider.of<DatabaseProvider>(context)
            .database
            .getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = ['All', ...snapshot.data!];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
      stream: Provider.of<DatabaseProvider>(context).database.getEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading events: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = _filterEvents(snapshot.data ?? []);

        if (events.isEmpty) {
          return const Center(
            child: Text('No events found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Implement refresh logic if needed
          },
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () => _navigateToEventDetails(event),
                onRegister: () => _registerForEvent(event),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Events',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show ACC Members Only Events'),
                    value: _showOnlyMemberEvents,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMemberEvents = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.setState(() {});
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    // Implement add event dialog or navigate to add event screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    );
  }

  void _navigateToEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }

  Future<void> _registerForEvent(Event event) async {
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await dbProvider.database.registerForEvent(
        event.id,
        'currentUserId', // Replace with actual user ID
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully registered for event'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Add Event Screen
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _presenterController = TextEditingController();
  final _presenterTitleController = TextEditingController();
  final _meetingIdController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _guidelines = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;
  String _selectedCategory = '';
  String? _selectedSeries;
  bool _isOnline = false;
  bool _isAccMembersOnly = false;

  final List<String> _categories = [
    'Education',
    'Career Development',
    'Language Learning',
    'Cultural Exchange',
    'Workshop',
  ];

  final List<String> _series = [
    'Future Focus',
    'English Conversation Club',
    'Study in the U.S.',
    'None',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _presenterController.dispose();
    _presenterTitleController.dispose();
    _meetingIdController.dispose();
    _passcodeController.dispose();
    _locationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
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

              // Category and Series Selection
              _buildSectionHeader('Event Type'),
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
              const SizedBox(height: 16),
              // Location and Access Section
              _buildSectionHeader('Location and Access'),
              SwitchListTile(
                title: const Text('Online Event'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
              if (_isOnline) ...[
                TextFormField(
                  controller: _meetingIdController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Passcode',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
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

              // Presenter Information
              _buildSectionHeader('Presenter Information (Optional)'),
              TextFormField(
                controller: _presenterController,
                decoration: const InputDecoration(
                  labelText: 'Presenter Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _presenterTitleController,
                decoration: const InputDecoration(
                  labelText: 'Presenter Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Guidelines Section
              _buildSectionHeader('Guidelines'),
              _buildGuidelinesList(),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Event'),
                ),
              ),
            ],
          ),
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
  Widget _buildGuidelinesList() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _guidelines.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_guidelines[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _guidelines.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Add Guideline',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _guidelines.add(value);
              });
            }
          },
        ),
      ],
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


  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedDate ?? DateTime.now(),
      firstDate: _selectedDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
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

// In _AddEventScreenState
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      try {
        final event = Event(
          id: '', // Will be set by Firestore
          title: _titleController.text,
          description: _descriptionController.text,
          dateTime: DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          ),
          location: _isOnline
              ? 'Online via Zoom'
              : _locationController.text.isEmpty
              ? 'ACC Location'
              : _locationController.text,
          isOnline: _isOnline,
          isAccMembersOnly: _isAccMembersOnly,
          timeRange: '${_selectedTime!.format(context)} - ${_selectedEndTime?.format(context) ?? _selectedTime!.replacing(hour: _selectedTime!.hour + 2).format(context)}',
          category: _selectedCategory,
          guidelines: _guidelines,
          presenter: _presenterController.text.isEmpty ? null : _presenterController.text,
          presenterTitle: _presenterTitleController.text.isEmpty ? null : _presenterTitleController.text,
          meetingId: _isOnline ? _meetingIdController.text : null,
          passcode: _isOnline ? _passcodeController.text : null,
          series: _selectedSeries == 'None' ? null : _selectedSeries,
        );

        final createdEvent = await Provider.of<DatabaseProvider>(context, listen: false)
            .database
            .createEvent(event);

        if (mounted) {
          Navigator.pop(context, createdEvent); // Return the created event
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create event: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}