import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/UserModel.dart';
import '../Models/BloodRequestModel.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Auth Services ---
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  // --- User Services ---
  Future<void> saveUserData(UserModel user) {
    return _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<UserModel>> searchDonors(String bloodGroup, String area) {
    return _firestore
        .collection('users')
        // .where('role', isEqualTo: 'donor') // Bug fixed: ab sab 'user' hain but donor searchable hain
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('area', isEqualTo: area)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((u) => u.uid != _auth.currentUser?.uid) // Khud ko filter kar diya
            .toList());
  }

  // --- Request Services ---
  Future<void> sendBloodRequest(BloodRequestModel request) {
    return _firestore.collection('requests').doc(request.requestId).set(request.toMap());
  }

  Stream<List<BloodRequestModel>> getIncomingRequests(String uid) {
    return _firestore
        .collection('requests')
        .where('donorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateRequestStatus(String requestId, String status) {
    return _firestore.collection('requests').doc(requestId).update({'status': status});
  }
}
