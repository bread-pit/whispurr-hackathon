import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.displaySmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            date,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),


          Text(
            content,
            style: context.textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }
}