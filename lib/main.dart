import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/views/login_signup/login_page.dart';
import 'package:whispurr_hackathon/views/login_signup/signup_page.dart';
import 'package:whispurr_hackathon/views/notes/notes_page.dart';
import 'theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whispurr',
      theme: createAppTheme(),
      home: NotesPage(),
    );
  }
}

