import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/views/notes/note_card.dart';
import 'package:whispurr_hackathon/views/notes/note_take.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gradient_bg_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Column(
              children: [
                Text(
                  'All Notes',
                  style: context.textTheme.displayLarge?.copyWith(

                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),

                // Top controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Menu + Date combined button
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_rounded, size: 18, color: AppColors.black),
                          const SizedBox(width: 4),
                          Text('Date', style: context.textTheme.bodySmall),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      height: 12,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.black.withOpacity(0.3),
                    ),

                    // Sort arrow
                    const Icon(Icons.arrow_upward, size: 18, color: AppColors.black),
                  ],
                ),

                const SizedBox(height: 30),

                // Note Cards List
                NoteCard(
                  title: "Whispurr",
                  content: "Sample content description goes here.",
                  date: "Dec 26, 2025",
                ),

                NoteCard(
                  title: "Design Meeting",
                  content: "Discuss the new glassmorphism UI updates and the fixed background issues.",
                  date: "Dec 26, 2025",
                ),

                NoteCard(
                  title: "Shopping List",
                  content: "Buy groceries, coffee, and new pens for sketching.",
                  date: "Dec 26, 2025",
                ),

              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteTake()),
        ),
        backgroundColor: context.mood.happy,
        shape: CircleBorder(
          side: BorderSide(
            color: AppColors.black.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        elevation: 2,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}