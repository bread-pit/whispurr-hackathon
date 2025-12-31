import 'package:flutter/foundation.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class NotesService {
  final _supabase = SupabaseService.client;

  // Fetch notes
  Future<List<Map<String, dynamic>>> getNotes(String userId) async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  // Create note
  Future<bool> createNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      await _supabase.from('notes').insert({
        'user_id': userId,
        'title': title,
        'content': content,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating note: $e');
      throw e; 
    }
  }
}