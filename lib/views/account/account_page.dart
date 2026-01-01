import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _notificationsEnabled = true;
  String _userName = "Angelica";
  DateTime _birthday = DateTime(2025, 12, 22);

  // 1. Logic for Editing Name
  void _editName() {
    final controller = TextEditingController(text: _userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter your name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                setState(() => _userName = controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 2. Logic for Selecting Birthday
  Future<void> _editBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.black)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  // 3. Logout Confirmation Popup
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your actual logout logic here
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/gradient_bg_2.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Account Info", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 12),
                _buildInfoCard(
                  children: [
                    _buildClickableRow(Icons.person, "Name", _userName, _editName),
                    const Divider(height: 32),
                    _buildClickableRow(Icons.calendar_month_rounded, "Birthday", DateFormat('MMMM dd, yyyy').format(_birthday), _editBirthday),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("General Settings", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 12),
                _buildInfoCard(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [Icon(Icons.notifications, size: 20), SizedBox(width: 12), Text("Notifications")]),
                        Switch(value: _notificationsEnabled, activeColor: Colors.black, onChanged: (val) => setState(() => _notificationsEnabled = val)),
                      ],
                    ),
                    const Divider(height: 32),
                    InkWell(
                      onTap: _showLogoutConfirmation,
                      child: const Row(children: [Icon(Icons.logout, size: 20), SizedBox(width: 12), Text("Logout")]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.grey.shade200, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  // Wrapper for clickable rows
  Widget _buildClickableRow(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}