import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/theme_provider.dart';
import 'services/firestore_service.dart';
import 'screens/main/splash_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (context) => ActivityProvider(FirestoreService()),
          update: (context, auth, previous) {
            // Re-fetch data if the user has changed
            return ActivityProvider(FirestoreService());
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Stride Fitness',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF4C66EE),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              cardColor: Colors.white,
              fontFamily: 'Inter',
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4C66EE),
                onSurface: Color(0xFF1E293B),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF4C66EE),
              scaffoldBackgroundColor: const Color(0xFF0F111A),
              cardColor: const Color(0xFF1A1D2E),
              fontFamily: 'Inter',
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4C66EE),
                onSurface: Colors.white,
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
