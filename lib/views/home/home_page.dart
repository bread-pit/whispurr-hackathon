import 'package:flutter/material.dart';
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
  // ─────────────────────────────────────────────
  // State Variables
  // ─────────────────────────────────────────────
  
  // Calendar
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Data
  final Map<DateTime, List<CalendarTask>> _allTasks = {};
  final _automationsService = AutomationsService();
  List<CalendarTask> _selectedEvents = [];
  
  // Notes
  Map<String, dynamic>? _recentNote; 

  // Summary Card Stats
  int _todaysTaskCount = 0;
  double _todaysSleep = 0.0;
  bool _isHappyMood = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    
    // Only fetch data if user is logged in
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      _fetchTasks();
      _fetchRecentNote();
    }
  }

  // ─────────────────────────────────────────────
  // Backend Logic
  // ─────────────────────────────────────────────

  // 1. Fetch Calendar Tasks & Calculate Summary
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

          final dateStr = payload['start_date'];
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            final normalizedDate = _normalizeDate(date);
            // Format time (e.g., 08:30)
            final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

            final task = CalendarTask(
              title: title,
              time: timeStr,
              color: const Color(0xFFA8C69F),
              isCompleted: status == 'completed',
            );

            if (_allTasks[normalizedDate] == null) {
              _allTasks[normalizedDate] = [];
            }
            _allTasks[normalizedDate]!.add(task);

            // Calculate "Today" stats
            if (normalizedDate == todayKey) {
              todayTotal++;
              if (task.isCompleted) todayCompleted++;
              
              // Logic: If task title contains "sleep", use a dummy value (or real duration if you have it)
              if (title.toLowerCase().contains("sleep")) {
                  calculatedSleep = 8.0; 
              }
            }
          }
        }

        // Update Summary State
        _todaysTaskCount = todayTotal;
        _todaysSleep = calculatedSleep;
        _isHappyMood = todayTotal == 0 || (todayCompleted / todayTotal) >= 0.5;

        // Refresh list
        _loadTasksForSelectedDay();
      });
    } catch (e) {
      debugPrint("Error fetching home tasks: $e");
    }
  }

  // 2. Fetch Most Recent Note from Supabase
  Future<void> _fetchRecentNote() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await SupabaseService.client
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false) // Newest first
          .limit(1)
          .maybeSingle(); 

      if (!mounted) return;

      if (response != null) {
        setState(() {
          _recentNote = response;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }
  }

  // ─────────────────────────────────────────────
  // Utilities
  // ─────────────────────────────────────────────
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _loadTasksForSelectedDay() {
    final key = _normalizeDate(_selectedDay!);
    setState(() {
      _selectedEvents = _allTasks[key] ?? [];
    });
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    final userName = user?.userMetadata?['first_name'] ?? 'Friend'; 

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Hello, $userName!",
                  style: context.textTheme.displayLarge,
                ),
                const SizedBox(height: 25),
                
                // CALENDAR
                TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  headerVisible: false,
                  
                  // Show dots for events
                  eventLoader: (day) {
                    return _allTasks[_normalizeDate(day)] ?? [];
                  },
                  
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    _selectedDay = _normalizeDate(selectedDay);
                    _focusedDay = focusedDay;
                    _loadTasksForSelectedDay();
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
                    // Fixed Marker Decoration
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF000000), 
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // SUMMARY CARD (Functional)
                SummaryCard(
                  taskCount: _todaysTaskCount,
                  sleepHours: _todaysSleep, 
                  isHappy: _isHappyMood,
                ),
                
                const SizedBox(height: 32),
                
                // TASKS HEADER
                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // TASKS LIST
                if (_selectedEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No tasks for today!",
                      style: TextStyle(color: Colors.grey),
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
                        onToggle: (_) {
                          setState(() {
                            task.isCompleted = !task.isCompleted;
                          });
                        },
                        onTap: () {},
                      );
                    },
                  ),
                  
                const SizedBox(height: 25),
                
                // RECENT NOTES HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Notes",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onTabChange(2);
                      },
                      child: const Text(
                        "See all",
                        style: TextStyle(color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                
                // RECENT NOTE CARD (Functional)
                if (_recentNote != null)
                  NoteCard(
                    title: _recentNote!['title'] ?? 'No Title',
                    content: _recentNote!['content'] ?? '',
                    // Parse Supabase Timestamp to Date String
                    date: _recentNote!['created_at'] != null 
                        ? DateTime.parse(_recentNote!['created_at']).toString().split(' ')[0] 
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
    );
  }
}