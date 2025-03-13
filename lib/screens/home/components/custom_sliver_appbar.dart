import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../services/database_service.dart';
import 'featured_events_carousel.dart';

class CustomSliverAppBar extends StatelessWidget {
  final bool innerBoxIsScrolled;
  final DatabaseService databaseService;
  final VoidCallback onSearchPressed;

  const CustomSliverAppBar({
    required this.innerBoxIsScrolled,
    required this.databaseService,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
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
        background: FeaturedEventsCarousel(databaseService: databaseService),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchPressed,
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
}