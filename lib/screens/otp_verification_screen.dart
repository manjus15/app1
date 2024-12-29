// lib/screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
// ignore: unused_import
import '../core/utils/logger.dart';
import '../services/otp_service.dart';
import '../core/config/environment_config.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // Controllers for the 6 OTP input fields
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _resendTimer = 30;
  String? _mobileNumber;
  int _attempts = 0;
  static const int _maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    // In development mode, pre-fill OTP fields
    if (EnvironmentConfig.isDevelopment) {
      Future.delayed(const Duration(milliseconds: 500), () {
        const devOTP = OTPService.devOTP;
        for (int i = 0; i < devOTP.length && i < _controllers.length; i++) {
          _controllers[i].text = devOTP[i];
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mobileNumber = ModalRoute.of(context)?.settings.arguments as String?;
    
    if (_mobileNumber != null) {
      _sendOTP(); // Send initial OTP
    }
  }

  Future<void> _sendOTP() async {
    try {
      await OTPService.sendOTP(_mobileNumber!);
      
      if (EnvironmentConfig.isDevelopment) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Development Mode: Use OTP 123456'),
              duration: Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _checkAndVerifyOTP();
            }
          } else if (index > 0 && value.isEmpty) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  void _checkAndVerifyOTP() {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      _verifyOTP(otp);
    }
  }

  Future<void> _verifyOTP(String otp) async {
    if (_mobileNumber == null) return;

    setState(() => _isLoading = true);
    
    try {
      final isValid = await OTPService.verifyOTP(_mobileNumber!, otp);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (isValid) {
          // Navigate to MPIN creation screen
          Navigator.pushReplacementNamed(context, '/create_mpin');
        } else {
          _attempts++;
          
          if (_attempts >= _maxAttempts) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum attempts reached. Please try again later.'),
                duration: Duration(seconds: 5),
              ),
            );
            Navigator.pop(context); // Go back to mobile verification
          } else {
            // Clear OTP fields
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid OTP. ${_maxAttempts - _attempts} attempts remaining.'
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: $e')),
        );
      }
    }
  }

  void _resendOTP() {
    if (_resendTimer == 0 && _mobileNumber != null) {
      setState(() => _resendTimer = 30);
      _startResendTimer();
      _sendOTP();
      
      // Clear existing OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    if (_mobileNumber != null) {
      OTPService.clearStoredOTP(_mobileNumber!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (EnvironmentConfig.isDevelopment)
                const Banner(
                  message: 'Development Mode',
                  location: BannerLocation.topEnd,
                ),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent you an SMS with the code to $_mobileNumber',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOTPField(index),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: _resendTimer == 0 ? _resendOTP : null,
                  child: Text(
                    _resendTimer > 0
                        ? 'Resend code in ${_resendTimer}s'
                        : 'Resend code',
                    style: TextStyle(
                      color: _resendTimer > 0 ? Colors.grey : Colors.blue,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Verify',
                onPressed: _checkAndVerifyOTP,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}