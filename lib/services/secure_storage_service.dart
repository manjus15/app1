// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../core/utils/logger.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _mpinKey = 'user_mpin';
  static const _mpinAttemptsKey = 'mpin_attempts';
  static const _lastAttemptTimeKey = 'last_attempt_time';
  
  // Maximum failed attempts before lockout
  static const int maxAttempts = 3;
  // Lockout duration in minutes
  static const int lockoutDuration = 30;
  
  // Store MPIN securely
  static Future<void> storeMPIN(String mpin) async {
    try {
      await _storage.write(key: _mpinKey, value: mpin);
      // Reset attempts counter on successful MPIN creation
      await _storage.write(key: _mpinAttemptsKey, value: '0');
      AppLogger.info('MPIN stored securely');
    } catch (e) {
      AppLogger.error('Error storing MPIN: $e');
      throw Exception('Failed to store MPIN securely');
    }
  }

  // Validate MPIN strength
  static String? validateMPINStrength(String mpin) {
    if (mpin.length != 4) {
      return 'MPIN must be 4 digits';
    }
    
    // Check for sequential numbers
    for (int i = 0; i < mpin.length - 1; i++) {
      if (int.parse(mpin[i + 1]) - int.parse(mpin[i]) == 1) {
        return 'MPIN cannot contain sequential numbers';
      }
    }
    
    // Check for repeated digits
    if (mpin.split('').toSet().length < 3) {
      return 'MPIN must contain at least 3 different digits';
    }
    
    // Check for common patterns
    final commonPINs = ['1234', '0000', '1111', '9999'];
    if (commonPINs.contains(mpin)) {
      return 'Please choose a less common MPIN';
    }
    
    return null;
  }

  // Check if device supports biometrics
  static Future<bool> isBiometricsAvailable() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      return await auth.canCheckBiometrics;
    } catch (e) {
      AppLogger.error('Error checking biometrics availability: $e');
      return false;
    }
  }

  // Authenticate using biometrics
  static Future<bool> authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to create MPIN',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      AppLogger.error('Biometric authentication error: $e');
      return false;
    }
  }

  // Check for rate limiting
  static Future<bool> isRateLimited() async {
    try {
      final attempts = await _storage.read(key: _mpinAttemptsKey);
      final lastAttemptTime = await _storage.read(key: _lastAttemptTimeKey);
      
      if (attempts == null || lastAttemptTime == null) {
        return false;
      }

      final currentAttempts = int.parse(attempts);
      final lastAttempt = DateTime.parse(lastAttemptTime);
      final now = DateTime.now();

      if (currentAttempts >= maxAttempts) {
        final timeDifference = now.difference(lastAttempt).inMinutes;
        if (timeDifference < lockoutDuration) {
          return true;
        } else {
          // Reset attempts after lockout period
          await _storage.write(key: _mpinAttemptsKey, value: '0');
          return false;
        }
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking rate limit: $e');
      return false;
    }
  }

  // Record failed attempt
  static Future<void> recordFailedAttempt() async {
    try {
      final attempts = await _storage.read(key: _mpinAttemptsKey) ?? '0';
      final currentAttempts = int.parse(attempts) + 1;
      await _storage.write(key: _mpinAttemptsKey, value: currentAttempts.toString());
      await _storage.write(key: _lastAttemptTimeKey, value: DateTime.now().toIso8601String());
    } catch (e) {
      AppLogger.error('Error recording failed attempt: $e');
    }
  }
}