import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _tasksCollection {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('tasks');
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _tasksCollection.add({
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUserId,
    });
  }

  Stream<QuerySnapshot> getTasks() {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _tasksCollection.doc(taskId).update({
      'title': title.trim(),
      'description': description.trim(),
    });
  }

  Future<void> deleteTask({required String taskId}) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _tasksCollection.doc(taskId).delete();
  }
}