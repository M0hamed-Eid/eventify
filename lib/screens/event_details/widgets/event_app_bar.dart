import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/event.dart';
import 'event_tags.dart';

class EventAppBar extends StatelessWidget {
  final Event event;

  const EventAppBar({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildEventImage(),
            _buildGradientOverlay(),
            _buildEventDetails(),
          ],
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return event.imageUrl != null
        ? CachedNetworkImage(
      imageUrl: event.imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error),
      ),
    )
        : Container(
      color: Colors.blue[100],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return DecoratedBox(
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
    );
  }

  Widget _buildEventDetails() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventTitle(),
          const SizedBox(height: 10),
          EventTags(event: event),
        ],
      ),
    );
  }

  Widget _buildEventTitle() {
    return Text(
      event.title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2.0, 2.0),
          ),
        ],
      ),
    );
  }
}

/*
// Optional: Custom AppBar actions
class EventAppBarActions extends StatelessWidget {
  final Event event;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;

  const EventAppBarActions({
    super.key,
    required this.event,
    this.onShare,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          color: Colors.white,
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          color: Colors.white,
          onPressed: onBookmark,
        ),
      ],
    );
  }
}

// Optional: Custom back button
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// Optional: Hero animation wrapper
class EventImageHero extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;

  const EventImageHero({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: imageUrl != null
          ? CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      )
          : Container(
        color: Colors.blue[100],
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// Optional: Shimmer loading effect
class EventAppBarShimmer extends StatelessWidget {
  const EventAppBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350.0,
      floating: false,
      pinned: true,
      flexibleSpace: Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}*/
