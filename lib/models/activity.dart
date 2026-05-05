import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String? id;
  final String type; // e.g., Running, Walking, Cycling, Gym
  final double value; // e.g., distance in km or step count
  final String unit; // e.g., km, steps, kcal
  final DateTime timestamp;
  final double caloriesBurned;

  Activity({
    this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.caloriesBurned,
  });

  // Convert a Map (from Firestore) into an Activity object
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      type: data['type'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      caloriesBurned: (data['caloriesBurned'] ?? 0).toDouble(),
    );
  }

  // Convert an Activity object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': Timestamp.fromDate(timestamp),
      'caloriesBurned': caloriesBurned,
    };
  }
}
