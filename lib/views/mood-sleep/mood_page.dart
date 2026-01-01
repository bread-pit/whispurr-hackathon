import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/core/services/logs_service.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? selectedMood;
  final _thoughtController = TextEditingController();
  final _logsService = LogsService();
  bool _isSavingNote = false;

  final List<Map<String, dynamic>> moods = [
    {'id': 'happy', 'label': 'Happy', 'image': 'assets/images/happy.png'},
    {'id': 'okay', 'label': 'Okay', 'image': 'assets/images/neutral.png'},
    {'id': 'sad', 'label': 'Sad', 'image': 'assets/images/sad.png'},
    {'id': 'awful', 'label': 'Awful', 'image': 'assets/images/angry.png'},
  ];

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  Color getMoodColor(String id, BuildContext context) {
    switch (id) {
      case 'happy': return const Color(0xFFA8C69F);
      case 'okay': return const Color(0xFFF7D486);
      case 'sad': return const Color(0xFFB5C7E6); 
      case 'awful': return const Color(0xFFE5A5A5);
      default: return Colors.white;
    }
  }

  Future<void> _onMoodTap(String moodId) async {
    setState(() => selectedMood = moodId);
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await _logsService.createLog(userId: user.id, mood: moodId, content: '');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood saved!'), duration: Duration(milliseconds: 500), backgroundColor: Colors.green));
      }
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _saveNote() async {
    if (_thoughtController.text.isEmpty) return;
    setState(() => _isSavingNote = true);
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await _logsService.createLog(userId: user.id, mood: selectedMood ?? 'neutral', content: _thoughtController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved!')));
          _thoughtController.clear();
        }
      }
    } catch (e) { debugPrint("Error: $e"); } 
    finally { if (mounted) setState(() => _isSavingNote = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text("What’s your mood today?", style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.0),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood['id'];
              return GestureDetector(
                onTap: () => _onMoodTap(mood['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? getMoodColor(mood['id'], context) : Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                    boxShadow: isSelected ? [BoxShadow(color: getMoodColor(mood['id'], context).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(mood['image'], height: 150)]),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text("Express yourself", style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25.0), border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.5)),
            child: Stack(
              children: [
                TextField(
                  controller: _thoughtController, maxLines: 5, style: context.textTheme.bodyMedium,
                  decoration: InputDecoration(hintText: "Write your thoughts...", hintStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(0.3)), contentPadding: const EdgeInsets.all(16.0), border: InputBorder.none),
                ),
                Positioned(
                  bottom: 8, right: 8,
                  child: IconButton(
                    onPressed: _isSavingNote ? null : _saveNote,
                    icon: _isSavingNote ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: Color(0xff628141)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}