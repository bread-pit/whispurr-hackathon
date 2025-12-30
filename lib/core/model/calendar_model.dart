import 'package:flutter/material.dart';

class CalendarTask {
  final String? id; 
  final String title;
  final String time;
  final Color color;
  bool isCompleted;

  CalendarTask({
    this.id, // 
    required this.title,
    required this.time,
    required this.color,
    this.isCompleted = false,
  });
}