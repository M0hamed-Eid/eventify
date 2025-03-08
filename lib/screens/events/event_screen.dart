import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/database_provider.dart';
import '../../widgets/event_card/event_card.dart';
import '../admin/add_event_screen.dart';
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
      print('Error registering for event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}