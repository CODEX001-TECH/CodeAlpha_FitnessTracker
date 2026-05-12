import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'step_tracker_channel',
      'Step Tracker Service',
      description: 'This channel is used for tracking steps in the background',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'step_tracker_channel',
        initialNotificationTitle: 'Stride Step Tracker',
        initialNotificationContent: 'Starting step tracking...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    StreamSubscription<StepCount>? subscription;

    service.on('stopService').listen((event) {
      subscription?.cancel();
      service.stopSelf();
    });

    subscription = Pedometer.stepCountStream.listen((StepCount event) async {
      final prefs = await SharedPreferences.getInstance();
      
      // We store the 'base' steps (first time we get a count today)
      int totalSteps = event.steps;
      int? baseSteps = prefs.getInt('base_steps');
      
      if (baseSteps == null) {
        await prefs.setInt('base_steps', totalSteps);
        baseSteps = totalSteps;
      }

      int todaySteps = totalSteps - baseSteps;
      await prefs.setInt('today_steps', todaySteps);

      flutterLocalNotificationsPlugin.show(
        888,
        'Stride Step Tracker',
        'You have taken $todaySteps steps today!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'step_tracker_channel',
            'Step Tracker Service',
            icon: '@mipmap/ic_launcher',
            ongoing: true,
          ),
        ),
      );

      service.invoke('update', {
        "steps": todaySteps,
      });
    }, onError: (error) {
      print("Pedometer Background Error: $error");
    });
  }
}
