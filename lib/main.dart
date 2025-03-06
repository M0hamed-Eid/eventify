import 'package:eventify/screens/calendar/event_calendar_screen.dart';
import 'package:eventify/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/database_provider.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

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

  await invokeTestEnvFunction();
  runApp(const MyApp());
}

Future<void> invokeTestEnvFunction() async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase.functions.invoke(
      'test-env',
      headers: {
        'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
      },
    );
    print('Response: ${response.data}');
  } catch (error) {
    print('Error invoking function: $error');
  }
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
      home: const MainScreen(),
    ));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;


  final List<Widget> _screens = const [
    HomeScreen(),
    EventCalendarScreen(),
    AdminDashboard(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}