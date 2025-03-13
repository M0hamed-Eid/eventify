import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/event.dart';
import '../../models/workshop.dart';
import '../../services/auth_service.dart';
import '../../widgets/event_card/event_card.dart';
import '../../services/database_service.dart';
import '../event_details/event_details_screen.dart';
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
      body: CustomScrollView(
        slivers: [
          _buildCustomSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActionButtons(),
                _buildSectionTitle('Today\'s Events'),
                _buildTodayEvents(),
                _buildSectionTitle('Upcoming Events'),
                _buildUpcomingEvents(),
                _buildSectionTitle('Workshops & Programs'),
                _buildWorkshopsAndMore(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'ACC Events',
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/event_background.png', // Add a background image
              fit: BoxFit.scaleDown,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.event,
              label: 'My Events',
              onTap: () {
                // Navigate to user's registered events
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.bookmark,
              label: 'Saved',
              onTap: () {
                // Navigate to saved events
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.workspace_premium,
              label: 'Workshops',
              onTap: () {
                // Scroll to workshops section
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onTap,
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
      // Ensure the user is authenticated
      final userId = AuthService().currentUser?.uid;
      if (userId == null) {
        // Show login prompt
        _showLoginRequiredDialog();
        return;
      }

      // Check event registration status
      final registrationStatus =
          await _checkEventRegistrationStatus(event, userId);

      switch (registrationStatus) {
        case RegistrationStatus.available:
          await _performEventRegistration(event, userId);
          break;
        case RegistrationStatus.full:
          _showWaitlistDialog(event);
          break;
        case RegistrationStatus.memberOnly:
          _showMemberOnlyDialog(event);
          break;
        case RegistrationStatus.alreadyRegistered:
          _showAlreadyRegisteredDialog(event);
          break;
      }
    } catch (e) {
      _handleRegistrationError(e);
    }
  }
  Future<RegistrationStatus> _checkEventRegistrationStatus(Event event, String userId) async {
    // Check if the user is already registered
    final registrationCheck = await _databaseService.checkEventRegistrationStatus(event.id, userId);
    if (registrationCheck['isRegistered'] == true) {
      return RegistrationStatus.alreadyRegistered;
    }

    // Check if event is members only and user is not a member
    if (event.isAccMembersOnly && !await _checkMemberStatus(userId)) {
      return RegistrationStatus.memberOnly;
    }

    // Check if event is full
    final currentRegistrations = await _databaseService.getCurrentRegistrationsCount(event.id);
    if (currentRegistrations >= event.maxParticipants) {
      return RegistrationStatus.full;
    }

    return RegistrationStatus.available;
  }

  Future<void> _performEventRegistration(Event event, String userId) async {
    try {
      final result = await _databaseService.registerForEvent(event.id, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 'confirmed'
                ? 'Successfully registered for the event!'
                : 'You have been added to the waitlist.'),
            backgroundColor: result == 'confirmed' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      _handleRegistrationError(e);
    }
  }

  Future<bool> _checkMemberStatus(String userId) async {
    // Implement logic to check if user is a member
    return await _databaseService.checkMemberStatus(userId);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to register for events.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              // Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showWaitlistDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Full'),
        content: Text('${event.title} is currently full. Would you like to join the waitlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _joinWaitlist(event);
            },
            child: const Text('Join Waitlist'),
          ),
        ],
      ),
    );
  }

  void _showMemberOnlyDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Members Only Event'),
        content: Text('${event.title} is only available to ACC members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to membership information or upgrade page
              // Navigator.pushNamed(context, '/membership');
            },
            child: const Text('Learn About Membership'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyRegisteredDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Registered'),
        content: Text('You are already registered for ${event.title}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinWaitlist(Event event) async {
    try {
      final userId = AuthService().currentUser?.uid;
      if (userId == null) return;

      await _databaseService.addToWaitlist(event.id, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to waitlist for ${event.title}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _handleRegistrationError(e);
    }
  }

  void _handleRegistrationError(dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}

enum RegistrationStatus {
  available,
  full,
  memberOnly,
  alreadyRegistered
}

