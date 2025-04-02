import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildCustomSliverAppBar(innerBoxIsScrolled),
        ],
        body: _buildMainContent(),
      ),
    );
  }


  Widget _buildCustomSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 4,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'ACC Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        background: _buildFeaturedEventsCarousel(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Navigate to notifications screen
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedEventsCarousel() {
    return StreamBuilder<List<Event>>(
      stream: _databaseService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCarousel();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCarousel();
        }

        final featuredEvents = snapshot.data!;
        return CarouselSlider.builder(
          itemCount: featuredEvents.length,
          itemBuilder: (context, index, realIndex) {
            final event = featuredEvents[index];
            return _buildFeaturedEventCard(event);
          },
          options: CarouselOptions(
            height: 250,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            autoPlayInterval: const Duration(seconds: 5),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[100]!,
            Colors.blue[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 50,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCarousel() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading events',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCarouselPlaceholder() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[500],
                    size: 50,
                  ),
                ),
              ),

              // Placeholder content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        enableInfiniteScroll: false,
      ),
    );
  }

  // More stylized placeholder
  Widget _buildStylizedCarouselPlaceholder() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[500],
                    size: 50,
                  ),
                ),
              ),

              // Placeholder content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        enableInfiniteScroll: false,
      ),
    );
  }




  Widget _buildFeaturedEventCard(Event event) {
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: CachedNetworkImageProvider(event.imageUrl ?? ''),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEE, MMM d').format(event.dateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200, // Adjust this value as needed
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(),
                _buildWorkshopsTab(),
                _buildMembershipTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.blue[900],
      labelColor: Colors.blue[900],
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: 'Events', icon: Icon(Icons.event)),
        Tab(text: 'Workshops', icon: Icon(Icons.workspace_premium)),
        Tab(text: 'Membership', icon: Icon(Icons.card_membership)),
      ],
    );
  }


  Widget _buildEventsTab() {
    return RefreshIndicator(
      onRefresh: _refreshContent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Today\'s Events'),
                _buildTodayEvents(),
                _buildSectionTitle('Upcoming Events'),
                _buildUpcomingEvents(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopsTab() {
    return _buildWorkshopsAndMore();
  }

  Widget _buildMembershipTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMembershipCard(),
            const SizedBox(height: 16),
            _buildMembershipBenefits(),
          ],
        ),
      ),
    );
  }


  Widget _buildMembershipCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Membership',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: Active',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to membership details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Manage Membership'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipBenefits() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Benefits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem('Access to Exclusive Events'),
            _buildBenefitItem('Discounted Workshop Rates'),
            _buildBenefitItem('Digital Library Access'),
            _buildBenefitItem('Networking Opportunities'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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

