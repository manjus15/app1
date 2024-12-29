// lib/models/user_profile.dart
class UserProfile {
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String address;
  final String? profileImagePath;
  final String panNumber;  // For KYC verification
  final String aadharNumber;  // For KYC verification

  UserProfile({
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.address,
    this.profileImagePath,
    required this.panNumber,
    required this.aadharNumber,
  });

  // Convert profile to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'profileImagePath': profileImagePath,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
    };
  }

  // Create profile from JSON data
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      panNumber: json['panNumber'] as String,
      aadharNumber: json['aadharNumber'] as String,
    );
  }
}