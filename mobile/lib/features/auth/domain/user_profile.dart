import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role; // 'patient', 'doctor', 'executive', 'admin'
  final DateTime createdAt;
  final String? profilePictureUrl;
  final Map<String, dynamic>? additionalInfo;
  final String subscriptionStatus;
  final String? subscriptionPlan;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.profilePictureUrl,
    this.additionalInfo,
    required this.subscriptionStatus,
    this.subscriptionPlan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String,
      email: data['email'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      role: data['role'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profilePictureUrl: data['profilePictureUrl'] as String?,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
      subscriptionStatus: data['subscriptionStatus'] as String,
      subscriptionPlan: data['subscriptionPlan'] as String?,
      subscriptionStartDate: (data['subscriptionStartDate'] as Timestamp?)?.toDate(),
      subscriptionEndDate: (data['subscriptionEndDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt,
      'profilePictureUrl': profilePictureUrl,
      'additionalInfo': additionalInfo,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStartDate': subscriptionStartDate,
      'subscriptionEndDate': subscriptionEndDate,
    };
  }
}

