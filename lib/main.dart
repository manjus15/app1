// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/select_bank_screen.dart';
import 'screens/mobile_verification_screen.dart' as mobile;
import 'screens/otp_verification_screen.dart' as otp;
import 'screens/create_mpin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // Make sure this line is present
      routes: {
        '/select_bank': (context) => const SelectBankScreen(),
        '/mobile_verification': (context) => const mobile.MobileVerificationScreen(),
        '/otp_verification': (context) => const otp.OTPVerificationScreen(),
        '/create_mpin': (context) => const CreateMPINScreen(),
        //'/profile_setup': (context) => const ProfileSetupScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
