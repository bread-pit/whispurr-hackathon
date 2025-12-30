import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared border style for all cards
    final cardBorder = Border.all(
      color: AppColors.black.withValues(alpha: 0.5),
      width: 0.5,
    );

    return Row(
      children: [

        // Whispurr Mood (Left Big Box with Broken Lines)
        Expanded(
          flex: 2,
          child: Container(
            height: 225,
            decoration: BoxDecoration(
              color: context.mood.happy,
              borderRadius: BorderRadius.circular(35.0),
              border: cardBorder,
            ),
            padding: const EdgeInsets.all(16),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: [5, 5],
                radius: Radius.circular(16),
                color: Colors.white
              ),
              child: Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Image.asset(
                        "assets/images/happy.png",
                        fit: BoxFit.cover,
                        height: 130,
                        width: 130,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Whispurr smiles with you today.",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              )
            )
          ),
        ),

        const SizedBox(width: 25),

        // Sleep & Task Column (Right Side)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Sleep Data Container
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.mood.happy?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  border: cardBorder,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // icon
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          "assets/images/sleep.png",
                          height: 21,
                          width: 21,
                        ),
                      ),

                      // hrs of sleep
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "6.5",
                          style: context.textTheme.displayLarge?.copyWith(
                            fontSize: 36
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      // label
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "hrs of sleep",
                          style: TextStyle(
                            fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),

              const SizedBox(height: 25),

              // Task Count Container
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.mood.happy?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  border: cardBorder,
                ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // icon
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "assets/images/tasks.png",
                            height: 21,
                            width: 21,
                          ),
                        ),

                        // hrs of sleep
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "10",
                            style: context.textTheme.displayLarge?.copyWith(
                                fontSize: 36
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),

                        // label
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "tasks",
                            style: TextStyle(
                                fontSize: 10
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        )
      ],
    );
  }
}