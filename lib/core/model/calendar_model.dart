import 'package:flutter/material.dart';

class CalendarTask {
  final String title;
  final String time;
  final Color color;
  bool isCompleted;

  CalendarTask({
    required this.title,
    required this.time,
    required this.color,
    this.isCompleted = false
  });
}