import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  /* =========================
     CREATE PATIENT
     ========================= */

  static Future<void> createPatient({
    required String name,
    required int age,
    required String gender,
    required String caregiver,
    required String relationship,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) return;

    await _db
        .collection('caregivers')
        .doc(user.uid)
        .collection('patients')
        .add({
      'name': name,
      'age': age,
      'gender': gender,
      'caregiver': caregiver,
      'relationship': relationship,
      'created_at': Timestamp.now(),
    });
  }

  /* =========================
     GET PATIENTS
     ========================= */

  static Stream<QuerySnapshot> getPatients() {
    final user = AuthService.currentUser;

    return _db
        .collection('caregivers')
        .doc(user!.uid)
        .collection('patients')
        .snapshots();
  }

  /* =========================
     SAVE MEMORY RESULT
     ========================= */

  static Future<void> saveMemoryResult({
    required String patientId,
    required int score,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) return;

    await _db
        .collection('caregivers')
        .doc(user.uid)
        .collection('patients')
        .doc(patientId)
        .collection('test_results')
        .add({
      'test_type': 'memory',
      'score': score,
      'created_at': Timestamp.now(),
    });
  }
}