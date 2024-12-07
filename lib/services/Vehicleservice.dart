import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/model/MaintenanceLog.dart';

import '../model/Rental.dart';
import '../model/vehicule.dart';
import '../util/util.dart';

class Vehicleservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> fetchVehicles() async {
    try {
      String documentPath = getFirestoreDocument();
      final vehiclesCollection = _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles');

      QuerySnapshot querySnapshot = await vehiclesCollection.get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Document data is null');
        }
        data['id'] = doc.id;

        return Vehicle.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching Vehicles: $e');
      rethrow;
    }
  }

  // Add a new maintenance log for a vehicle
  Future<void> addMaintenanceLog(String vehicleId, MaintenanceLog log) async {
    try {
      String documentPath = getFirestoreDocument();
      await _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles')
          .doc(vehicleId)
          .update({
        'maintenanceLog': FieldValue.arrayUnion([log.toJson()])
      });

      print('Maintenance log added successfully for vehicle $vehicleId');
    } catch (e) {
      print('Error adding maintenance log for vehicle $vehicleId: $e');
      rethrow;
    }
  }

  // Update an existing maintenance log for a vehicle
  Future<void> updateMaintenanceLog(String vehicleId, String logId, MaintenanceLog updatedLog) async {
    try {
      String documentPath = getFirestoreDocument();
      final maintenanceLogDoc = _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles')
          .doc(vehicleId)
          .collection('MaintenanceLogs')
          .doc(logId);

      await maintenanceLogDoc.update(updatedLog.toJson());
      print('Maintenance log updated successfully for vehicle $vehicleId');
    } catch (e) {
      print('Error updating maintenance log for vehicle $vehicleId: $e');
      rethrow;
    }
  }

  // Update reservation status for a vehicle
  Future<void> updateVehicleReservationStatus(String vehicleId, bool isReserved) async {
    try {
      String documentPath = getFirestoreDocument();
      await _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles')
          .doc(vehicleId)
          .update({
        'isReserved': isReserved,
      });

      print(
          'Vehicle reservation status updated successfully for vehicle $vehicleId');
    } catch (e) {
      print('Error updating reservation status for vehicle $vehicleId: $e');
      rethrow;
    }
  }

  Future<void> reserveVehicle(String vehicleId, String userId, Rental rental) async {
    try {
      String documentPath = getFirestoreDocument();
      // Add the Rental object to the "Rentals" collection
      await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rental.id)
          .set(rental.toJson());

      // Update the vehicle's reservation status
      await _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles')
          .doc(vehicleId)
          .update({
        'isReserved': true,
        'user': userId, // Add reserved user ID
      });

      print('Vehicle reserved successfully');
    } catch (e) {
      print('Error reserving vehicle: $e');
      rethrow;
    }
  }

  Future<void> cancelReservation(String vehicleId, String userId) async {
    try {
      String documentPath = getFirestoreDocument();

      // Find the Rental object associated with the vehicle and user
      final rentalQuery = await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .where('vId', isEqualTo: vehicleId)
          .where('user', isEqualTo: userId)
          .get();

      if (rentalQuery.docs.isNotEmpty) {
        final rentalId = rentalQuery.docs.first.id;

        // Delete the Rental object
        await _firestore
            .collection(documentPath)
            .doc('Rentals')
            .collection('Rentals')
            .doc(rentalId)
            .delete();

        // Update the vehicle's reservation status
        await _firestore
            .collection(documentPath)
            .doc('Vehicles')
            .collection('Vehicles')
            .doc(vehicleId)
            .update({
          'isReserved': false,
          'reservedBy': null,
        });

        print('Reservation canceled successfully');
      }
    } catch (e) {
      print('Error canceling reservation: $e');
      rethrow;
    }
  }

  Future<Vehicle> fetchVehicleById(String vehicleId) async {
    try {
      String documentPath = getFirestoreDocument();
      DocumentSnapshot vehicleDoc = await _firestore
          .collection(documentPath)
          .doc('Vehicles')
          .collection('Vehicles')
          .doc(vehicleId)
          .get();

      if (vehicleDoc.exists) {
        return Vehicle.fromJson(vehicleDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Vehicle not found.');
      }
    } catch (e) {
      print('Error fetching vehicle: $e');
      rethrow;
    }
  }
}
