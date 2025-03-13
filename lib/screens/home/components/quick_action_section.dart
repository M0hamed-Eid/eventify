import 'package:flutter/material.dart';

class QuickActionSection extends StatelessWidget {
  final TabController tabController;

  const QuickActionSection({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.event,
              label: 'My Events',
              onTap: () {
                // Navigate to my events
              },
            ),
            _buildQuickActionButton(
              icon: Icons.bookmark,
              label: 'Saved',
              onTap: () {
                // Navigate to saved events
              },
            ),
            _buildQuickActionButton(
              icon: Icons.workspace_premium,
              label: 'Workshops',
              onTap: () {
                tabController.animateTo(1);
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
}