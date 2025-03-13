import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventify/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/event.dart';
import '../../../services/database_service.dart';
import '../../event_details/event_details_screen.dart';

class FeaturedEventsCarousel extends StatelessWidget {
  final DatabaseService databaseService;

  const FeaturedEventsCarousel({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: databaseService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildCarouselPlaceholder();
        }

        final featuredEvents = snapshot.data!;
        return CarouselSlider.builder(
          itemCount: featuredEvents.length,
          itemBuilder: (context, index, realIndex) {
            final event = featuredEvents[index];
            return _buildFeaturedEventCard(event, context);
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

  Widget _buildCarouselPlaceholder() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 200,
                        height: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        enableInfiniteScroll: false,
        pauseAutoPlayOnTouch: true,
      ),
    );
  }

  Widget _buildFeaturedEventCard(Event event, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event, context),
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
                      formatDate(event.dateTime),
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

  void _navigateToEventDetails(Event event, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }
}