class Env {
  // Supabase Configuration - Use the same environment variable names as Expo
  // These should match your .env file from the Expo project
  static const String supabaseUrl = 'https://ntckmekstkqxqgigqzgn.supabase.co';
  // static const String supabaseAnonKey =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50Y2ttZWtzdGtxeHFnaWdxemduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzcwNDA3MCwiZXhwIjoyMDQzMjgwMDcwfQ.V97GVqdldwCTrThr4hJ93sB4pXwD7ito7OQtR4UfzYE';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50Y2ttZWtzdGtxeHFnaWdxemduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc3MDQwNzAsImV4cCI6MjA0MzI4MDA3MH0.Y2XD5ampTB2FMQHWukJqOs6oiHU0YCCXwCEJ_vn_CdA';

  // App Configuration
  static const String appName = 'Love in Action';
  static const String appVersion = '1.0.2'; // Match Expo version

  // Expo Project ID (for reference)
  static const String expoProjectId = 'b0196b01-e63b-4bf8-a0b4-3edacc926fc7';

  // API Configuration
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
}
