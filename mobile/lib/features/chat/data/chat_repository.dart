
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
    
    // Update last message in chat document
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': [message.senderId, message.receiverId],
    }, SetOptions(merge: true));
  }

  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }
}
