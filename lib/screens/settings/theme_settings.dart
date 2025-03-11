import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Predefined MaterialColor options
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Color Themes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: colors.map((color) {
                return _buildColorOption(context, color);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, MaterialColor color) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        themeProvider.setColor(color);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: themeProvider.primaryColor == color
              ? Border.all(color: Colors.white, width: 4)
              : null,
        ),
      ),
    );
  }
}