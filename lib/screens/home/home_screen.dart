import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/event.dart';
import '../../models/workshop.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../event_details/event_details_screen.dart';
import 'home_tabs/events_tab.dart';
import 'home_tabs/workshops_tab.dart';
import 'home_tabs/membership_tab.dart';
import 'components/custom_sliver_appbar.dart';
import 'components/quick_action_section.dart';
import 'event_search_delegate.dart';

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
          CustomSliverAppBar(
            innerBoxIsScrolled: innerBoxIsScrolled,
            databaseService: _databaseService,
            onSearchPressed: () => _showSearchDialog(context),
          ),
        ],
        body: Column(
          children: [
            QuickActionSection(tabController: _tabController),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  EventsTab(databaseService: _databaseService),
                  WorkshopsTab(databaseService: _databaseService),
                  MembershipTab(),
                ],
              ),
            ),
          ],
        ),
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

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: EventSearchDelegate(_databaseService),
    );
  }
}