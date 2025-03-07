import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? fallbackRoute;

  const RouteGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: AuthService().getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return fallbackRoute ?? const SizedBox();
        }

        final userRole = snapshot.data!;
        if (!allowedRoles.contains(userRole)) {
          return fallbackRoute ??
              const Scaffold(
                body: Center(
                  child: Text('Access Denied'),
                ),
              );
        }

        return child;
      },
    );
  }
}