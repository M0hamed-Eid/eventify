import 'package:flutter/material.dart';

class ShowErrorWidget extends StatelessWidget {
  final String message;
  const ShowErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}