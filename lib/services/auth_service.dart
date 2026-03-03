import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with custom fields
  Future<Map<String, dynamic>> signIn({
    required String customerId,
    required String userId,
    required String password,
  }) async {
    try {
      // Create email from customerId and userId for Supabase Auth
      String email = '${customerId}_$userId@dreamdestination.com';
      
      // Sign in with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'message': 'Login successful!',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please check your credentials.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign up with custom fields
  Future<Map<String, dynamic>> signUp({
    required String customerId,
    required String userId,
    required String password,
  }) async {
    try {
      // Create email from customerId and userId
      String email = '${customerId}_$userId@dreamdestination.com';
      
      // Create user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'customer_id': customerId,
          'user_id': userId,
        },
      );

      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'message': 'Account created successfully!',
        };
      } else {
        return {
          'success': false,
          'message': 'Sign up failed. Please try again.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Error message helper
  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect credentials. Please try again.';
    } else if (message.contains('User already registered')) {
      return 'An account already exists with these credentials.';
    } else if (message.contains('Password should be at least')) {
      return 'Password should be at least 6 characters.';
    } else if (message.contains('Invalid email')) {
      return 'Invalid credentials format.';
    } else {
      return 'Authentication failed: $message';
    }
  }
}
