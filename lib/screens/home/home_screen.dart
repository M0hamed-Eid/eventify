import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/event.dart';
import '../../models/workshop.dart';
import '../../widgets/event_card/event_card.dart';
import '../../services/database_service.dart';
import '../events/event_details_screen.dart';
import 'event_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACC Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Today\'s Events'),
              _buildTodayEvents(),
              _buildSectionTitle('Upcoming Events'),
              _buildUpcomingEvents(),
              _buildSectionTitle('Workshops and More'),
              _buildWorkshopsAndMore(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  Widget _buildTodayEvents() {
    return StreamBuilder<List<Event>>(
      stream: _databaseService.getTodayEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget("Error loading today's events");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEventShimmer();
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return _buildEmptyStateWidget("No events today");
        }

        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: EventCard(
                      event: events[index],
                      onTap: () => _navigateToEventDetails(events[index]),
                      onRegister: () => _registerForEvent(events[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return StreamBuilder<List<Event>>(
      stream: _databaseService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget("Error loading upcoming events");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEventShimmer();
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return _buildEmptyStateWidget("No upcoming events");
        }

        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: EventCard(
                      event: events[index],
                      onTap: () => _navigateToEventDetails(events[index]),
                      onRegister: () => _registerForEvent(events[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkshopsAndMore() {
    return StreamBuilder<List<Workshop>>(
      stream: _databaseService.getWorkshops(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget("Error loading workshops");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildWorkshopShimmer();
        }

        final workshops = snapshot.data ?? [];

        if (workshops.isEmpty) {
          return _buildEmptyStateWidget("No workshops available");
        }

        return AnimationLimiter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[50]!,
                  Colors.blue[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[200]!.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workshops & Programs',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.blue[700],
                        size: 30,
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  workshops.length,
                      (index) => AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildWorkshopItem(workshops[index], index),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkshopItem(Workshop workshop, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getWorkshopColor(index),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getWorkshopIcon(workshop.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          workshop.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              workshop.status,
              style: TextStyle(
                color: _getStatusColor(workshop.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  workshop.schedule,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blue[700],
        ),
        onTap: () {
          // Navigate to workshop details or show more info
          _showWorkshopDetailsBottomSheet(workshop);
        },
      ),
    );
  }

  Color _getWorkshopColor(int index) {
    final colors = [
      Colors.blue[700],
      Colors.green[700],
      Colors.purple[700],
      Colors.orange[700],
      Colors.teal[700],
    ];
    return colors[index % colors.length]!;
  }

  IconData _getWorkshopIcon(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Icons.event_available;
      case 'ongoing':
        return Icons.play_circle_filled;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.workspace_premium;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.orange;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showWorkshopDetailsBottomSheet(Workshop workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.info_outline,
                  'Status',
                  workshop.status,
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Schedule',
                  workshop.schedule,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Add registration or more details logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Column(
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            ...List.generate(
              3,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            color: Colors.grey[400],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: EventSearchDelegate(_databaseService),
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
      await _databaseService.registerForEvent(
        event.id,
        'currentUserId', // Replace with actual user ID
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// The EventSearchDelegate remains the same as in the previous implementation