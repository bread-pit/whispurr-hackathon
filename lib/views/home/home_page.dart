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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<CalendarTask>> _allTasks = {};
  final _automationsService = AutomationsService();
  List<CalendarTask> _selectedEvents = [];

  // Variable to store the user's name
  String _userName = "Friend";

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    _loadUserName(); // Fetch the name on init
    _fetchTasks();
  }

  // Fetch user name from Supabase metadata
  void _loadUserName() {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      final metaName = user.userMetadata?['full_name'];
      if (metaName != null && metaName.isNotEmpty) {
        if (mounted) {
          setState(() {
            _userName = metaName;
          });
        }
      }
    }
  }

  Future<void> _fetchTasks() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _automationsService.getAutomations(user.id);

      if (!mounted) return;

      setState(() {
        _allTasks.clear();

        for (var item in data) {
          final payload = item['payload'] ?? {};
          final title = item['title'] ?? 'Untitled';
          final status = item['status'] ?? 'pending';

          final dateStr = payload['start_date'];
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            final normalizedDate = _normalizeDate(date);
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
          }
        }
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
    final key = _normalizeDate(_selectedDay!);
    setState(() {
      _selectedEvents = _allTasks[key] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  "Hello, $_userName!", // Dynamic name displayed here
                  style: context.textTheme.displayLarge,
                ),
                const SizedBox(height: 25),
                TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  headerVisible: false,
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
                    markerDecoration: const BoxDecoration(
                      color: AppColors.black,
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
                const SummaryCard(),
                const SizedBox(height: 32),
                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                const NoteCard(
                  title: "Hello",
                  content: "Hello",
                  date: "Date",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}