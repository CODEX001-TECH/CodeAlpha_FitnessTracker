import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PedometerService {
  StreamSubscription<StepCount>? _subscription;
  final Function(int) onStepCount;

  PedometerService({required this.onStepCount});

  Future<void> start() async {
    // Permission check for Mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      var status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        _subscription = Pedometer.stepCountStream.listen(
          (StepCount event) => onStepCount(event.steps),
          onError: (error) => print('Pedometer Error: $error'),
        );
      }
    } else {
      print('Automatic step detection is only available on Mobile devices.');
    }
  }

  void stop() {
    _subscription?.cancel();
  }

  // Helper for simulation (useful for testing on PC)
  void simulateStep(int currentSteps) {
    onStepCount(currentSteps + 1);
  }
}
