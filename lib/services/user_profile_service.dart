import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String location,
    required String userType, // "Local" / "Traveller"
  }) async {
    await _db.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "location": location,
      "userType": userType,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final uid = _uid;
    if (uid == null) {
      // dummy stream that won't crash UI
      return const Stream.empty();
    }
    return _db.collection("users").doc(uid).snapshots();
  }

  Future<void> updateLocationAndType({
    required String location,
    required String userType,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection("users").doc(uid).set({
      "location": location,
      "userType": userType,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
