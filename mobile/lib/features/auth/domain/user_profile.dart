class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role; // 'patient', 'doctor', 'executive', 'admin'
  final DateTime createdAt;
  final String? profilePictureUrl;
  final Map<String, dynamic>? additionalInfo;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.profilePictureUrl,
    this.additionalInfo,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String,
      email: data['email'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      role: data['role'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      profilePictureUrl: data['profilePictureUrl'] as String?,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'additionalInfo': additionalInfo,
    };
  }
}
