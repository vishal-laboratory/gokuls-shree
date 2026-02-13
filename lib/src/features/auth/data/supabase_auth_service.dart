import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gokul_shree_app/src/core/services/api_client.dart';

// Auth State
sealed class SupabaseAuthState {}

class AuthInitial extends SupabaseAuthState {}

class AuthLoading extends SupabaseAuthState {}

class AuthAuthenticated extends SupabaseAuthState {
  final User user;
  final Map<String, dynamic>? studentData;
  AuthAuthenticated(this.user, this.studentData);
}

class AuthError extends SupabaseAuthState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends SupabaseAuthState {}

// Auth Notifier
class SupabaseAuthNotifier extends Notifier<SupabaseAuthState> {
  late ApiClient _apiClient;

  @override
  SupabaseAuthState build() {
    _apiClient = ref.read(apiClientProvider);
    return AuthInitial();
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = AuthLoading();

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      _handleLoginResponse(response);
    } catch (e) {
      state = AuthError('Login failed: ${e.toString()}');
    }
  }

  /// Sign in with registration number
  Future<void> signInWithRegNo({
    required String registrationNumber,
    required String password,
  }) async {
    state = AuthLoading();

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'regNo': registrationNumber, 'password': password},
      );
      _handleLoginResponse(response);
    } catch (e) {
      state = AuthError('Login failed: ${e.toString()}');
    }
  }

  void _handleLoginResponse(dynamic response) {
    // Handle Dio Response or raw Map
    dynamic data;
    int statusCode = 401;

    if (response is Map) {
      data = response;
      statusCode = 200; // Assume success if map returned directly
    } else {
      // Assume Dio Response
      data = response.data;
      statusCode = response.statusCode ?? 500;
    }

    if (statusCode >= 200 && statusCode < 300) {
      // Construct a Mock User object for UI compatibility
      var userData = data['user'];
      if (userData == null && data['data'] != null) {
        userData = data['data'];
      }

      final user = User(
        id: userData?['id'] ?? '1',
        appMetadata: {},
        userMetadata: {
          'name': userData?['name'] ?? 'User',
          'role': userData?['role'], // Explicitly map role
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      // Save Token
      if (data['token'] != null) {
        _apiClient.setAuthToken(data['token']);
      }

      state = AuthAuthenticated(user, {
        'name': userData?['name'],
        'registration_number':
            userData?['registrationNumber'] ?? userData?['id'],
        'phone': userData?['phone'],
        'course_name': userData?['course_id'],
      });
    } else {
      state = AuthError('Login failed. Invalid credentials.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _apiClient.setAuthToken(null);
    state = AuthUnauthenticated();
  }

  /// Sign in as Admin
  Future<void> adminLogin({
    required String loginId,
    required String password,
  }) async {
    state = AuthLoading();

    try {
      // For now, we use the same login endpoint but with a flag or specific payload
      // In a real app, this might be a separate endpoint like '/admin/login'
      final response = await _apiClient.post(
        '/auth/login',
        data: {'loginId': loginId, 'password': password, 'isAdmin': true},
      );
      _handleLoginResponse(response);
    } catch (e) {
      state = AuthError('Admin Login failed: ${e.toString()}');
    }
  }

  // Placeholder for Register
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? registrationNumber,
    String? phone,
  }) async {
    state = AuthLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = AuthError("Registration Disabled. Please contact Admin.");
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Mock success
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {}
}

// Provider
final supabaseAuthProvider =
    NotifierProvider<SupabaseAuthNotifier, SupabaseAuthState>(() {
      return SupabaseAuthNotifier();
    });

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(supabaseAuthProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

// Student data provider
final studentDataProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(supabaseAuthProvider);
  if (authState is AuthAuthenticated) {
    return authState.studentData;
  }
  return null;
});
