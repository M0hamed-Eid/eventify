import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';
import '../event_details/event_details_screen.dart';
import 'package:intl/intl.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen>
    with SingleTickerProviderStateMixin {

  late final ValueNotifier<List<Event>> _selectedEvents;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isCalendarView = true;

  // New UI-related variables
  late AnimationController _animationController;
  bool _isListView = false;
  bool _isLoading = true;

  List<Event> allEvents = [];
  Map<DateTime, List<Event>> _events = {};
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<Event>>? _eventsSubscription;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _initializeEvents();
    _setupEventsListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventsSubscription?.cancel();
    _selectedEvents.dispose();
    super.dispose();
  }


  Future<void> _initializeEvents() async {
    setState(() => _isLoading = true);
    try {
      final List<Event> fetchedEvents = await _databaseService.getEvents();
      if (mounted) {
        setState(() {
          allEvents = fetchedEvents;
          _events = _groupEventsByDay();
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error loading events: $e');
      }
    }
  }

  void _setupEventsListener() {
    _eventsSubscription = _databaseService.getEventsStream().listen(
          (events) {
        if (mounted) {
          setState(() {
            allEvents = events;
            _events = _groupEventsByDay();
            _selectedEvents.value = _getEventsForDay(_selectedDay!);
          });
        }
      },
      onError: (error) {
        _showErrorSnackBar('Error updating events: $error');
      },
    );
  }

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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Event Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[900]!,
                      Colors.blue[600]!,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.list_view,
                  progress: _animationController,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                    _isListView
                        ? _animationController.forward()
                        : _animationController.reverse();
                  });
                },
              ),
            ],
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _initializeEvents,
          child: PageTransitionSwitcher(
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: _isListView
                ? _buildEventListView()
                : _buildCalendarView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        _buildEnhancedCalendar(),
        Expanded(child: _buildDayEvents()),
      ],
    );
  }

  Widget _buildEnhancedCalendar() {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: TableCalendar<Event>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: Colors.blue[900],
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue[900],
            shape: BoxShape.circle,
          ),
          todayDecoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _selectedEvents.value = _getEventsForDay(selectedDay);
            });
          }
        },
      ),
    );
  }

  Widget _buildEventListView() {
    final sortedEvents = List<Event>.from(allEvents)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return _buildEnhancedEventCard(event);
      },
    );
  }

  Widget _buildEnhancedEventCard(Event event) {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedBuilder: (context, action) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[900]!,
                Colors.blue[600]!,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Event Date Container
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(event.dateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      event.dateTime.day.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Event Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            event.isOnline ? Icons.videocam : Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.timeRange,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      openBuilder: (context, action) => EventDetailsScreen(event: event),
    );
  }

  Widget _buildDayEvents() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        return events.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.blue[900]?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No events for this day',
                style: TextStyle(
                  color: Colors.blue[900]?.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEnhancedEventCard(events[index]);
          },
        );
      },
    );
  }
}