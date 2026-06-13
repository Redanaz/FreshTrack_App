/*
 * Supabase Dashboard Steps:
 * 1. Go to Supabase Dashboard -> Authentication -> Providers -> Enable Google
 * 2. Add your SHA-1 fingerprint from ./gradlew signingReport to the Google Cloud Console OAuth client
 * 3. Copy the Google Client ID into Supabase's Google provider settings
 * 4. Add the Supabase redirect URL com.example.fresh_track_app://login-callback to Google Cloud Console's authorised redirect URIs
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'core/notification_service.dart'; // Logic Lead: Import the new service

void main() async {
  // 1. Ensure Flutter is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: 'https://vlevtrwflvictiluylge.supabase.co', anonKey: 'sb_publishable_HCMi1Fw7JwZOCqHmWOgx_Q_gQYd7yAh');

  // 2. Initialize the Notification Service and Timezones
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const FreshTrackApp());
}

class FreshTrackApp extends StatelessWidget {
  const FreshTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display', 
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D44)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}