import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class AlternativeContactInfo extends StatelessWidget {
  const AlternativeContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(AppSpacing.s16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alternative Contact Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _ContactMethod(
              icon: Icons.location_on,
              title: 'Address',
              detail: 'U.S. Embassy Cairo, 5 Tawfik Diab Street',
            ),
            _ContactMethod(
              icon: Icons.access_time,
              title: 'Opening Hours',
              detail: 'Monday-Thursday, 10:00 a.m. - 3:00 p.m.',
            ),
            _ContactMethod(
              icon: Icons.email,
              title: 'Email',
              detail: 'ACCairo@state.gov',
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _ContactMethod({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}