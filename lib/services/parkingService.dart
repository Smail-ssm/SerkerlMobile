import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/parking.dart';
import '../util/util.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all parkings
  Future<List<Parking>> fetchParkings() async {
    try {

      String documentPath = getFirestoreDocument();
      final areasCollection = _firestore.collection(documentPath);

      QuerySnapshot querySnapshot = await areasCollection
          .doc('Parkings')
          .collection('Parkings')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Parking.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }}
