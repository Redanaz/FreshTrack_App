import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'core/notification_service.dart'; // Logic Lead: Import the new service

void main() async {
  // 1. Ensure Flutter is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_SUPABASE_ANON_KEY');
  if (Supabase.instance.client.auth.currentSession == null) {
    await Supabase.instance.client.auth.signInAnonymously();
  }

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
      home: const HomeScreen(),
    );
  }
}