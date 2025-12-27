import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

class FirestoreExampleScreen extends ConsumerStatefulWidget {
  const FirestoreExampleScreen({super.key});

  @override
  ConsumerState<FirestoreExampleScreen> createState() => _FirestoreExampleScreenState();
}

class _FirestoreExampleScreenState extends ConsumerState<FirestoreExampleScreen> {
  final TextEditingController _noteController = TextEditingController();

  Future<void> _addNote() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null || _noteController.text.trim().isEmpty) {
      return;
    }

    final firestore = ref.read(firestoreProvider);
    await firestore.collection('users').doc(user.uid).collection('notes').add({
      'text': _noteController.text.trim(),
      'timestamp': Timestamp.now(),
    });
    _noteController.clear();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Firestore Example')),
        body: const Center(child: Text('Please log in to view and add notes.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes (Firestore)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.read(firestoreProvider)
                  .collection('users')
                  .doc(user.uid)
                  .collection('notes')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data?.docs ?? [];

                if (notes.isEmpty) {
                  return const Center(child: Text('No notes yet. Add one below!'));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(note['text']),
                        subtitle: Text(
                          (note['timestamp'] as Timestamp).toDate().toLocal().toString().split('.')[0],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await note.reference.delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'New note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
