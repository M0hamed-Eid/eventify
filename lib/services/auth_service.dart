
import 'package:supabase_flutter/supabase_flutter.dart';

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
}