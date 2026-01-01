import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/services/logs_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'mood_page.dart';
import 'sleep_page.dart';

class MoodSleepPage extends StatefulWidget {
  const MoodSleepPage({super.key});

  @override
  State<MoodSleepPage> createState() => _MoodSleepPageState();
}

class _MoodSleepPageState extends State<MoodSleepPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        title: Text('Mood & Sleep', style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xff628141),
          labelColor: const Color(0xff628141),
          unselectedLabelColor: Colors.black.withOpacity(0.5),
          labelStyle: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Mood'),
            Tab(text: 'Sleep'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TabBarView(
            controller: _tabController,
            children: const [
              MoodPage(),
              SleepPage(),
            ],
          ),
        ),
      ),
    );
  }
}

