import 'package:flutter/foundation.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class ProfileService {
  final _supabase = SupabaseService.client;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> createProfile({
    required String userId,
    required String email,
    int energyBaseline = 50,
    double sleepGoalHours = 7.5,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'energy_baseline': energyBaseline,
        'sleep_goal_hours': sleepGoalHours,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    int? energyBaseline,
    double? sleepGoalHours,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (energyBaseline != null) updates['energy_baseline'] = energyBaseline;
      if (sleepGoalHours != null) updates['sleep_goal_hours'] = sleepGoalHours;

      await _supabase.from('profiles').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}
