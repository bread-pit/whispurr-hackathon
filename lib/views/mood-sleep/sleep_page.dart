import 'package:fl_chart/fl_chart.dart'; // Ensure you add fl_chart: ^0.63.0 to pubspec.yaml
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/services/logs_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import '../../core/utils/time_picker_utils.dart';
import 'time_picker_button.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

enum ViewType { weekly, monthly }

class _SleepPageState extends State<SleepPage> {
  TimeOfDay bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay wakeup = const TimeOfDay(hour: 7, minute: 0);
  ViewType selectedView = ViewType.weekly;
  final _logsService = LogsService();
  bool _isSaving = false;
  
  // Chart Data
  List<FlSpot> _weeklySpots = [];
  double _maxHours = 12;

  @override
  void initState() {
    super.initState();
    _loadSleepHistory();
  }

  // Fetch history for the chart
  Future<void> _loadSleepHistory() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await SupabaseService.client
            .from('logs')
            .select('created_at, content')
            .eq('user_id', user.id)
            .eq('mood', 'sleep_log')
            .order('created_at', ascending: true)
            .limit(7);

        List<FlSpot> spots = [];
        double maxH = 8;
        
        for (int i = 0; i < data.length; i++) {
          final hours = double.tryParse(data[i]['content'].toString()) ?? 0.0;
          spots.add(FlSpot(i.toDouble(), hours));
          if (hours > maxH) maxH = hours;
        }
        
        if (mounted) setState(() { _weeklySpots = spots; _maxHours = maxH + 2; });
      } catch (e) { debugPrint("Chart Error: $e"); }
    }
  }

  Future<void> _saveSleep() async {
    setState(() => _isSaving = true);
    
    // Calculate Duration
    final now = DateTime.now();
    DateTime bedDateTime = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
    DateTime wakeDateTime = DateTime(now.year, now.month, now.day, wakeup.hour, wakeup.minute);
    
    // If wake time is before bed time, assume wake is next day
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    final double hoursSlept = wakeDateTime.difference(bedDateTime).inMinutes / 60.0;

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await _logsService.createLog(
          userId: user.id,
          mood: 'sleep_log', 
          content: hoursSlept.toStringAsFixed(1), 
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sleep saved: ${hoursSlept.toStringAsFixed(1)} hrs')));
          _loadSleepHistory(); 
        }
      }
    } catch (e) { debugPrint("Error: $e"); }
    finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.topLeft,
            child: Text("How long did you sleep?", style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TimePickerButton(
                label: "Bedtime",
                time: bedtime,
                backgroundColor: context.mood.sad,
                onTap: () async {
                  final selected = await pickTime(context, bedtime);
                  if (selected != null) setState(() => bedtime = selected);
                },
              ),
              const SizedBox(width: 16),
              TimePickerButton(
                label: "Wake Up",
                time: wakeup,
                backgroundColor: context.mood.okay,
                onTap: () async {
                  final selected = await pickTime(context, wakeup);
                  if (selected != null) setState(() => wakeup = selected);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSleep,
              icon: const Icon(Icons.save, color: Colors.white),
              label: _isSaving ? const Text("Saving...") : const Text("Log Sleep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff628141),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Toggle
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
              child: IntrinsicWidth(
                child: Row(children: [_buildToggleButton("Weekly", ViewType.weekly), _buildToggleButton("Monthly", ViewType.monthly)]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chart Card
          Container(
            width: double.infinity, height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(45), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sleep Data", style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Expanded(
                  child: _weeklySpots.isEmpty 
                    ? const Center(child: Text("No sleep data yet", style: TextStyle(color: Colors.grey))) 
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          minY: 0,
                          maxY: _maxHours,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _weeklySpots,
                              isCurved: true,
                              color: const Color(0xff628141),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: true, color: const Color(0xff628141).withOpacity(0.2)),
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, ViewType type) {
    bool isSelected = selectedView == type;
    return GestureDetector(
      onTap: () => setState(() => selectedView = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.grey.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: context.textTheme.displaySmall?.copyWith(fontSize: 16, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey)),
      ),
    );
  }
}