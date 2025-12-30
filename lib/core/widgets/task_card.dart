import 'package:flutter/material.dart';

// TODO:
// 1. allow card selection -> create task
// 2. mood color

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color dotColor;
  final bool isCompleted;
  final ValueChanged<bool?> onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    required this.isCompleted,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Radio Toggle implementation
            SizedBox(
              height: 24,
              width: 24,
              child: Radio<bool>(
                value: true,
                groupValue: isCompleted,
                activeColor: dotColor,
                toggleable: true,
                onChanged: onToggle,
              ),
            ),
            const SizedBox(width: 16),

            // Task details with Strikethrough logic
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}