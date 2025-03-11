import 'package:flutter/material.dart';
import 'theme_settings.dart';
import 'language_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSettingsSection(
            context: context,
            title: 'Appearance',
            icon: Icons.palette,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsScreen(),
              ),
            ),
          ),
          _buildSettingsSection(
            context: context,
            title: 'Language',
            icon: Icons.language,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSettingsScreen(),
              ),
            ),
          ),
          _buildSettingsSection(
            context: context,
            title: 'Notifications',
            icon: Icons.notifications,
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _buildSettingsSection(
            context: context,
            title: 'Privacy & Security',
            icon: Icons.security,
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}