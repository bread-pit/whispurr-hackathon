import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/views/mood-sleep/sleep_page.dart';
import 'package:whispurr_hackathon/views/mood-sleep/mood_page.dart';

class MoodSleepPage extends StatefulWidget {
  const MoodSleepPage({super.key});

  @override
  State<MoodSleepPage> createState() => _MoodSleepPageState();
}

class _MoodSleepPageState extends State<MoodSleepPage> {
  bool isMoodSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gradient_bg_3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Selector
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => isMoodSelected = true);
                        },
                        child: Text(
                          'Mood',
                          style: context.textTheme.displaySmall?.copyWith(
                            color: Colors.black.withOpacity(isMoodSelected ? 1.0 : 0.5),
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 2,
                        color: Colors.grey.withValues(alpha: 0.5),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => isMoodSelected = false);
                        },
                        child: Text(
                          'Sleep',
                          style: context.textTheme.displaySmall?.copyWith(
                            color: Colors.black.withOpacity(isMoodSelected ? 0.5 : 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Display the selected page content
                isMoodSelected ? const MoodPage() : const SleepPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
