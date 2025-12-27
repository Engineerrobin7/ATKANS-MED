import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String title;
  final String type;
  final String downloadUrl;
  final DateTime createdAt;
  final String userId;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.downloadUrl,
    required this.createdAt,
    required this.userId,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      title: data['title'] as String,
      type: data['type'] as String,
      downloadUrl: data['downloadUrl'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'downloadUrl': downloadUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }
}
