import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  // Get Supabase credentials from environment configuration
  static const String supabaseUrl = Env.supabaseUrl;
  static const String supabaseAnonKey = Env.supabaseAnonKey;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }
}
