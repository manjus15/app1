// lib/screens/profile_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/image_picker_service.dart';
import '../services/secure_storage_service.dart';
import '../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _panController = TextEditingController();
  final _aadharController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  // Pick profile image from gallery
  Future<void> _pickImage() async {
    try {
      final File? image = await ImagePickerService.pickProfileImage();
      if (image != null) {
        setState(() => _profileImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // Show date picker for date of birth
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      helpText: 'Select Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  // Validate form and save profile
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile picture')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Create user profile
        final profile = UserProfile(
          fullName: _nameController.text,
          email: _emailController.text,
          dateOfBirth: _dobController.text,
          address: _addressController.text,
          profileImagePath: _profileImage?.path,
          panNumber: _panController.text,
          aadharNumber: _aadharController.text,
        );

        // Save profile data securely
        await SecureStorageService.saveUserProfile(profile);

        if (mounted) {
          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Selection
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF2196F3),
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Colors.white,
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Fields
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Please enter your full name (first and last name)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth Field
                CustomTextField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field
CustomTextField(
  label: 'Address',
  controller: _addressController,
  maxLines: 3,  // This will now work properly
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  },
),
                const SizedBox(height: 16),

                // KYC Information
                const Text(
                  'KYC Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // PAN Card Field
                CustomTextField(
                  label: 'PAN Number',
                  controller: _panController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PAN number';
                    }
                    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid PAN number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Aadhar Card Field
                CustomTextField(
                  label: 'Aadhar Number',
                  controller: _aadharController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Aadhar number';
                    }
                    if (value.length != 12) {
                      return 'Aadhar number must be 12 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                CustomButton(
                  text: 'Complete Profile',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}