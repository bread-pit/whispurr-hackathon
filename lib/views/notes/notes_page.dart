import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Notes',
          style: context.textTheme.displaySmall?.copyWith(fontSize: 20),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gradient_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      // menu icon

                      Text(
                        'Date',
                        style: context.textTheme.bodySmall,
                      ),

                      // horizontal bar divider

                      // icon up arrow
                    ],
                  )

                  // Your Content here

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
