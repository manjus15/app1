// lib/widgets/session_warning_dialog.dart
import 'package:flutter/material.dart';
import '../services/session_service.dart';

/// A dialog that warns users about impending session timeout
/// Gives them the option to extend their session or log out
class SessionWarningDialog extends StatelessWidget {
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const SessionWarningDialog({
    super.key,
    required this.onExtendSession,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session Expiring Soon'),
      content: const Text(
        'Your session will expire in 1 minute due to inactivity. '
        'Would you like to extend your session?'
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLogout();
          },
          child: const Text('Logout'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onExtendSession();
            SessionService.updateActivity();
          },
          child: const Text('Extend Session'),
        ),
      ],
    );
  }
}