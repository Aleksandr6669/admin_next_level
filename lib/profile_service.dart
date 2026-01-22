import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference get _schoolDocRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    // Предполагаем, что ID школы совпадает с UID ее создателя (администратора)
    return _firestore.collection('schools').doc(user.uid);
  }

  // --- Профиль Пользователя ---
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
      await _firestore.collection('users').doc(user.uid).update(data);
    } else {
      throw Exception('No user logged in');
    }
  }

  // --- Профиль Школы ---
  Stream<DocumentSnapshot> getSchoolProfile() {
    return _schoolDocRef.snapshots();
  }

  Future<void> updateSchoolProfile(Map<String, dynamic> data) async {
    final snapshot = await _schoolDocRef.get();

    Map<String, dynamic> dataToSave = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': _auth.currentUser!.uid,
    };

    if (!snapshot.exists) {
      dataToSave['creationDate'] = DateFormat('dd.MM.yyyy').format(DateTime.now());
      dataToSave['admins'] = [_auth.currentUser!.uid]; // Создатель автоматически становится админом
      dataToSave['teachers'] = [];
      dataToSave['students'] = [];
    }

    await _schoolDocRef.set(dataToSave, SetOptions(merge: true));
  }

  // --- Управление Пользователями Школы ---

  Future<DocumentSnapshot> getUserById(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<List<DocumentSnapshot>> searchUsersByEmail(String emailQuery) async {
    if (emailQuery.isEmpty) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: emailQuery)
        .where('email', isLessThanOrEqualTo: '$emailQuery\uf8ff')
        .limit(10)
        .get();
    return querySnapshot.docs;
  }

  Future<void> addUserToSchool(String userId, String role) async {
    String field = _getRoleField(role);
    await _schoolDocRef.update({
      field: FieldValue.arrayUnion([userId])
    });
  }

  Future<void> removeUserFromSchool(String userId, String role) async {
    String field = _getRoleField(role);
    await _schoolDocRef.update({
      field: FieldValue.arrayRemove([userId])
    });
  }

  String _getRoleField(String role) {
    switch (role) {
      case 'admins':
        return 'admins';
      case 'teachers':
        return 'teachers';
      case 'students':
        return 'students';
      default:
        throw Exception('Invalid role: $role');
    }
  }
}
