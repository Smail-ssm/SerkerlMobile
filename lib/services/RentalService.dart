import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Rental.dart';
import '../util/util.dart';

class RentalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new Rental
  Future<void> addRental(Rental rental) async {
    try {
      String documentPath = getFirestoreDocument(); // Replace with your logic
      await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rental.id)
          .set(rental.toJson());
      print('Rental added successfully with ID: ${rental.id}');
    } catch (e) {
      print('Error adding rental: $e');
      rethrow;
    }
  }

  // Fetch a Rental by ID
  Future<Rental?> fetchRentalById(String rentalId) async {
    try {
      String documentPath = getFirestoreDocument();
      DocumentSnapshot rentalDoc = await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rentalId)
          .get();

      if (rentalDoc.exists) {
        return Rental.fromJson(rentalDoc.data() as Map<String, dynamic>);
      } else {
        print('Rental with ID $rentalId not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching rental by ID: $e');
      rethrow;
    }
  }

  // Fetch a Rental by Vehicle ID
  Future<Rental?> getRentalByVehicleId(String vehicleId) async {
    try {
      String documentPath = getFirestoreDocument();
      QuerySnapshot querySnapshot = await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .where('vId', isEqualTo: vehicleId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Rental.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print('No rental found for vehicle ID $vehicleId.');
        return null;
      }
    } catch (e) {
      print('Error fetching rental by vehicle ID: $e');
      rethrow;
    }
  }

  // Fetch all Rentals for a specific user
  Future<List<Rental>> fetchRentalsByUser(String userId) async {
    try {
      String documentPath = getFirestoreDocument();
      QuerySnapshot querySnapshot = await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .where('user', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return Rental.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching rentals by user: $e');
      rethrow;
    }
  }

  // Update an existing Rental
  Future<void> updateRental(String rentalId, Map<String, dynamic> updates) async {
    try {
      String documentPath = getFirestoreDocument();
      await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rentalId)
          .update(updates);

      print('Rental with ID $rentalId updated successfully.');
    } catch (e) {
      print('Error updating rental: $e');
      rethrow;
    }
  }
  Future<void> updateRentalNotes(String rentalId, String? newNotes) async {
    try {
      String documentPath = getFirestoreDocument();
      await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rentalId)
          .update({'notes': newNotes});

      print('Rental notes for ID $rentalId updated successfully.\n');
    } catch (e) {
      print('Error updating rental notes: $e');
      rethrow;
    }
  }

  // Delete a Rental by ID
  Future<void> deleteRental(String rentalId) async {
    try {
      String documentPath = getFirestoreDocument();
      await _firestore
          .collection(documentPath)
          .doc('Rentals')
          .collection('Rentals')
          .doc(rentalId)
          .delete();

      print('Rental with ID $rentalId deleted successfully.');
    } catch (e) {
      print('Error deleting rental: $e');
      rethrow;
    }
  }
}
