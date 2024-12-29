// lib/services/session_service.dart
import 'dart:async';
// ignore: unused_import
import '../core/utils/logger.dart';

class SessionService {
  static const int sessionTimeoutMinutes = 5;
  static DateTime? _lastActivityTime;
  static Timer? _sessionTimer;
  static Function()? _onSessionTimeout;

  static void startSession( {required Null Function() onTimeout, required Null Function() onWarning}) {
    _onSessionTimeout = onTimeout;
    _updateLastActivityTime();
    _startSessionTimer();
  }

  static void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkSession(),
    );
  }

  static void _checkSession() {
    if (_lastActivityTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastActivityTime!).inMinutes;
      
      if (difference >= sessionTimeoutMinutes) {
        _sessionTimer?.cancel();
        _onSessionTimeout?.call();
      }
    }
  }

  static void updateActivity() {
    _updateLastActivityTime();
  }

  static void _updateLastActivityTime() {
    _lastActivityTime = DateTime.now();
  }

  static void endSession() {
    _sessionTimer?.cancel();
    _lastActivityTime = null;
    _onSessionTimeout = null;
  }
}