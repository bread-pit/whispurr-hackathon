import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';

class SummaryCard extends StatelessWidget {
  final int taskCount;
  final double sleepHours;
  final bool isHappy;

  const SummaryCard({
    super.key,
    required this.taskCount,
    required this.sleepHours,
    required this.isHappy,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorder = Border.all(
      color: AppColors.black.withValues(alpha: 0.5),
      width: 0.5,
    );

    final moodImage = isHappy ? "assets/images/happy.png" : "assets/images/happy.png"; // Replace with neutral if available
    final moodText = isHappy ? "Whispurr smiles with you today." : "Whispurr is cheering for you!";
    final mainColor = isHappy ? context.mood.happy : (context.mood.happy?.withOpacity(0.7)); 

    return Row(
      children: [
        // Mood Card
        Expanded(
          flex: 2,
          child: Container(
            height: 225,
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(35.0),
              border: cardBorder,
            ),
            padding: const EdgeInsets.all(16),
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                dashPattern: [5, 5],
                radius: Radius.circular(16),
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Image.asset(
                        moodImage,
                        fit: BoxFit.cover,
                        height: 130,
                        width: 130,
                        errorBuilder: (context, error, stackTrace) {
                           return const Icon(Icons.sentiment_satisfied, size: 80, color: Colors.white);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        moodText,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        
        // Stats Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Sleep Data
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: mainColor?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  border: cardBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          "assets/images/sleep.png",
                          height: 21,
                          width: 21,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sleepHours.toStringAsFixed(1),
                            style: context.textTheme.displayLarge?.copyWith(
                              fontSize: 36,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "hrs of sleep",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Task Count Data
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: mainColor?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  border: cardBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          "assets/images/tasks.png",
                          height: 21,
                          width: 21,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$taskCount",
                            style: context.textTheme.displayLarge?.copyWith(
                              fontSize: 36,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "tasks",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}