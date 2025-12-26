import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  // Track the currently selected mood.
  // Options: 'happy', 'okay', 'sad', 'awful'
  String? selectedMood;

  // Define your mood data
  final List<Map<String, dynamic>> moods = [
    {'id': 'happy', 'label': 'Happy', 'image': 'assets/images/happy.png'},
    {'id': 'okay', 'label': 'Okay', 'image': 'assets/images/neutral.png'},
    {'id': 'sad', 'label': 'Sad', 'image': 'assets/images/sad.png'},
    {'id': 'awful', 'label': 'Awful', 'image': 'assets/images/angry.png'},
  ];

  // Helper to get color based on context.mood (from your theme)
  Color getMoodColor(String id, BuildContext context) {
    switch (id) {
      case 'happy': return context.mood.happy ?? Colors.transparent;
      case 'okay': return context.mood.okay ?? Colors.transparent;
      case 'sad': return context.mood.sad ?? Colors.transparent;
      case 'awful': return context.mood.awful ?? Colors.transparent;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          "What’s your mood today?",
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        // 2x2 Grid
        GridView.builder(
          shrinkWrap: true, // Important inside SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Makes them square
          ),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            final mood = moods[index];
            final isSelected = selectedMood == mood['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMood = mood['id'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  // Background changes if selected, otherwise white
                  color: isSelected ? getMoodColor(mood['id'], context) : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: getMoodColor(mood['id'], context).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(mood['image'], height: 150),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        Text(
          "Express yourself",
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: TextField(
            maxLines: 5,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: "Write your thoughts...",
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
