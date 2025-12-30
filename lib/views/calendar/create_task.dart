import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whispurr_hackathon/core/services/automations_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _automationsService = AutomationsService();
  bool _isSaving = false;
  
  // These variables were missing in your previous code
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String selectedRepeat = "Don't repeat";

  final List<String> repeatOptions = [
    "Don't repeat",
    "Every day",
    "Every week",
    "Every month",
    "Every year",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Fix end date logic
    final cleanStart = DateTime(startDate.year, startDate.month, startDate.day);
    final cleanEnd = DateTime(endDate.year, endDate.month, endDate.day);

    if (cleanEnd.isBefore(cleanStart)) {
       endDate = startDate;
    }

    setState(() => _isSaving = true);

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await _automationsService.createAutomation(
          userId: user.id,
          title: _titleController.text,
          status: 'pending',
          payload: {
            'start_date': cleanStart.toIso8601String(),
            'end_date': cleanEnd.toIso8601String(),
            'repeat': selectedRepeat,
            'notes': _notesController.text,
          },
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to create tasks')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save task.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
          if (startDate.isAfter(endDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _showRepeatPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: repeatOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedRepeat,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setModalState(() => selectedRepeat = value!);
                      setState(() => selectedRepeat = value!);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormSection(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 24, color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildFormSection(
              child: InkWell(
                onTap: _showRepeatPicker,
                child: _buildListTile(
                    Icons.repeat,
                    selectedRepeat,
                    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey)
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildFormSection(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.notes, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Notes",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.white24),
                  Expanded(
                    child: TextButton(
                      onPressed: _isSaving ? null : _saveTask,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildListTile(IconData icon, String label, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          if (trailing != null) trailing,
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