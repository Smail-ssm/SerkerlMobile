import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/task.dart';
import '../util/util.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Task>> fetchTasks() async {
    try {
      String env = getFirestoreDocument();

      QuerySnapshot querySnapshot = await _firestore
          .collection(env)
          .doc('Tasks')
          .collection('Tasks')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Document data is null');
        }
        return Task.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }
}
