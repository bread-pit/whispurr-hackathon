import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class LogsService {
  final _client = SupabaseService.client;

  /// Fetch all logs for a specific user
  Future<List<Map<String, dynamic>>> getLogs(String userId) async {
    try {
      final response = await _client
          .from('logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Newest first
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching logs: $e');
    }
  }

  /// Create a new log entry
  Future<void> createLog({
    required String userId,
    required String mood,   // Maps to Title
    required String content, // Maps to Content
    Map<String, dynamic>? context,
  }) async {
    try {
      await _client.from('logs').insert({
        'user_id': userId,
        'mood': mood,
        'content': content,
        'context': context ?? {},
      });
    } catch (e) {
      throw Exception('Error creating log: $e');
    }
  }
}