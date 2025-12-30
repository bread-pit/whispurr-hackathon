import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:whispurr_hackathon/views/login_signup/login_page.dart';
import 'package:whispurr_hackathon/views/login_signup/signup_page.dart';
import 'package:whispurr_hackathon/views/mood-sleep/mood_sleep_page.dart';
import 'package:whispurr_hackathon/views/navigation/navigation_route.dart';
import 'package:whispurr_hackathon/views/notes/notes_page.dart';
import 'theme.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qneswperrepfiqwkudqf.supabase.co', 
    
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFuZXN3cGVycmVwZmlxd2t1ZHFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwNDU0MzcsImV4cCI6MjA4MjYyMTQzN30.wGIJaw4XCDuuaI1WdVzVXpSy3O0MArmRIr4jbmBreCE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whispurr',
      theme: createAppTheme(),
      home: SignupPage(),
    );
  }
}