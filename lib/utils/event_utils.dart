import 'package:flutter/material.dart';

class EventUtils {
  static Future<bool> showUnregisterConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unregister from Event'),
            content: const Text('Are you sure you want to unregister?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Unregister'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
