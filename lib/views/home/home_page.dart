import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:table_calendar/table_calendar.dart';
import 'package:whispurr_hackathon/core/services/automations_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'package:whispurr_hackathon/core/widgets/note_card.dart';
import 'package:whispurr_hackathon/views/home/summary_card.dart';
import '../../core/model/calendar_model.dart';
import '../../core/widgets/task_card.dart';
import '../../theme.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange;
  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); 

  final Map<DateTime, List<CalendarTask>> _allTasks = {};
  final _automationsService = AutomationsService();
  List<CalendarTask> _selectedEvents = [];
  Map<String, dynamic>? _recentNote; 
  final Map<DateTime, Color> _moodColors = {}; 

  int _todaysTaskCount = 0;
  double _todaysSleep = 0.0;
  String? _currentMood; 
  
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      _fetchData();
      
      _subscription = SupabaseService.client.channel('public:db_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            callback: (payload) {
              debugPrint("Database changed! Refreshing Home...");
              _fetchData();
            },
          )
          .subscribe();
    }
  }

  @override
  void dispose() {
    if (_subscription != null) SupabaseService.client.removeChannel(_subscription!);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _fetchData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refreshed!'), duration: Duration(milliseconds: 500)),
      );
    }
  }

  Future<void> _fetchData() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    await Future.wait([
      _fetchTasks(user.id),
      _fetchRecentNote(user.id),
      _fetchLogs(user.id),
    ]);
  }

  // --- FETCH MOODS & SLEEP ---
  Future<void> _fetchLogs(String userId) async {
    try {
      // Fetch ALL logs ordered by newest first
      final response = await SupabaseService.client
          .from('logs')
          .select('created_at, mood, content')
          .eq('user_id', userId)
          .order('created_at', ascending: false); 

      final Map<DateTime, Color> tempMoodMap = {};
      String? foundMoodToday;
      double? foundSleepToday;
      final today = _normalizeDate(DateTime.now());

      for (var log in response) {
        final date = DateTime.parse(log['created_at']);
        final moodKey = log['mood'] as String?;
        final content = log['content'] as String?;
        final normalizedDate = _normalizeDate(date);
        
        // 1. Process Sleep Logs
        if (moodKey == 'sleep_log') {
          if (normalizedDate == today && foundSleepToday == null) {
             foundSleepToday = double.tryParse(content ?? '0') ?? 0.0;
          }
          continue;
        }

        // 2. Process Mood Colors
        Color c = Colors.transparent;
        if (moodKey == 'happy') c = const Color(0xFFA8C69F);
        else if (moodKey == 'okay') c = const Color(0xFFB5C7E6);
        else if (moodKey == 'sad') c = const Color(0xFFF7D486);
        else if (moodKey == 'awful') c = const Color(0xFFE5A5A5);
        
        if (!tempMoodMap.containsKey(normalizedDate)) {
           tempMoodMap[normalizedDate] = c;
        }
        if (normalizedDate == today && foundMoodToday == null) {
           foundMoodToday = moodKey;
        }
      }
      
      if (mounted) {
        setState(() {
          _moodColors.clear();
          _moodColors.addAll(tempMoodMap);
          _currentMood = foundMoodToday;
          _todaysSleep = foundSleepToday ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    }
  }

  Future<void> _fetchRecentNote(String userId) async {
    try {
      final response = await SupabaseService.client.from('notes').select().eq('user_id', userId).order('created_at', ascending: false).limit(1).maybeSingle();
      if (mounted && response != null) setState(() => _recentNote = response);
    } catch (e) {}
  }

  Future<void> _fetchTasks(String userId) async {
    try {
      final data = await _automationsService.getAutomations(userId);
      if (!mounted) return;
      setState(() {
        _allTasks.clear();
        int todayTotal = 0;
        final todayKey = _normalizeDate(DateTime.now());

        for (var item in data) {
          final payload = item['payload'] ?? {};
          final title = item['title'] ?? 'Untitled';
          final status = item['status'] ?? 'pending';
          final id = item['id'].toString(); 
          final dateStr = payload['start_date'];
          final endDateStr = payload['end_date'];

          if (dateStr != null) {
            final startDate = DateTime.parse(dateStr);
            final endDate = endDateStr != null ? DateTime.parse(endDateStr) : startDate;
            final timeStr = "${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}";
            final task = CalendarTask(id: id, title: title, time: timeStr, color: const Color(0xFFA8C69F), isCompleted: status == 'completed');

            for (var day = _normalizeDate(startDate); !day.isAfter(_normalizeDate(endDate)); day = day.add(const Duration(days: 1))) {
              if (_allTasks[day] == null) _allTasks[day] = [];
              if (!_allTasks[day]!.any((t) => t.id == task.id)) _allTasks[day]!.add(task);
              if (day == todayKey) {
                todayTotal++;
              }
            }
          }
        }
        _todaysTaskCount = todayTotal;
        _loadTasksForSelectedDay();
      });
    } catch (e) {}
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
  void _loadTasksForSelectedDay() => setState(() => _selectedEvents = _allTasks[_normalizeDate(_selectedDay)] ?? []);
  
  Future<void> _handleTaskToggle(CalendarTask task) async {
    setState(() => task.isCompleted = !task.isCompleted);
    if (task.id != null) {
      try { await _automationsService.updateStatus(task.id!, task.isCompleted ? 'completed' : 'pending'); } catch (e) { if (mounted) setState(() => task.isCompleted = !task.isCompleted); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Friend'; 
    final bool isToday = isSameDay(_selectedDay, DateTime.now());
    final String listHeader = isToday ? "Today's Tasks" : "Tasks for ${DateFormat('MMM d').format(_selectedDay)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/gradient_bg_3.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Hello, $userName!", style: context.textTheme.displayLarge),
                    IconButton(onPressed: _onRefresh, icon: const Icon(Icons.refresh, color: AppColors.black)),
                  ]),
                  const SizedBox(height: 25),
                  TableCalendar(
                    firstDay: DateTime.utc(2025, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay, calendarFormat: _calendarFormat, headerVisible: false,
                    eventLoader: (day) => _allTasks[_normalizeDate(day)] ?? [],
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = _normalizeDate(selectedDay); _focusedDay = focusedDay; _loadTasksForSelectedDay(); }); },
                    calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Colors.transparent), selectedDecoration: BoxDecoration(color: Colors.transparent)),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) => _buildMoodDay(day),
                      todayBuilder: (context, day, focusedDay) => _buildMoodDay(day, isToday: true),
                      selectedBuilder: (context, day, focusedDay) => _buildMoodDay(day, isSelected: true),
                      markerBuilder: (context, day, events) => (events != null && events.isNotEmpty) ? Positioned(bottom: 8, child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // PASSING CORRECT STATE VARIABLES
                  SummaryCard(taskCount: _todaysTaskCount, sleepHours: _todaysSleep, currentMood: _currentMood),
                  const SizedBox(height: 32),
                  Text(listHeader, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_selectedEvents.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text("No tasks for ${DateFormat('MMM d').format(_selectedDay)}.", style: const TextStyle(color: Colors.grey)))
                  else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _selectedEvents.length, itemBuilder: (context, index) { final task = _selectedEvents[index]; return TaskCard(title: task.title, subtitle: task.time, dotColor: task.color, isCompleted: task.isCompleted, onToggle: (_) => _handleTaskToggle(task)); }),
                  const SizedBox(height: 25),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ const Text("Recent Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), TextButton(onPressed: () => widget.onTabChange(2), child: const Text("See all", style: TextStyle(color: AppColors.black))) ]),
                  if (_recentNote != null) NoteCard(title: _recentNote!['title'] ?? 'No Title', content: _recentNote!['content'] ?? '', date: _recentNote!['created_at'] != null ? DateFormat('MMM dd').format(DateTime.parse(_recentNote!['created_at'])) : 'Today') else const Padding(padding: EdgeInsets.only(top: 10), child: Text("No notes yet.", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ),
        ),
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
}