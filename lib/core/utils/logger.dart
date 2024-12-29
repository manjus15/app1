// lib/core/utils/logger.dart
import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('BankingApp');
  
  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // In development, we'll see logs in the console
      // In production, you might want to send these to a logging service
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static void debug(String message) => _logger.fine(message);
  static void info(String message) => _logger.info(message);
  static void warning(String message) => _logger.warning(message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}