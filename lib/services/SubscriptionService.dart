import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/subscription.dart';
import '../util/util.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName =
      'Subscription'; // Adjust based on your environment setup

  // Add a subscription
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(subscription.id)
          .set(subscription.toJson());
    } catch (e) {
      print('Error adding subscription: $e');
      rethrow;
    }
  }

  // Get all subscriptions

  Future<List<Subscription>> getAllSubscriptions() async {
    try {
      String documentPath = getFirestoreDocument();
      final areasCollection = _firestore.collection(documentPath);

      QuerySnapshot querySnapshot = await areasCollection
          .doc('Subscription')
          .collection('Subscription')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Document data is null');
        }
        data['id'] = doc.id;
        return Subscription.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }

  // Update a subscription
  Future<void> updateSubscription(Subscription subscription) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(subscription.id)
          .update(subscription.toJson());
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Delete a subscription
  Future<void> deleteSubscription(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting subscription: $e');
      rethrow;
    }
  }

  activateSubscription(String id) {
    print('activateSubscription');
  }
}
