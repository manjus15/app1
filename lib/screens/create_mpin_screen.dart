// lib/screens/create_mpin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/session_warning_dialog.dart';
import '../core/utils/logger.dart';
import '../services/secure_storage_service.dart';
import '../services/session_service.dart';

class CreateMPINScreen extends StatefulWidget {
  const CreateMPINScreen({super.key});

  @override
  State<CreateMPINScreen> createState() => _CreateMPINScreenState();
}

class _CreateMPINScreenState extends State<CreateMPINScreen> {
  // Controllers for MPIN input fields
  final List<TextEditingController> _mpinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  
  final List<TextEditingController> _confirmControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Focus nodes for input fields
  final List<FocusNode> _mpinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  
  final List<FocusNode> _confirmFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // State variables
  bool _biometricsAvailable = false;
  bool _isConfirmationMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Initializes the screen with necessary security checks
  Future<void> _initializeScreen() async {
    await _checkBiometrics();
    _startSecureSession();
  }

  /// Checks if the device supports biometric authentication
  Future<void> _checkBiometrics() async {
    final available = await SecureStorageService.isBiometricsAvailable();
    setState(() => _biometricsAvailable = available);
  }

  /// Sets up a secure session with timeout handling
  void _startSecureSession() {
    SessionService.startSession(
      onTimeout: () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      onWarning: () {
        if (mounted) {
          _showSessionWarning();
        }
      },
    );
  }

  /// Shows the session warning dialog
  void _showSessionWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionWarningDialog(
        onExtendSession: () {
          // Session is automatically extended by the dialog
        },
        onLogout: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }

  /// Handles input for each MPIN digit
  void _handleMPINInput(String value, int index, bool isConfirmation) {
    SessionService.updateActivity();  // Update session activity
    
    final focusNodes = isConfirmation ? _confirmFocusNodes : _mpinFocusNodes;

    if (value.isNotEmpty) {
      if (index < 3) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
        if (!isConfirmation) {
          setState(() {
            _isConfirmationMode = true;
            _errorMessage = null;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            _confirmFocusNodes[0].requestFocus();
          });
        } else {
          _verifyAndSaveMPIN();
        }
      }
    } else if (index > 0 && value.isEmpty) {
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Creates an individual PIN input field
  Widget _buildPINField(int index, bool isConfirmation) {
    final controllers = isConfirmation ? _confirmControllers : _mpinControllers;
    final focusNodes = isConfirmation ? _confirmFocusNodes : _mpinFocusNodes;

    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        obscuringCharacter: '●',
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
        onChanged: (value) => _handleMPINInput(value, index, isConfirmation),
      ),
    );
  }

  /// Verifies and saves the MPIN securely
  Future<void> _verifyAndSaveMPIN() async {
    setState(() => _isLoading = true);
    
    final mpin = _mpinControllers.map((c) => c.text).join();
    final confirmMpin = _confirmControllers.map((c) => c.text).join();

    // Validate MPIN strength
    final validationError = SecureStorageService.validateMPINStrength(mpin);
    if (validationError != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = validationError;
        _clearFields();
      });
      return;
    }

    // Verify MPIN match
    if (mpin != confirmMpin) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'MPINs do not match. Please try again.';
        _clearConfirmationFields();
      });
      return;
    }

    try {
      // Request biometric authentication if available
      if (_biometricsAvailable) {
        final authenticated = await SecureStorageService.authenticateWithBiometrics();
        if (!authenticated) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Biometric authentication failed. Please try again.';
          });
          return;
        }
      }

      // Store MPIN securely
      await SecureStorageService.storeMPIN(mpin);
      
      if (mounted) {
        setState(() => _isLoading = false);
        AppLogger.info('MPIN created successfully');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MPIN created successfully')),
        );

        Navigator.pushReplacementNamed(context, '/profile_setup');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to create MPIN. Please try again.';
        });
      }
    }
  }

  /// Clears all input fields
  void _clearFields() {
    for (var controller in [..._mpinControllers, ..._confirmControllers]) {
      controller.clear();
    }
    _mpinFocusNodes[0].requestFocus();
    setState(() => _isConfirmationMode = false);
  }

  /// Clears only confirmation fields
  void _clearConfirmationFields() {
    for (var controller in _confirmControllers) {
      controller.clear();
    }
    _confirmFocusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create MPIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create your MPIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirmationMode
                    ? 'Confirm your MPIN'
                    : 'Enter a 4-digit PIN for secure access',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => _buildPINField(index, _isConfirmationMode),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              if (_biometricsAvailable)
                const Text(
                  'Your MPIN will be secured with biometric authentication',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create MPIN',
                onPressed: _isConfirmationMode ? () => _verifyAndSaveMPIN() : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SessionService.endSession();
    for (var controller in [..._mpinControllers, ..._confirmControllers]) {
      controller.dispose();
    }
    for (var node in [..._mpinFocusNodes, ..._confirmFocusNodes]) {
      node.dispose();
    }
    super.dispose();
  }
}