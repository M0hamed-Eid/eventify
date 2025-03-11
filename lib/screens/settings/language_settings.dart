import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Language Settings')),
      body: ListView.builder(
        itemCount: languageProvider.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = languageProvider.supportedLanguages[index];
          return ListTile(
            title: Text(language.name),
            trailing: Radio<String>(
              value: language.code,
              groupValue: languageProvider.currentLanguageCode,
              onChanged: (value) {
                if (value != null) {
                  languageProvider.changeLanguage(value);
                }
              },
            ),
          );
        },
      ),
    );
  }
}