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
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.black,
                  width: 1,
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

                  Text('Sign Up', style: context.textTheme.displayLarge),

                  SizedBox(height: 10),

                  Text(
                      'Clarity starts here.',
                      style: context.textTheme.titleMedium
                  ),

                  SizedBox(height: 30),

                  // Email textfield
                  TextfieldCard(
                      iconPath: 'assets/icons/email.svg',
                      hintText: 'Email'
                  ),

                  // Username textfield
                  TextfieldCard(
                      iconPath: 'assets/icons/user-filled.svg',
                      hintText: 'Username'
                  ),

                  // Password textfield
                  TextfieldCard(
                    iconPath: 'assets/icons/lock-filled.svg',
                    hintText: 'Password',
                    isPassword: true,
                  ),

                  TextfieldCard(
                    iconPath: 'assets/icons/lock-filled.svg',
                    hintText: 'Confirm Password',
                    isPassword: true,
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
                          'Sign Up',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        )
                    ),
                  ),

                  // Signup Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: context.textTheme.bodySmall,
                      ),

                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(5),
                            minimumSize: const Size(0, 0),
                          ),
                          child: Text(
                            'Sign in',
                            style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600
                            ),
                          )
                      ),
                    ],
                  )

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
