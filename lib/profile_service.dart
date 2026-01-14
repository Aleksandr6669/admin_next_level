
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot> getUserProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    } else {
      throw Exception('No user logged in');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      final dataWithTimestamp = {
        ...data,
        'profileEditedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(user.uid).update(dataWithTimestamp);
    } else {
      throw Exception('No user logged in');
    }
  }

  /// This function is now a placeholder and always allows editing.
  Future<bool> startEditing() async {
    // Always return true to indicate that editing can start.
    return true;
  }

  /// This function is now a placeholder.
  Future<void> finishEditing() async {
    // No action needed as we are not setting a lock anymore.
    return;
  }
}
