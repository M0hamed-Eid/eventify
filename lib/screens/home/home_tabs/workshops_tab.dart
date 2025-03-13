import 'package:flutter/material.dart';
import '../../../models/workshop.dart';
import '../../../services/database_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/workshop_item.dart';

class WorkshopsTab extends StatelessWidget {
  final DatabaseService databaseService;

  const WorkshopsTab({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Workshop>>(
      stream: databaseService.getWorkshops(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ShowErrorWidget(message: "Error loading workshops");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoader();
        }

        final workshops = snapshot.data ?? [];

        if (workshops.isEmpty) {
          return EmptyStateWidget(message: "No workshops available");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workshops.length,
          itemBuilder: (context, index) {
            return WorkshopItem(workshop: workshops[index]);
          },
        );
      },
    );
  }
}