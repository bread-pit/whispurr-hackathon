import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import '../../utils/time_picker_utils.dart';
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

  // State for the toggle
  ViewType selectedView = ViewType.weekly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Added to prevent overflow on smaller screens
      child: Column(
        children: [
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "How long did you sleep?",
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
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

          const SizedBox(height: 32),

          // --- Toggle Header ---
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    _buildToggleButton("Weekly", ViewType.weekly),
                    _buildToggleButton("Monthly", ViewType.monthly),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Sleep Data Card ---
          Container(
            width: double.infinity,
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sleep Data",
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),

                Center(
                  child: Text(
                    selectedView == ViewType.weekly
                        ? "Weekly Chart Goes Here"
                        : "Monthly Chart Goes Here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Spacer(),
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
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: context.textTheme.displaySmall?.copyWith(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),


        ),
      ),
    );
  }
}