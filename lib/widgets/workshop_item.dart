import 'package:flutter/material.dart';
import '../../models/workshop.dart';

class WorkshopItem extends StatelessWidget {
  final Workshop workshop;

  const WorkshopItem({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(workshop.title),
      subtitle: Text(workshop.status),
      onTap: () {
        // Show workshop details
      },
    );
  }
}