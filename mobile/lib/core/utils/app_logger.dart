
import 'dart:developer' as developer;

class AppLogger {
  static void logInfo(String message) {
    developer.log('INFO: $message', name: 'ATKANS_MED');
  }

  static void logWarning(String message) {
    developer.log('WARNING: $message', name: 'ATKANS_MED');
  }

  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log('ERROR: $message', name: 'ATKANS_MED', error: error, stackTrace: stackTrace);
  }
}
