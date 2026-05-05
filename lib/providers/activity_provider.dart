import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ActivityProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Activity> _activities = [];
  bool _isLoading = false;
  
  // Stream subscriptions to cancel on dispose
  StreamSubscription? _profileSubscription;
  StreamSubscription? _activitySubscription;

  // Live tracking data
  int _liveSteps = 0;
  double _liveCalories = 0;
  
  // User Profile data
  String _displayName = "User";
  int _stepGoal = 10000;
  String? _photoUrl;

  ActivityProvider(this._firestoreService) {
    _fetchActivities();
    _fetchProfile();
  }

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  int get liveSteps => _liveSteps;
  double get liveCalories => _liveCalories;
  String get displayName => _displayName;
  int get stepGoal => _stepGoal;
  String? get photoUrl => _photoUrl;

  void _fetchProfile() {
    _profileSubscription?.cancel();
    _profileSubscription = _firestoreService.getUserProfile().listen((data) {
      // Check if we are already disposed before calling notifyListeners
      _displayName = data?['displayName'] ?? "User";
      _stepGoal = data?['stepGoal'] ?? 10000;
      _photoUrl = data?['photoUrl'];
      notifyListeners();
    }, onError: (e) => print("Profile Stream Error: $e"));
  }

  Future<void> updateProfile(String name, int goal) async {
    await _firestoreService.updateUserProfile({
      'displayName': name,
      'stepGoal': goal,
    });
  }

  Future<void> updatePhoto(String url) async {
    await _firestoreService.updateUserProfile({
      'photoUrl': url,
    });
  }

  void updateLiveSteps(int steps) {
    _liveSteps = steps;
    // Simple calorie estimation: 0.04 kcal per step
    _liveCalories = steps * 0.04;
    notifyListeners();
  }

  // Fetch activities and listen for updates
  void _fetchActivities() {
    _isLoading = true;
    notifyListeners();

    _activitySubscription?.cancel();
    _activitySubscription = _firestoreService.getActivities().listen((activityList) {
      _activities = activityList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) => print("Activity Stream Error: $e"));
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _activitySubscription?.cancel();
    super.dispose();
  }

  // Add activity
  Future<void> addActivity(Activity activity) async {
    await _firestoreService.addActivity(activity);
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    await _firestoreService.deleteActivity(activityId);
  }

  // Dashboard Stats (Today's Historical + Live)
  double get totalCaloriesBurned {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    double historicalToday = _activities
        .where((a) => a.timestamp.isAfter(today))
        .fold(0, (sum, item) => sum + item.caloriesBurned);
        
    return historicalToday + _liveCalories;
  }

  double get totalSteps {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double historicalToday = _activities
        .where((a) => a.unit == 'steps' && a.timestamp.isAfter(today))
        .fold(0, (sum, item) => sum + item.value);
        
    return historicalToday + _liveSteps;
  }

  // Data for the last 7 days for the chart
  Map<String, double> get weeklyCalorieData {
    Map<String, double> data = {};
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dayLabel = DateFormat('E').format(day); // e.g., Mon, Tue
      
      double dayTotal = _activities.where((a) {
        return a.timestamp.year == day.year &&
               a.timestamp.month == day.month &&
               a.timestamp.day == day.day;
      }).fold(0, (sum, item) => sum + item.caloriesBurned);
      
      data[dayLabel] = dayTotal;
    }
    return data;
  }
}
