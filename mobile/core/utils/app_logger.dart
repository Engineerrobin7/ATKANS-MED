class AppLogger {
  static void logInfo(String message, {dynamic error, StackTrace? stackTrace}) {
    print('INFO: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  static void logWarning(String message, {dynamic error, StackTrace? stackTrace}) {
    print('WARNING: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    print('ERROR: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  static void logDebug(String message, {dynamic error, StackTrace? stackTrace}) {
    print('DEBUG: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
}