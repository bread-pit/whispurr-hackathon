import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/widgets/note_card.dart';
import 'package:whispurr_hackathon/views/notes/note_take.dart';
import 'package:whispurr_hackathon/core/services/notes_service.dart'; // UPDATED IMPORT
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _notesService = NotesService(); // UPDATED SERVICE

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load Notes from Supabase
  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final notes = await _notesService.getNotes(user.id);

      // Sort logic
      notes.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return _sortDescending
            ? bDate.compareTo(aDate)
            : aDate.compareTo(bDate);
      });

      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notes: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSort() {
    setState(() {
      _sortDescending = !_sortDescending;
    });
    _loadNotes();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
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
          child: RefreshIndicator(
            onRefresh: _loadNotes,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
              physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              child: Column(
                children: [
                  Text(
                    'All Notes',
                    style: context.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: _toggleSort,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_rounded, size: 18, color: AppColors.black),
                            const SizedBox(width: 4),
                            Text('Date', style: context.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        height: 12, width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.black.withOpacity(0.3),
                      ),
                      Icon(
                        _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 18, color: AppColors.black,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Notes List
                  if (_isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ))
                  else if (_notes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No notes yet. Start writing!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._notes.map(
                      (note) => NoteCard(
                        title: note['title'] ?? 'Untitled',
                        content: note['content'] ?? '',
                        date: _formatDate(note['created_at']),
                      ),
                    ),
                  
                  // Extra space at bottom so FAB doesn't cover last item
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteTake()),
          );
          _loadNotes(); // Reload list after returning from NoteTake
        },
        backgroundColor: context.mood.happy,
        shape: const CircleBorder(side: BorderSide(color: Colors.black12, width: 0.5)),
        elevation: 2,
        child: const Icon(Icons.edit, color: Colors.white, size: 24),
      ),
    );
  }
}