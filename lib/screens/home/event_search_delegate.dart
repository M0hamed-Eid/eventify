import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../services/database_service.dart';
import '../../widgets/event_card/event_card.dart';

class EventSearchDelegate extends SearchDelegate {
  final DatabaseService _databaseService;

  EventSearchDelegate(this._databaseService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),  
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _databaseService.searchEvents(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text('No events found'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () {
                close(context, events[index]);
              },
              onRegister: () async {
                // Handle registration
                try {
                  await _databaseService.registerForEvent(
                    events[index].id,
                    'currentUserId', // Replace with actual user ID
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully registered for event'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to register: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
