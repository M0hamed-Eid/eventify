
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

enum UserRole {
  user,
  admin,
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserRole> getCurrentUserRole() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] == 'admin' ? UserRole.admin : UserRole.user;
    } catch (e) {
      _logger.e('Error getting user role: $e');
      return UserRole.user;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      _logger.d('Signing up user: $email');

      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.toString().split('.').last,
        },
      );

      if (response.user == null) {
        throw 'Signup failed: No user returned';
      }

      _logger.d('User signed up successfully: ${response.user!.id}');
    } catch (e) {
      _logger.e('Error during signup: $e');
      throw 'Error during signup: $e';
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Signing in user: $email');

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Login failed: No user returned';
      }

      _logger.d('User signed in successfully: ${response.user!.id}');
    } catch (e) {
      _logger.e('Error during login: $e');
      throw 'Error during login: $e';
    }
  }

  Future<void> signOut() async {
    try {
      _logger.d('Signing out user');
      await _supabase.auth.signOut();
      _logger.d('User signed out successfully');
    } catch (e) {
      _logger.e('Error during sign out: $e');
      throw 'Error during sign out: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.d('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.d('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Error sending password reset: $e');
      throw 'Error sending password reset: $e';
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      _logger.d('Updating user password');
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      _logger.d('Password updated successfully');
    } catch (e) {
      _logger.e('Error updating password: $e');
      throw 'Error updating password: $e';
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      throw 'Error getting user profile: $e';
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);

      _logger.d('Profile updated successfully');
    } catch (e) {
      _logger.e('Error updating profile: $e');
      throw 'Error updating profile: $e';
    }
  }
}


/*
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<bool> isUserAdmin() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId)
          .eq('role', 'admin')
          .single();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}*/
