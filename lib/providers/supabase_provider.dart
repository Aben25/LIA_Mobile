import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/easy_loading_config.dart';

class SupabaseProvider extends ChangeNotifier {
  User? _user;
  Session? _session;
  bool _initialized = false;

  User? get user => _user;
  Session? get session => _session;
  bool get initialized => _initialized;

  SupabaseClient get supabase => SupabaseConfig.client;

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      // Get current session
      final session = supabase.auth.currentSession;
      _session = session;
      _user = session?.user;

      _initialized = true;

      // Set up auth state change listener
      supabase.auth.onAuthStateChange.listen((data) {
        _session = data.session;
        _user = data.session?.user;
        notifyListeners();
      });
    } catch (error) {
      debugPrint('❌ [AUTH] Error initializing auth: $error');
      _initialized = true; // Still mark as initialized to prevent hanging
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      print('🔐 [SIGNUP] Starting signup for email: $email');
      print('🔐 [SIGNUP] Supabase client: ${supabase.auth}');
      print('🔐 [SIGNUP] Calling supabase.auth.signUp...');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      print(
          '📡 [SIGNUP] Response received: User=${response.user != null}, Session=${response.session != null}');
      print('📡 [SIGNUP] Full response: $response');

      // Check if the user needs to confirm their email (like Expo app)
      if (response.user != null && response.session == null) {
        print('📧 [SIGNUP] User created, needs email confirmation');
        print('📧 [SIGNUP] User ID: ${response.user!.id}');
        print('📧 [SIGNUP] User email: ${response.user!.email}');

        // Don't throw exception - this is the expected behavior for email confirmation
        print('✅ [SIGNUP] User created successfully, email confirmation sent');
        return; // Success - user created and email sent
      }

      if (response.user != null && response.session != null) {
        print(
            '✅ [SIGNUP] User created and session established (no email confirmation needed)');
        print('✅ [SIGNUP] User ID: ${response.user!.id}');
      }

      print('✅ [SIGNUP] Signup process completed successfully');
    } catch (error) {
      print('❌ [SIGNUP] Error: ${error.toString()}');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signInWithPassword(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid email or password. Please try again.');
      }

      // Session will be updated via the auth state change listener
    } catch (error) {
      if (error.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (error.toString().contains('Email not confirmed')) {
        throw Exception('Please confirm your email address before signing in.');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      // User and session will be cleared via the auth state change listener
    } catch (error) {
      print('Error signing out: $error');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (error) {
      if (error.toString().contains('User not found')) {
        throw Exception(
            'No account found with this email address. Please check your email and try again.');
      } else if (error.toString().contains('rate limit')) {
        throw Exception(
            'Too many password reset attempts. Please try again later.');
      }
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      if (response.user == null) {
        throw Exception('Failed to update password. Please try again.');
      }
    } catch (error) {
      print('Error updating password: $error');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      print('🗑️ [DELETE] Starting account deletion...');

      // For now, we'll just sign out the user
      // In a production app, you would typically:
      // 1. Call a serverless function to delete user data
      // 2. Delete from related tables
      // 3. Then delete the auth account

      // For demo purposes, we'll just sign out
      await supabase.auth.signOut();

      print('✅ [DELETE] Account deletion initiated (user signed out)');
    } catch (error) {
      print('❌ [DELETE] Error deleting account: $error');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _user != null && _session != null;

  // Fetch projects for guest mode (public access)
  Future<List<Map<String, dynamic>>> fetchProjects() async {
    try {
      print('🔍 [GUEST] Fetching projects from Supabase...');

      final response = await supabase.from('projects').select('''
            id,
            project_title,
            goal,
            impact,
            project_type,
            project_profile_picture_id,
            profile_picture:project_profile_picture_id(id, filename),
            latest_status:projects_status(
              id,
              progress,
              description,
              spent_amount,
              last_updated_date
            )
          ''').order('created_at', ascending: false);

      print('🔍 [GUEST] Successfully fetched ${response.length} projects');

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      print('❌ [GUEST] Error fetching projects: $error');
      rethrow;
    }
  }
}
