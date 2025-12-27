class ApiConstants {
  // For Android Emulator use 10.0.2.2, for iOS Simulator use 127.0.0.1
  // For Physical Device use your machine's IP address (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 
  
  static const String authUrl = '$baseUrl/auth';
  static const String subscriptionUrl = '$baseUrl/subscription';
}
