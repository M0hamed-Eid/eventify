import 'package:flutter/material.dart';
import 'widgets/contact_header.dart';
import 'widgets/contact_form.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            ContactHeader(),
            ContactForm(),
          ],
        ),
      ),
    );
  }
}