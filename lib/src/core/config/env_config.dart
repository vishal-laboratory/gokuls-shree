import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file
class EnvConfig {
  // Private constructor
  EnvConfig._();

  /// Load environment variables from .env file
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // ===========================================
  // SUPABASE CONFIGURATION
  // ===========================================

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ===========================================
  // BACKEND API CONFIGURATION
  // ===========================================

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static int get apiTimeoutSeconds =>
      int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;

  // ===========================================
  // APP CONFIGURATION
  // ===========================================

  static String get appName => dotenv.env['APP_NAME'] ?? 'Gokul Shree School';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // ===========================================
  // WEBSITE URLS
  // ===========================================

  static String get websiteBaseUrl =>
      dotenv.env['WEBSITE_BASE_URL'] ?? 'https://gokulshreeschool.com';

  // ===========================================
  // VALIDATION
  // ===========================================

  /// Check if Supabase is configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Check if API is configured
  static bool get isApiConfigured => apiBaseUrl.isNotEmpty;
}
