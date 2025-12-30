import 'package:flutter/foundation.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class LogsService {
  final _supabase = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getLogs(String userId) async {
    try {
      final response = await _supabase
          .from('logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      return [];
    }
  }

  Future<bool> createLog({
    required String userId,
    String? mood,
    String? content,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _supabase.from('logs').insert({
        'user_id': userId,
        'mood': mood,
        'content': content,
        'context': context,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating log: $e');
      return false;
    }
  }

  Future<bool> updateLog({
    required String logId,
    String? mood,
    String? content,
    Map<String, dynamic>? context,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (mood != null) updates['mood'] = mood;
      if (content != null) updates['content'] = content;
      if (context != null) updates['context'] = context;

      await _supabase.from('logs').update(updates).eq('id', logId);
      return true;
    } catch (e) {
      debugPrint('Error updating log: $e');
      return false;
    }
  }

  Future<bool> deleteLog(String logId) async {
    try {
      await _supabase.from('logs').delete().eq('id', logId);
      return true;
    } catch (e) {
      debugPrint('Error deleting log: $e');
      return false;
    }
  }
}
