import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/area.dart';
import '../util/util.dart';

class AreaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Area>> fetchAreas() async {
    try {
      String documentPath = getFirestoreDocument();
      final areasCollection = _firestore.collection(documentPath);

      QuerySnapshot querySnapshot =
          await areasCollection.doc('Areas').collection('Areas').get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Document data is null');
        }
        data['id'] = doc.id;
        return Area.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }
}
