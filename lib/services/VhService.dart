import 'package:cloud_firestore/cloud_firestore.dart';
 import '../model/vehicule.dart';
import '../util/util.dart';

class Vehicleservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> fetchVehicles() async {
    try {
      String documentPath = await getFirestoreDocument();
      final VehiclesCollection = _firestore.collection(documentPath);

      QuerySnapshot querySnapshot = await VehiclesCollection
          .doc('Vehicles')
          .collection('Vehicles')
          .get();

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
}
