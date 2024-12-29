// lib/services/otp_service.dart
import '../core/config/environment_config.dart';
import '../core/utils/logger.dart';

class OTPService {
  static const String devOTP = '123456';
  static final Map<String, String> _devOTPStorage = {};

  static Future<void> sendOTP(String phoneNumber) async {
    if (EnvironmentConfig.isDevelopment) {
      _devOTPStorage[phoneNumber] = devOTP;
      AppLogger.info('Development Mode: OTP sent - $devOTP');
    } else {
      // Integration with actual OTP service would go here
      throw UnimplementedError('Production OTP service not implemented');
    }
  }

  static Future<bool> verifyOTP(String phoneNumber, String otp) async {
    if (EnvironmentConfig.isDevelopment) {
      return otp == devOTP;
    } else {
      throw UnimplementedError('Production OTP service not implemented');
    }
  }

  static void clearStoredOTP(String phoneNumber) {
    _devOTPStorage.remove(phoneNumber);
  }
}