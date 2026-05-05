class ActivityConstants {
  // Calories burned per unit (Step or Minute)
  static const Map<String, double> caloriesPerUnit = {
    'Running': 0.05,  // per step
    'Walking': 0.04,  // per step
    'Cycling': 8.0,   // per minute
    'Gym': 6.0,       // per minute
    'Swimming': 10.0, // per minute
    'Other': 4.0,     // per minute
  };

  static String getUnitForType(String type) {
    if (type == 'Running' || type == 'Walking') {
      return 'steps';
    }
    return 'mins';
  }
}
