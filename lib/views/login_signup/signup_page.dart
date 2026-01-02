import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whispurr_hackathon/core/widgets/animated_gradient_screen.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/views/login_signup/textField_card.dart';
import 'package:whispurr_hackathon/views/navigation/navigation_route.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff628141), 
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
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty || _birthdayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final email = '$cleanName${DateTime.now().millisecondsSinceEpoch}@whispurr.com'; 
      const password = 'ChangeMe123!'; 

      // Create User & Save Name to Metadata
      final AuthResponse res = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'birthday': _birthdayController.text.trim(),
        },
      );

      if (res.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigateRoute()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
        children: [
            Positioned.fill(
              child: VividAnimatedBackground()
            ),
            Center(
            child: Container(
                margin: const EdgeInsets.all(32.0),
                padding: const EdgeInsets.all(32.0),
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.black.withOpacity(0.5),
                      width: 0.5,
                  ),
                ),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Image.asset('assets/images/logo.png', width: 60),
                    const SizedBox(height: 20),
                    Text('Clarity starts here.', style: context.textTheme.titleMedium),
                    const SizedBox(height: 30),

                    TextfieldCard(
                        iconPath: 'assets/icons/user-filled.svg',
                        hintText: 'Name',
                        controller: _nameController,
                    ),
                    GestureDetector(
                      onTap: _selectDate, 
                      child: AbsorbPointer( 
                        child: TextfieldCard(
                          iconPath: 'assets/icons/calendar.svg',
                          hintText: 'Birthday',
                          controller: _birthdayController,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff628141),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                            : Text('Start your journey', style: context.textTheme.bodyMedium?.copyWith(color: Colors.white))
                    ),
                    ),
                ],
                ),
            ),
            )
        ],
        ),
    );
  }
}