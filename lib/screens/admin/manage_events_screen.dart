import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';
import 'add_event_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showPastEvents = false;

  final List<String> _categories = [
    'All',
    'Education',
    'Career Development',
    'Language Learning',
    'Cultural Exchange',
    'Workshop',
    'Information Session',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewEvent(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _databaseService.getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorView(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = _filterEvents(snapshot.data ?? []);

                if (events.isEmpty) {
                  return _buildEmptyView();
                }

                return _buildEventsList(events);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'All';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Show Past Events'),
                selected: _showPastEvents,
                onSelected: (value) {
                  setState(() {
                    _showPastEvents = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    print('num of events : ${events.length}');
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isPastEvent = event.dateTime.isBefore(DateTime.now());

        return Dismissible(
          key: Key(event.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _confirmDelete(context, event),
          onDismissed: (direction) {
            _databaseService.deleteEvent(event.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${event.title} deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    // Implement undo functionality
                  },
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isPastEvent ? Colors.grey : Theme.of(context).primaryColor,
                child: Icon(
                  event.isOnline ? Icons.video_call : Icons.event,
                  color: Colors.white,
                ),
              ),
              title: Text(
                event.title,
                style: TextStyle(
                  decoration: isPastEvent ? TextDecoration.lineThrough : null,
                  color: isPastEvent ? Colors.grey : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(event.dateTime),
                    style: TextStyle(
                      color: isPastEvent ? Colors.grey : null,
                    ),
                  ),
                  Text(
                    event.timeRange,
                    style: TextStyle(
                      color: isPastEvent ? Colors.grey : null,
                    ),
                  ),
                  if (event.isAccMembersOnly)
                    const Text(
                      'ACC Members Only',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicate'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editEvent(context, event);
                      break;
                    case 'duplicate':
                      _duplicateEvent(context, event);
                      break;
                    case 'delete':
                      _confirmDelete(context, event);
                      break;
                  }
                },
              ),
              onTap: () => _editEvent(context, event),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No events found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _addNewEvent(context),
            child: const Text('Add New Event'),
          ),
        ],
      ),
    );
  }

  List<Event> _filterEvents(List<Event> events) {
    return events.where((event) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!event.title.toLowerCase().contains(query) &&
            !event.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'All' && event.category != _selectedCategory) {
        return false;
      }

      // Filter past events
      if (!_showPastEvents && event.dateTime.isBefore(DateTime.now())) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _addNewEvent(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );
    }
  }

  Future<void> _editEvent(BuildContext context, Event event) async {
    // Navigate to edit event screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(event: event),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
    }
  }

  Future<void> _duplicateEvent(BuildContext context, Event event) async {
    // Implement event duplication logic
  }

  Future<bool> _confirmDelete(BuildContext context, Event event) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: Text('Are you sure you want to delete "${event.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('DELETE'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
