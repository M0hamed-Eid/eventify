import 'package:eventify/screens/auth/auth_wrapper.dart';
import 'package:eventify/screens/main/main_screen.dart';
import 'package:eventify/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for FCM
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    // SUPABASE_URL
    url: 'https://xknkomvlqnvftoohfokn.supabase.co',
    // Project API Keys
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrbmtvbXZscW52ZnRvb2hmb2tuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyMDc5MjksImV4cCI6MjA1Njc4MzkyOX0.e1dPifWqPw23eEOswmy7UdGZxG8DulDh04SX32W7rD4',
  );

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Events App',
      theme: AppTheme.theme,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ));
  }
}
