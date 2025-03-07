import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/auth_wrapper.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/calendar/event_calendar_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../services/auth_service.dart';
import '../utils/route_transition.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String admin = '/admin';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return RouteTransition(page: const AuthWrapper());
      case login:
        return RouteTransition(page: const LoginScreen());
      case signup:
        return RouteTransition(page: const SignupScreen());
      case home:
        return RouteTransition(page: const MainScreen());
      default:
        return RouteTransition(
          page: Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}