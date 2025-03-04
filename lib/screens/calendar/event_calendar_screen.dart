import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/event.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = true; // Toggle between calendar and list view

  // Sample events - Replace with your actual events data
  final List<Event> allEvents = [
    Event(
      id: '1',
      title: 'Stay Safe Online',
      description: 'Learn about online safety and security',
      dateTime: DateTime.now(),
      location: 'Online via Zoom',
      isOnline: true,
      isAccMembersOnly: false,
      timeRange: '1:00 - 2:30 p.m.',
      registrationLink: 'bit.ly/MediaLit25', guidelines: [],
    ),
    Event(
      id: '2',
      title: 'English Conversation Club',
      description: 'Famous People from the American South',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      location: 'ACC',
      isOnline: false,
      isAccMembersOnly: true,
      timeRange: '2:00 - 3:00 p.m.', guidelines: [],
    ),
    // Add more events...
  ];

  // Convert list of events to map for calendar
  late final Map<DateTime, List<Event>> _events = _groupEventsByDay();

  Map<DateTime, List<Event>> _groupEventsByDay() {
    Map<DateTime, List<Event>> eventsByDay = {};
    for (var event in allEvents) {
      DateTime day = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      if (eventsByDay[day] == null) eventsByDay[day] = [];
      eventsByDay[day]!.add(event);
    }
    return eventsByDay;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Calendar'),
        actions: [
          // Toggle between calendar and list view
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isCalendarView) _buildCalendarView() else _buildListViewHeader(),
          Expanded(
            child: _isCalendarView
                ? _buildSelectedDayEvents()
                : _buildCompleteEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return TableCalendar<Event>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: const CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: Color(0xFF1B3C8F),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF1B3C8F),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedEvents.value = _getEventsForDay(selectedDay);
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildListViewHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        return events.isEmpty
            ? const Center(
          child: Text('No events for this day'),
        )
            : ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index]);
          },
        );
      },
    );
  }

  Widget _buildCompleteEventsList() {
    // Sort events by date
    final sortedEvents = List<Event>.from(allEvents)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];

        // Add date header if it's the first event or if the date changed
        final bool showHeader = index == 0 ||
            !isSameDay(sortedEvents[index - 1].dateTime, event.dateTime);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _formatDate(event.dateTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _buildEventCard(event),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Customize this based on your needs
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1B3C8F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  event.isOnline ? Icons.video_call : Icons.location_on,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (event.isAccMembersOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACC Members Only',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time: ${event.timeRange}'),
                Text('Location: ${event.location}'),
                if (event.registrationLink != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle registration
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3C8F),
                    ),
                    child: const Text('Register Now'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}