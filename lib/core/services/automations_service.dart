import 'package:flutter/foundation.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class AutomationsService {
  final _supabase = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getAutomations(String userId) async {
    try {
      final response = await _supabase
          .from('automations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching automations: $e');
      return [];
    }
  }

  Future<bool> createAutomation({
    required String userId,
    required String title,
    String status = 'pending',
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _supabase.from('automations').insert({
        'user_id': userId,
        'title': title,
        'status': status,
        'payload': payload,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating automation: $e');
      return false;
    }
  }

  // Existing method (keep this if you use it elsewhere)
  Future<bool> updateAutomationStatus({
    required String automationId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('automations')
          .update({'status': status})
          .eq('id', automationId);
      return true;
    } catch (e) {
      debugPrint('Error updating automation: $e');
      return false;
    }
  }

  // ADD THIS METHOD to fix your error
  // Note: The 'id' in your CalendarTask model is likely an int, 
  // so this accepts 'int id'. If your DB uses UUID strings, change int to String.
  Future<void> updateStatus(int id, String status) async {
    try {
      await _supabase
          .from('automations')
          .update({'status': status})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow; // Optional: rethrow so the UI knows it failed
    }
  }
}