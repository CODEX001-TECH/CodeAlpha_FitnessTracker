import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  FirestoreService();

  // Get a reference to the user's activities collection
  CollectionReference get _activitiesRef => 
      _db.collection('users').doc(userId).collection('activities');

  // Add a new activity log
  Future<void> addActivity(Activity activity) async {
    try {
      await _activitiesRef.add(activity.toFirestore());
    } catch (e) {
      print("Error adding activity: $e");
      rethrow;
    }
  }

  // Get activities stream for real-time updates
  Stream<List<Activity>> getActivities() {
    return _activitiesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    });
  }

  // Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _activitiesRef.doc(activityId).delete();
    } catch (e) {
      print("Error deleting activity: $e");
      rethrow;
    }
  }

  // Profile Management
  Stream<Map<String, dynamic>?> getUserProfile() {
    return _db.collection('users').doc(userId).snapshots().map((doc) => doc.data());
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
