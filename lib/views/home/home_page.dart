import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/core/widgets/note_card.dart';
import 'package:whispurr_hackathon/views/home/summary_card.dart';
import 'package:whispurr_hackathon/views/notes/notes_page.dart';
import '../../core/model/calendar_model.dart'; // Ensure this matches your project structure
import '../../core/widgets/task_card.dart';
import '../../theme.dart';


class HomePage extends StatefulWidget {
  final Function(int) onTabChange;

  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data for the current day's tasks
  // In a real scenario, you'd filter your global events list by DateTime.now()
  List<CalendarTask> _selectedEvents = [
    CalendarTask(
      title: "Morning Meditation",
      time: "8:00 AM",
      color: const Color(0xFFA8C69F),
      isCompleted: false,
    ),
    CalendarTask(
      title: "Check Whispurr Mood",
      time: "9:30 AM",
      color: const Color(0xFFA8C69F),
      isCompleted: true,
    ),
    CalendarTask(
      title: "Morning Meditation",
      time: "8:00 AM",
      color: const Color(0xFFA8C69F),
      isCompleted: false,
    ),
    CalendarTask(
      title: "Check Whispurr Mood",
      time: "9:30 AM",
      color: const Color(0xFFA8C69F),
      isCompleted: true,
    ),
  ];

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
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Calendar placeholder (Weekly View)
                SizedBox(height: 20),

                // 2. Summary Board
                SummaryCard(),

                SizedBox(height: 32),

                // 3. Today's Tasks Header
                Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 16),

                // 4. Task List Implementation
                if (_selectedEvents.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No tasks for today!", style: TextStyle(color: Colors.grey)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final task = _selectedEvents[index];
                      return TaskCard(
                        title: task.title,
                        subtitle: task.time,
                        dotColor: task.color,
                        isCompleted: task.isCompleted,
                        onToggle: (val) {
                          setState(() {
                            task.isCompleted = !task.isCompleted;
                          });
                        },
                        onTap: () {
                          // Handle navigation to task details
                        },
                      );
                    },
                  ),

                SizedBox(height: 25),

                // 5. Recent Notes Section...
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Notes",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    TextButton(
                        onPressed: () {
                          widget.onTabChange(2);
                        },
                        child: Text(
                            "See all",
                          style: TextStyle(
                            color: AppColors.black
                          ),
                        )
                    ),
                  ],
                ),


                NoteCard(
                  title: "Hello",
                  content: "Hello",
                  date: "Date"
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}