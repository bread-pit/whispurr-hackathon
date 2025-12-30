import 'package:flutter/material.dart';
import 'package:whispurr_hackathon/theme.dart';
import 'package:whispurr_hackathon/views/login_signup/textField_card.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
                      hintText: 'Name'
                  ),

                  // Password textfield
                  TextfieldCard(
                    iconPath: 'assets/icons/lock-filled.svg',
                    hintText: 'Age',
                  ),

                  TextfieldCard(
                    iconPath: 'assets/icons/calendar.svg',
                    hintText: 'Birthday',
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff628141),
                          foregroundColor: Colors.white, // Text color
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
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
