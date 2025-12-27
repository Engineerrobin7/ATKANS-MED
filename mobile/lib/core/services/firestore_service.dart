import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // Example: Get a document by path
  Future<DocumentSnapshot> getDocument(String path) {
    return _firestore.doc(path).get();
  }

  // Example: Get a collection
  Stream<QuerySnapshot> getCollection(String path) {
    return _firestore.collection(path).snapshots();
  }

  // Example: Add data to a collection
  Future<DocumentReference> addData(String collectionPath, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).add(data);
  }

  // Example: Set/Update data in a document
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = false}) {
    return _firestore.doc(path).set(data, SetOptions(merge: merge));
  }

  // Example: Update specific fields in a document
  Future<void> updateData(String path, Map<String, dynamic> data) {
    return _firestore.doc(path).update(data);
  }

  // Example: Delete a document
  Future<void> deleteDocument(String path) {
    return _firestore.doc(path).delete();
  }
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreService(firestore);
});
