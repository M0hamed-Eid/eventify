import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../services/database_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/event_card/event_card.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../event_details/event_details_screen.dart';
import '../../../widgets/error_widget.dart';

class EventsTab extends StatelessWidget {
  final DatabaseService databaseService;

  const EventsTab({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Today\'s Events'),
                _buildTodayEvents(context),
                _buildSectionTitle(context, 'Upcoming Events'),
                _buildUpcomingEvents(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTodayEvents(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: databaseService.getTodayEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ShowErrorWidget(message: "Error loading today's events");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoader();
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return EmptyStateWidget(message: "No events today");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () => _navigateToEventDetails(events[index], context),
              onRegister: () => _registerForEvent(events[index], context),
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: databaseService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ShowErrorWidget(message: "Error loading upcoming events");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoader();
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return EmptyStateWidget(message: "No upcoming events");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () => _navigateToEventDetails(events[index], context),
              onRegister: () => _registerForEvent(events[index], context),
            );
          },
        );
      },
    );
  }

  void _navigateToEventDetails(Event event, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }

  void _registerForEvent(Event event, BuildContext context) {
    // Registration logic
  }
}