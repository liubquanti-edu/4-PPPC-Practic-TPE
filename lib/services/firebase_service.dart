import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/marker_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MarkerModel>> getMarkers() async {
    try {
      final snapshot = await _firestore.collection('markers').get();
      return snapshot.docs
          .map((doc) => MarkerModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting markers: $e');
      return [];
    }
  }

  Future<void> addMarker(MarkerModel marker) async {
    try {
      await _firestore.collection('markers').add(marker.toMap());
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  Future<void> updateMarker(MarkerModel marker) async {
    try {
      await _firestore
          .collection('markers')
          .doc(marker.id)
          .update(marker.toMap());
    } catch (e) {
      print('Error updating marker: $e');
    }
  }

  Future<void> deleteMarker(String markerId) async {
    try {
      await _firestore.collection('markers').doc(markerId).delete();
    } catch (e) {
      print('Error deleting marker: $e');
    }
  }
}