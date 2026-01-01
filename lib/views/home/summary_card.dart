import 'package:flutter/material.dart';
import '../../theme.dart';

class SummaryCard extends StatelessWidget {
  final int taskCount;
  final double sleepHours;
  final String? currentMood;

  const SummaryCard({
    super.key,
    required this.taskCount,
    required this.sleepHours,
    this.currentMood,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;
    String message;
    
    // Default/Fallback
    imagePath = 'assets/images/happy.png';
    message = "Whispurr smiles with\nyou today.";

    if (currentMood == 'happy') {
      imagePath = 'assets/images/happy.png';
      message = "Whispurr smiles with\nyou today.";
    } else if (currentMood == 'okay') {
      imagePath = 'assets/images/neutral.png';
      message = "Whispurr is chill\nwith you today.";
    } else if (currentMood == 'sad') {
      imagePath = 'assets/images/sad.png';
      message = "Whispurr is here\nfor you.";
    } else if (currentMood == 'awful') {
      imagePath = 'assets/images/angry.png';
      message = "Whispurr understands\nit's a tough day.";
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff9FBfa2).withOpacity(0.8), // Green tint background
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // RIGHT COLUMN (Sleep & Tasks)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // SLEEP CARD
              Container(
                height: 82,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffD6E6CE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.nights_stay, size: 16),
                      ],
                    ),
                    Text(
                      sleepHours.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("hrs of sleep", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // TASKS CARD
              Container(
                height: 82,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffD6E6CE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16),
                      ],
                    ),
                    Text(
                      taskCount.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("tasks", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}