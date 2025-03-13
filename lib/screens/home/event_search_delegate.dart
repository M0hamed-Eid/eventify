import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';

class EventSearchDelegate extends SearchDelegate<Event> {
  final DatabaseService databaseService;

  EventSearchDelegate(this.databaseService);

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
        close(context, Event.empty() as Event); // Return a default Event object
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Event>>(
      stream: databaseService.searchEvents(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              title: Text(event.title),
              onTap: () {
                close(context, event);
              },
            );
          },
        );
      },
    );
  }
}