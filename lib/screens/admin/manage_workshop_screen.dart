import 'package:flutter/material.dart';
import '../../models/workshop.dart';
import '../../services/database_service.dart';

class ManageWorkshopsScreen extends StatefulWidget {
  const ManageWorkshopsScreen({super.key});

  @override
  State<ManageWorkshopsScreen> createState() => _ManageWorkshopsScreenState();
}

class _ManageWorkshopsScreenState extends State<ManageWorkshopsScreen> {
  final DatabaseService _databaseService = DatabaseService();


  Future<void> _deleteWorkshop(String workshopId) async {
    try {
      await _databaseService.deleteWorkshop(workshopId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete workshop: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workshops'),
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: _databaseService.getWorkshops(), // Listen to the stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No workshops found.'),
            );
          }

          final workshops = snapshot.data!; // List of workshops from the stream

          return ListView.builder(
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return ListTile(
                title: Text(workshop.title),
                subtitle: Text(workshop.schedule),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteWorkshop(workshop.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}