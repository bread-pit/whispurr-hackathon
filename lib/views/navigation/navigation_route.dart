import 'package:flutter/material.dart';
import '../account/account_page.dart';
import '../calendar/calendar_page.dart';
import '../home/home_page.dart';
import '../mood-sleep/mood_sleep_page.dart';
import '../notes/notes_page.dart';
import 'fab.dart';
import 'main_navigation.dart';

class NavigateRoute extends StatefulWidget {
  const NavigateRoute({super.key});

  @override
  State<NavigateRoute> createState() => _NavigateRouteState();
}

class _NavigateRouteState extends State<NavigateRoute> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
    HomePage(onTabChange: _onTabTapped), // 3. Pass the function here
    const CalendarPage(),
    const NotesPage(),
    const AccountPage(),
    const MoodSleepPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        // Increase the top padding to push the button down
        padding: const EdgeInsets.only(top: 30),
        child: FabNav(
          onPressed: () => _onTabTapped(4),
        ),
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }
}