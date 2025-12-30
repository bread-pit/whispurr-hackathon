import 'package:flutter/material.dart';


Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initialTime) async {
  return await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        ),
        child: child!,
      );
    },
  );
}