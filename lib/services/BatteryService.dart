// lib/services/battery_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/Battery.dart';
import '../util/util.dart';

class BatteryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String env = getFirestoreDocument();

  BatteryService() ;

  // Fetch all batteries
  Future<List<Battery>> getAllBatteries() async {
    try {

      QuerySnapshot querySnapshot = await _firestore
          .collection(env)
          .doc('Batterys') // Ensure this matches your Firestore path
          .collection('Batterys')
          .get();

      return querySnapshot.docs.map((doc) {
        return Battery.fromJson(doc.data() as Map<String, dynamic> );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching batteries: $e');
      rethrow;
    }
  }

  // Update battery status
  Future<void> updateBatteryStatus(String batteryId, String newStatus) async {
    try {
      await _firestore
          .collection(env)
          .doc('Batterys')
          .collection('Batterys')
          .doc(batteryId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating battery status: $e');
      rethrow;
    }
  }

  // Optionally, add methods to add or delete batteries
  Future<void> addBattery(Battery battery) async {
    try {
      await _firestore
          .collection(env)
          .doc('Batterys')
          .collection('Batterys')
          .doc(battery.id)
          .set(battery.toJson());
    } catch (e) {
      debugPrint('Error adding battery: $e');
      rethrow;
    }
  }

  Future<void> deleteBattery(String batteryId) async {
    try {
      await _firestore
          .collection(env)
          .doc('Batterys')
          .collection('Batterys')
          .doc(batteryId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting battery: $e');
      rethrow;
    }
  }
}
