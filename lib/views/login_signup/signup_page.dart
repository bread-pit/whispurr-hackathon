import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/views/login_signup/textField_card.dart';
import 'package:whispurr_hackathon/views/navigation/navigation_route.dart';
import 'package:whispurr_hackathon/core/services/supabase_service.dart';
import 'package:whispurr_hackathon/core/services/profile_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
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
      // For now, we'll create a profile without authentication
      // In a full implementation, you'd use Supabase Auth first
      final email = '${_nameController.text.toLowerCase().replaceAll(' ', '_')}@whispurr.app';
      
      // Note: In production, you'd use Supabase Auth signup here
      // For now, we'll just navigate to the main app
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigateRoute()),
      );
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
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
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/gradient_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Container for content
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
                  color: AppColors.black.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    'assets/images/logo.png',
                    width: 60,
                  ),

                  SizedBox(height: 20),


                  Text(
                      'Clarity starts here.',
                      style: context.textTheme.titleMedium
                  ),

                  SizedBox(height: 30),

                  // Username textfield
                  TextfieldCard(
                      iconPath: 'assets/icons/user-filled.svg',
                      hintText: 'Name',
                      controller: _nameController,
                  ),

                  TextfieldCard(
                    iconPath: 'assets/icons/calendar.svg',
                    hintText: 'Birthday',
                    controller: _birthdayController,
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff628141),
                          foregroundColor: Colors.white, // Text color
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Start your journey',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              )
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
