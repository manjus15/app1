// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../core/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.info('Splash Screen initialized');
    _navigateToNext();
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 3), () {
      AppLogger.info('Navigation timer completed');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/select_bank');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building Splash Screen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Buildings illustration at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/building_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          // Centered logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/cobank_logo.png',
                  width: 120,  // Adjust size as needed
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}