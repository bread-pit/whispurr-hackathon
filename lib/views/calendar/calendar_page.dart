import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Map<DateTime, List<CalendarTask>> _events = {};
  List<CalendarTask> _selectedEvents = [];
  final Map<DateTime, Color> _moodColors = {};
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    _loadData();
    
    _subscription = SupabaseService.client.channel('public:db_changes')
        .onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', callback: (payload) => _loadData())
        .subscribe();
  }

  @override
  void dispose() {
    if (_subscription != null) SupabaseService.client.removeChannel(_subscription!);
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _loadData() async {
    if (!mounted) return;
    if (_events.isEmpty) setState(() => _isLoading = true);
    
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) await Future.wait([_loadTasks(user.id), _loadMoods(user.id)]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMoods(String userId) async {
    try {
      final response = await SupabaseService.client.from('logs').select('created_at, mood').eq('user_id', userId);
      final Map<DateTime, Color> newMap = {};
      for (var log in response) {
        final date = DateTime.parse(log['created_at']);
        final mood = log['mood'] as String?;
        Color c = Colors.transparent;
        if (mood == 'happy') c = const Color(0xFFA8C69F);
        else if (mood == 'okay') c = const Color(0xFFB5C7E6);
        else if (mood == 'sad') c = const Color(0xFFF7D486);
        else if (mood == 'awful') c = const Color(0xFFE5A5A5);
        newMap[_normalizeDate(date)] = c;
      }
      if (mounted) setState(() => _moodColors.addAll(newMap));
    } catch (e) {}
  }

  Future<void> _loadTasks(String userId) async {
    try {
      final data = await _automationsService.getAutomations(userId);
      final Map<DateTime, List<CalendarTask>> loadedEvents = {};
      for (var item in data) {
        final payload = item['payload'] ?? {};
        final id = item['id'].toString();
        final dateStr = payload['start_date'];
        final endDateStr = payload['end_date'];
        if (dateStr != null) {
          final startDate = DateTime.parse(dateStr);
          final endDate = endDateStr != null ? DateTime.parse(endDateStr) : startDate;
          final timeStr = "${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}";
          final task = CalendarTask(id: id, title: item['title'] ?? 'Untitled', time: timeStr, color: Colors.black, isCompleted: item['status'] == 'completed');
          for (var day = _normalizeDate(startDate); !day.isAfter(_normalizeDate(endDate)); day = day.add(const Duration(days: 1))) {
            if (loadedEvents[day] == null) loadedEvents[day] = [];
            if (!loadedEvents[day]!.any((t) => t.id == task.id)) loadedEvents[day]!.add(task);
          }
        }
      }
      if (mounted) {
        setState(() {
          _events = loadedEvents;
          if (_selectedDay != null) _selectedEvents = _getEventsForDay(_selectedDay!);
        });
      }
    } catch (e) {}
  }

  List<CalendarTask> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  Future<void> _handleTaskToggle(CalendarTask task) async {
    setState(() => task.isCompleted = !task.isCompleted);
    if (task.id != null) {
      try { await _automationsService.updateStatus(task.id!, task.isCompleted ? 'completed' : 'pending'); } catch (e) { if (mounted) setState(() => task.isCompleted = !task.isCompleted); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TableCalendar<CalendarTask>(
                firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay, calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day), 
                eventLoader: _getEventsForDay,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Colors.transparent), selectedDecoration: BoxDecoration(color: Colors.transparent)),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) => _buildMoodDay(day),
                  todayBuilder: (context, day, focusedDay) => _buildMoodDay(day, isToday: true),
                  selectedBuilder: (context, day, focusedDay) => _buildMoodDay(day, isSelected: true),
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) { 
                      return Positioned(bottom: 8, child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))); 
                    }
                    return null;
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; _selectedEvents = _getEventsForDay(selectedDay); });
                },
              ),
              const SizedBox(height: 32),
              Expanded(child: _buildUpcomingSection()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0, shape: const CircleBorder(), backgroundColor: const Color(0xFFA8C69F),
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const CreateTask()),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMoodDay(DateTime day, {bool isToday = false, bool isSelected = false}) {
    final color = _moodColors[_normalizeDate(day)] ?? Colors.transparent;
    return Container(
      margin: const EdgeInsets.all(4), alignment: Alignment.center,
      decoration: BoxDecoration(color: color == Colors.transparent && isToday ? Colors.grey.shade200 : color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.black, width: 1.5) : null),
      child: Text('${day.day}', style: TextStyle(color: Colors.black, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildUpcomingSection() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Upcoming", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFA8C69F)))
          else if (_selectedEvents.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No tasks for this day.", style: TextStyle(color: Colors.grey)))
          else ..._selectedEvents.map((task) => TaskCard(title: task.title, subtitle: task.time, dotColor: task.color, isCompleted: task.isCompleted, onToggle: (val) => _handleTaskToggle(task))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}