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

  // Hardcoded mood history for visual demo (you can connect this to logs later)
  final Map<DateTime, Color> _moodHistory = {
    DateTime(2025, 12, 1): Colors.pink.shade100,
    DateTime(2025, 12, 2): Colors.blue.shade200,
    DateTime(2025, 12, 3): Colors.yellow.shade200,
    DateTime(2025, 12, 4): Colors.green.shade300,
  };

  List<CalendarTask> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    // Start with empty events, they will load via _loadAutomations
    _selectedEvents = []; 
    _loadAutomations();
  }

  // Helper to remove time from dates for accurate comparison
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

          final dateStr = payload['start_date'];
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            final key = _normalizeDate(date);
            
            // Format time for display (e.g. 14:30)
            final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

            final task = CalendarTask(
              title: title,
              time: timeStr,
              color: const Color(0xFFA8C69F),
              isCompleted: status == 'completed',
            );

            if (loadedEvents[key] == null) {
              loadedEvents[key] = [];
            }
            loadedEvents[key]!.add(task);
          }
        }

        if (mounted) {
          setState(() {
            _events = loadedEvents;
            _selectedEvents = _getEventsForDay(_selectedDay!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          _loadAutomations(); // Reload after creating
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
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.white),
        outsideBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.white, opacity: 0.3),
        todayBuilder: (context, day, focusedDay) => _buildDayItem(day, Colors.grey.shade200, isToday: true),
        markerBuilder: (context, day, events) {
          final normalizedDate = _normalizeDate(day);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_moodHistory.containsKey(normalizedDate))
                _buildDayItem(day, _moodHistory[normalizedDate]!),
              
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
           const Center(child: CircularProgressIndicator())
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
            onToggle: (val) {
              setState(() {
                task.isCompleted = !task.isCompleted;
                });
            },
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