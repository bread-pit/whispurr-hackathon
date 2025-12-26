import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';

class TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const TimePickerButton({
    super.key,
    required this.label,
    required this.time,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: backgroundColor?.withValues(alpha: 0.5),
            border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                time.format(context),
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(label, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}