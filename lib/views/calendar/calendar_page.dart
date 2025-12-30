import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'create_task.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock data: Day -> Mood Color
  final Map<DateTime, Color> _moodHistory = {
    DateTime(2025, 12, 1): Colors.blue.shade200,
    DateTime(2025, 12, 2): Colors.yellow.shade200,
    DateTime(2025, 12, 3): Colors.green.shade300,
    DateTime(2025, 12, 11): Colors.red.shade200,
    DateTime(2025, 12, 16): Colors.green.shade200,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomCalendar(),
              const SizedBox(height: 24),
              _buildMoodInputArea(),
              const SizedBox(height: 32),
              _buildUpcomingSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA8C69F), // Sage green from design
        onPressed: () => _showCreateTaskSheet(context),
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
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _buildMoodCircle(day, Colors.transparent),
        outsideBuilder: (context, day, focusedDay) => _buildMoodCircle(day, Colors.transparent, opacity: 0.3),
        todayBuilder: (context, day, focusedDay) => _buildMoodCircle(day, Colors.grey.shade200, isToday: true),
        // This is where the magic happens: Color dates based on mood history
        markerBuilder: (context, day, events) {
          final normalizedDate = DateTime(day.year, day.month, day.day);
          if (_moodHistory.containsKey(normalizedDate)) {
            return _buildMoodCircle(day, _moodHistory[normalizedDate]!);
          }
          return null;
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildMoodCircle(DateTime day, Color color, {double opacity = 1.0, bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // If the color passed is transparent (no mood), use White instead
        color: color == Colors.transparent ? Colors.white : color.withOpacity(opacity),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withOpacity(0.1), // Slightly darker border for visibility
          width: 1,
        ),
        boxShadow: [
          if (color != Colors.transparent) // Optional: add a tiny shadow to mood dates
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
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
  }

  Widget _buildMoodInputArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFA8C69F).withOpacity(0.6), // Matching your sage box
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Text(
        "Share your thoughts..",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTaskItem("Go for a walk", "Today", const Color(0xFFA8C69F)),
        _buildTaskItem("Go for a walk", "Tomorrow", Colors.grey.shade200),
        _buildTaskItem("Go for a walk", "December 20, 2025", Colors.grey.shade200),
      ],
    );
  }

  Widget _buildTaskItem(String title, String subtitle, Color dotColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: dotColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTask(),
    );
}
