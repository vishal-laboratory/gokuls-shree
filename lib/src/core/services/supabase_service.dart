import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gokul_shree_app/src/core/config/env_config.dart';

/// Supabase configuration loaded from .env file
/// Get these values from: Supabase Dashboard → Settings → API
class SupabaseConfig {
  // Credentials are loaded from .env file via EnvConfig
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
}

/// Initialize Supabase - call this in main() before runApp()
Future<void> initializeSupabase() async {
  if (!EnvConfig.isSupabaseConfigured) {
    throw Exception('Supabase credentials not configured in .env file');
  }

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
}

/// Get Supabase client instance
SupabaseClient get supabase => Supabase.instance.client;

/// Supabase service for all database operations
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // ============================================
  // COURSES
  // ============================================
  Future<List<Map<String, dynamic>>> getCourses({String? category}) async {
    var query = _client.from('courses').select().eq('is_active', true);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getCourseById(int id) async {
    final response = await _client
        .from('courses')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<List<String>> getCourseCategories() async {
    final response = await _client
        .from('courses')
        .select('category')
        .eq('is_active', true);

    final categories = <String>{};
    for (final row in response) {
      categories.add(row['category'] as String);
    }
    return categories.toList()..sort();
  }

  // ============================================
  // NOTICES
  // ============================================
  Future<List<Map<String, dynamic>>> getNotices({int? limit}) async {
    var query = _client
        .from('notices')
        .select()
        .eq('is_active', true)
        .order('published_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================
  // DOWNLOADS
  // ============================================
  Future<List<Map<String, dynamic>>> getDownloads() async {
    final response = await _client
        .from('downloads')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> incrementDownloadCount(int id) async {
    await _client.rpc('increment_download_count', params: {'row_id': id});
  }

  // ============================================
  // STUDENTS
  // ============================================
  Future<Map<String, dynamic>?> getStudentByRegNo(String regNo) async {
    final response = await _client
        .from('students')
        .select()
        .eq('registration_number', regNo)
        .maybeSingle();
    return response;
  }

  // ============================================
  // AUTH (using Supabase Auth)
  // ============================================
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

// Riverpod Providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return supabase;
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.watch(supabaseClientProvider));
});

// Data providers
final supabaseCoursesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((
      ref,
      category,
    ) async {
      final service = ref.watch(supabaseServiceProvider);
      return service.getCourses(category: category);
    });

final supabaseNoticesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getNotices(limit: 10);
});

final supabaseDownloadsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getDownloads();
});
