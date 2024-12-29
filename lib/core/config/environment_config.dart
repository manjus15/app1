// lib/core/config/environment_config.dart
class EnvironmentConfig {
  static const bool isDevelopment = true;
  
  static final List<Map<String, String>> countryCodes = [
    {'code': '+91', 'country': 'IND'},
    {'code': '+1', 'country': 'USA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+971', 'country': 'UAE'},
  ];
  
  static String get defaultCountryCode => '+91';
  
  static String? validatePhoneNumber(String? value, String countryCode) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    
    int requiredLength = countryCode == '+971' ? 9 : 10;
    
    if (value.length != requiredLength) {
      return 'Please enter a valid $requiredLength-digit mobile number';
    }
    return null;
  }
}