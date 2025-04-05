import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ContactHeader extends StatelessWidget {
  const ContactHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      color: AppColors.primary,
      child: Column(
        children: [
          const Icon(
            Icons.contact_support,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.s16),
          const Text(
            'Get in Touch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'We\'ll get back to you as soon as possible',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}