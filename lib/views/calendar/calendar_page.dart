import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/services/automations_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import '../../core/model/calendar_model.dart';
import 'create_task.dart';
import '../../core/widgets/task_card.dart';

// TODO:
// 1. fix colors
// 2. allow TaskCard selection (see task_card.dart)

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _automationsService = AutomationsService();
  List<Map<String, dynamic>> _automations = [];
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, Color> _moodHistory = {
    DateTime(2025, 12, 1): Colors.pink.shade100,
    DateTime(2025, 12, 2): Colors.blue.shade200,
    DateTime(2025, 12, 3): Colors.yellow.shade200,
    DateTime(2025, 12, 4): Colors.green.shade300,
    DateTime(2025, 12, 11): Colors.red.shade200,
    DateTime(2025, 12, 16): Colors.green.shade200,
  };

  final Map<DateTime, List<CalendarTask>> _events = {
    DateTime(2025, 12, 30): [
      CalendarTask(title: "Go for a walk", time: "Today", color: Color(0xFFA8C69F)),
    ],
    DateTime(2025, 12, 31): [
      CalendarTask(title: "Go for a walk", time: "Tomorrow", color: Colors.grey.shade200),
    ],
    DateTime(2025, 12, 20): [
      CalendarTask(title: "Go for a walk", time: "December 20, 2025", color: Colors.grey.shade200),
    ],
  };

  List<CalendarTask> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = _getEventsForDay(_selectedDay!);
    _loadAutomations();
  }

  Future<void> _loadAutomations() async {
    setState(() => _isLoading = true);
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final automations = await _automationsService.getAutomations(user.id);
        setState(() {
          _automations = automations;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading automations: $e');
      setState(() => _isLoading = false);
    }
  }

  List<CalendarTask> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildCustomCalendar(),
              const SizedBox(height: 24),
              // _buildMoodInputArea(),
              const SizedBox(height: 32),
              _buildUpcomingSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: CircleBorder(),
        backgroundColor: const Color(0xFFA8C69F),
        onPressed: () async {
          await _showCreateTaskSheet(context);
          _loadAutomations(); // Reload automations after creating a task
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCustomCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay, // Required for event markers
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        headerPadding: EdgeInsets.only(bottom: 20),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
      calendarBuilders: CalendarBuilders(
        // Default day look (White circles)
        defaultBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.white),
        // Days from other months
        outsideBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.white, opacity: 0.3),
        // Today's highlight
        todayBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.grey.shade200, isToday: true),
        // Main marker builder to display Mood Colors and Event Dots
        markerBuilder: (context, day, events) {
          final normalizedDate = DateTime(day.year, day.month, day.day);

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Draw the Mood Circle if data exists
              if (_moodHistory.containsKey(normalizedDate))
                _buildDayItem(day, _moodHistory[normalizedDate]!),

              // 2. Draw the Event Dot if tasks exist
              if (events.isNotEmpty)
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedEvents = _getEventsForDay(selectedDay);
        });
      },
    );
  }

  Widget _buildDayItem(DateTime day, Color color, {double opacity = 1.0, bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: Colors.black,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget _buildMoodInputArea() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFA8C69F).withOpacity(0.6),
  //       borderRadius: BorderRadius.circular(28),
  //     ),
  //     child: const Text(
  //       "Share your thoughts..",
  //       style: TextStyle(color: Colors.white, fontSize: 16),
  //     ),
  //   );
  // }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_selectedEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No tasks for this day.", style: TextStyle(color: Colors.grey)),
          )
        else
          ..._selectedEvents.map((task) => TaskCard(
            title: task.title,
            subtitle: task.time,
            dotColor: task.color,
            isCompleted: task.isCompleted,
            onToggle: (val) {
              setState(() {
                // Toggle the boolean value
                task.isCompleted = !task.isCompleted;
              });
            },
          )).toList()
      ],
    );
  }

  Future<void> _showCreateTaskSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTask(),
    );
  }
}