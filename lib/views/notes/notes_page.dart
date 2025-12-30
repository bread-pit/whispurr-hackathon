import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/widgets/note_card.dart';
import 'package:whispurr_hackathon/views/notes/note_take.dart';
import 'package:whispurr_hackathon/core/services/logs_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _logsService = LogsService();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final logs = await _logsService.getLogs(user.id);
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading logs: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }
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
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No notes yet. Start writing!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ..._logs.map((log) => NoteCard(
                    title: log['mood'] ?? 'Note',
                    content: log['content'] ?? '',
                    date: _formatDate(log['created_at']),
                  )).toList(),

              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteTake()),
          );
          _loadLogs(); // Reload logs after returning from note creation
        },
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