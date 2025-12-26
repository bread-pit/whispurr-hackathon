import 'package:flutter/material.dart';
import '../../theme.dart';

class NoteTake extends StatelessWidget {
  const NoteTake({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Optional: Add a checkmark or 'Save' button
          TextButton(onPressed: () {},
              child: Text(
                'Save',
                style: TextStyle(
                  color: context.mood.happy
                ),
              )
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Title Input
            TextField(
              style: context.textTheme.displaySmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: context.textTheme.displaySmall?.copyWith(
                  color: AppColors.black.withOpacity(0.3),
                  fontSize: 24,
                ),
                border: InputBorder.none, // Removes default underline
              ),
              maxLines: 1,
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "August 12, 2003",
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black.withOpacity(0.6),
                ),
              ),
            ),


            // 2. Divider
            Divider(
              color: AppColors.black.withOpacity(0.1),
              thickness: 1,
              height: 32,
            ),

            // 3. Note Content Input
            TextField(
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Aa...',
                hintStyle: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.black.withOpacity(0.3),
                ),
                border: InputBorder.none,
              ),
              maxLines: null, // Allows the field to grow as you type
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }
}