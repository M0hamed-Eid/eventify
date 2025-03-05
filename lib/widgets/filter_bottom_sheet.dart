import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _showOnlyMemberEvents = false;
  bool _showOnlyOnlineEvents = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('ACC Members Only Events'),
            value: _showOnlyMemberEvents,
            onChanged: (value) {
              setState(() {
                _showOnlyMemberEvents = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Online Events Only'),
            value: _showOnlyOnlineEvents,
            onChanged: (value) {
              setState(() {
                _showOnlyOnlineEvents = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters({
                'membersOnly': _showOnlyMemberEvents,
                'onlineOnly': _showOnlyOnlineEvents,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3C8F),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}