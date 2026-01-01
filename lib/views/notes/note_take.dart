import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/core/services/notes_service.dart'; // UPDATED IMPORT
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';

class NoteTake extends StatefulWidget {
  const NoteTake({super.key});

  @override
  State<NoteTake> createState() => _NoteTakeState();
}

class _NoteTakeState extends State<NoteTake> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesService = NotesService(); 
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write some content first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = SupabaseService.client.auth.currentUser;
      
      if (user != null) {
        await _notesService.createNote(
          userId: user.id,
          title: _titleController.text.isNotEmpty ? _titleController.text : 'Untitled Note',
          content: _contentController.text,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note Saved!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Not logged in.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveNote,
            child: _isSaving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: context.mood.happy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title Input
            TextField(
              controller: _titleController,
              style: context.textTheme.displaySmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: context.textTheme.displaySmall?.copyWith(
                  color: AppColors.black.withOpacity(0.3),
                  fontSize: 24,
                ),
                border: InputBorder.none,
              ),
              maxLines: 1,
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black.withOpacity(0.6),
                ),
              ),
            ),

            Divider(
              color: AppColors.black.withOpacity(0.1),
              thickness: 1,
              height: 32,
            ),

            // Content Input
            TextField(
              controller: _contentController,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Start writing here...',
                hintStyle: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.black.withOpacity(0.3),
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            
            const SizedBox(height: 300), 
          ],
        ),
      ),
    );
  }
}