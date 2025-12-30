import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  // Function to handle the date selection logic
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Title",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 24),
              border: InputBorder.none, // Matches the clean look in your image
            ),
          ),
          const SizedBox(height: 16),

          // Updated Date Pickers
          _buildDateField(
            "Start Date",
            DateFormat('MMMM d, yyyy').format(startDate),
                () => _selectDate(context, true),
          ),
          const SizedBox(height: 12),
          _buildDateField(
            "End Date",
            DateFormat('MMMM d, yyyy').format(endDate),
                () => _selectDate(context, false),
          ),

          const SizedBox(height: 24),

          // Bottom Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3)), // Divider like your image
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(date),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
              ],
            ),
          ),
        )
      ],
    );
  }
}