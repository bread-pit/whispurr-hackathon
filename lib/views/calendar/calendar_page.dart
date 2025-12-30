import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/services/automations_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import '../../core/model/calendar_model.dart';
import 'create_task.dart';
import '../../core/widgets/task_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _automationsService = AutomationsService();
  
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Stores events fetched from backend
  Map<DateTime, List<CalendarTask>> _events = {};

  // REMOVED: _moodHistory (Fixed issue where random colors appeared on the calendar)

  List<CalendarTask> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    _selectedEvents = []; 
    _loadAutomations();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadAutomations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final data = await _automationsService.getAutomations(user.id);
        
        final Map<DateTime, List<CalendarTask>> loadedEvents = {};

        for (var item in data) {
          final payload = item['payload'] ?? {};
          final title = item['title'] ?? 'Untitled';
          final status = item['status'] ?? 'pending';
          final id = item['id']; 

          final dateStr = payload['start_date'];
          final endDateStr = payload['end_date'];

          if (dateStr != null) {
            final startDate = DateTime.parse(dateStr);
            final endDate = endDateStr != null ? DateTime.parse(endDateStr) : startDate;
            
            final timeStr = "${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}";

            final task = CalendarTask(
              id: id, 
              title: title,
              time: timeStr,
              color: const Color(0xFFA8C69F),
              isCompleted: status == 'completed',
            );

            for (var day = _normalizeDate(startDate);
                !day.isAfter(_normalizeDate(endDate));
                day = day.add(const Duration(days: 1))) {
              
              if (loadedEvents[day] == null) {
                loadedEvents[day] = [];
              }
              if (!loadedEvents[day]!.any((t) => t.id == task.id)) {
                loadedEvents[day]!.add(task);
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _events = loadedEvents;
            if (_selectedDay != null) {
              _selectedEvents = _getEventsForDay(_selectedDay!);
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading automations: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CalendarTask> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  Future<void> _handleTaskToggle(CalendarTask task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });

    if (task.id != null) {
      try {
        final newStatus = task.isCompleted ? 'completed' : 'pending';
        await _automationsService.updateStatus(task.id!, newStatus);
      } catch (e) {
        if (mounted) {
          setState(() {
            task.isCompleted = !task.isCompleted;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update task status')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Safe background color
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAutomations,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildCustomCalendar(),
                const SizedBox(height: 32),
                _buildUpcomingSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFA8C69F),
        onPressed: () async {
          await _showCreateTaskSheet(context);
          _loadAutomations(); // Reloads calendar after creating task
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
      eventLoader: _getEventsForDay, 
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        headerPadding: EdgeInsets.only(bottom: 20),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
      calendarStyle: const CalendarStyle(
        // Default style for Today (Grey circle)
        todayDecoration: BoxDecoration(
          color: Color(0xFFEEEEEE), 
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: Colors.black),
        // Default style for Selected Day (Green circle)
        selectedDecoration: BoxDecoration(
          color: Color(0xFFA8C69F), 
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // Custom Marker Builder (The Dots)
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            return Positioned(
              bottom: 12,
              child: Container(
                width: 6, // Made slightly bigger for visibility
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFA8C69F), // Green color to "light up"
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
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

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
           const Center(child: Padding(
             padding: EdgeInsets.all(20.0),
             child: CircularProgressIndicator(color: Color(0xFFA8C69F)),
           ))
        else if (_selectedEvents.isEmpty)
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
            onToggle: (val) => _handleTaskToggle(task),
          )),
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