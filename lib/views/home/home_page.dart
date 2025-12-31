import 'dart:async'; // Required for Auto-Refresh
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); 

  // Data State
  final Map<DateTime, List<CalendarTask>> _allTasks = {};
  final _automationsService = AutomationsService();
  List<CalendarTask> _selectedEvents = [];
  
  // Note State
  Map<String, dynamic>? _recentNote; 

  // Summary State
  int _todaysTaskCount = 0;
  double _todaysSleep = 0.0;
  bool _isHappyMood = true;
  
  // Timer for Auto-Refresh
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      _fetchTasks();
      _fetchRecentNote();
      
      // AUTO-REFRESH: Runs every 5 seconds to catch new notes and tasks
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          _fetchTasks();
          _fetchRecentNote(); 
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _fetchTasks();
    await _fetchRecentNote();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refreshed!'), duration: Duration(milliseconds: 500)),
      );
    }
  }

  // --- FETCH RECENT NOTE ---
  Future<void> _fetchRecentNote() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await SupabaseService.client
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1) 
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _recentNote = response;
      });
    } catch (e) {
       debugPrint("Error fetching recent note: $e");
    }
  }

  // --- FETCH TASKS ---
  Future<void> _fetchTasks() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _automationsService.getAutomations(user.id);
      
      if (!mounted) return;

      setState(() {
        _allTasks.clear();
        int todayTotal = 0;
        int todayCompleted = 0;
        double calculatedSleep = 0.0;
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
              
              if (_allTasks[day] == null) _allTasks[day] = [];
              if (!_allTasks[day]!.any((t) => t.id == task.id)) {
                _allTasks[day]!.add(task);
              }

              if (day == todayKey) {
                todayTotal++;
                if (task.isCompleted) todayCompleted++;
                if (title.toLowerCase().contains("sleep")) calculatedSleep = 8.0; 
              }
            }
          }
        }

        _todaysTaskCount = todayTotal;
        _todaysSleep = calculatedSleep;
        _isHappyMood = todayTotal == 0 || (todayCompleted / todayTotal) >= 0.5;

        _loadTasksForSelectedDay();
      });
    } catch (e) {
      debugPrint("Error fetching home tasks: $e");
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _loadTasksForSelectedDay() {
    final key = _normalizeDate(_selectedDay);
    setState(() {
      _selectedEvents = _allTasks[key] ?? [];
    });
  }

  Future<void> _handleTaskToggle(CalendarTask task) async {
    setState(() => task.isCompleted = !task.isCompleted);
    if (task.id != null) {
      try {
        final newStatus = task.isCompleted ? 'completed' : 'pending';
        await _automationsService.updateStatus(task.id!, newStatus);
      } catch (e) {
        if (mounted) setState(() => task.isCompleted = !task.isCompleted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Friend'; 
    
    final bool isToday = isSameDay(_selectedDay, DateTime.now());
    final String listHeader = isToday 
        ? "Today's Tasks" 
        : "Tasks for ${DateFormat('MMM d').format(_selectedDay)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gradient_bg_3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), 
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Hello, $userName!", style: context.textTheme.displayLarge),
                      IconButton(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh, color: AppColors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  TableCalendar(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    headerVisible: false,
                    eventLoader: (day) => _allTasks[_normalizeDate(day)] ?? [],
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = _normalizeDate(selectedDay);
                        _focusedDay = focusedDay;
                        _loadTasksForSelectedDay(); 
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFFA8C69F), 
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SummaryCard(
                    taskCount: _todaysTaskCount,
                    sleepHours: _todaysSleep, 
                    isHappy: _isHappyMood,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    listHeader,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No tasks for ${DateFormat('MMM d').format(_selectedDay)}.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final task = _selectedEvents[index];
                        return TaskCard(
                          title: task.title,
                          subtitle: task.time,
                          dotColor: task.color,
                          isCompleted: task.isCompleted,
                          onToggle: (_) => _handleTaskToggle(task),
                          onTap: () {},
                        );
                      },
                    ),
                    
                  const SizedBox(height: 25),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => widget.onTabChange(2),
                        child: const Text("See all", style: TextStyle(color: AppColors.black)),
                      ),
                    ],
                  ),
                  
                  // DISPLAY RECENT NOTE HERE
                  if (_recentNote != null)
                    NoteCard(
                      title: _recentNote!['title'] ?? 'No Title',
                      content: _recentNote!['content'] ?? '',
                      date: _recentNote!['created_at'] != null 
                          ? DateFormat('MMM dd').format(DateTime.parse(_recentNote!['created_at']))
                          : 'Today',
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text("No notes yet.", style: TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}