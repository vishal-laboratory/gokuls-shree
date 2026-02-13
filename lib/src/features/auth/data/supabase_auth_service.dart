import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================
// AUTH STATES
// ============================================
sealed class SupabaseAuthState {}

class AuthInitial extends SupabaseAuthState {}

class AuthLoading extends SupabaseAuthState {}

class AuthAuthenticated extends SupabaseAuthState {
  final User user;
  final Map<String, dynamic>? profile;
  AuthAuthenticated(this.user, this.profile);

  // Backward compatibility alias
  Map<String, dynamic>? get studentData => profile;
}

class AuthError extends SupabaseAuthState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends SupabaseAuthState {}

// ============================================
// AUTH NOTIFIER (Real Supabase Auth)
// ============================================
// ============================================
// AUTH NOTIFIER (Real Supabase Auth)
// ============================================
class SupabaseAuthNotifier extends ChangeNotifier {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseAuthState _state = AuthInitial();

  SupabaseAuthState get state => _state;

  SupabaseAuthNotifier() {
    _init();
  }

  void _init() {
    // Listen to auth changes
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _loadProfile(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _state = AuthUnauthenticated();
        notifyListeners();
      }
    });

    // Check if already logged in
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      _loadProfile(currentUser);
      _state = AuthLoading(); // Will be updated by _loadProfile
      notifyListeners();
    } else {
      _state = AuthInitial();
      notifyListeners();
    }
  }

  /// Load user profile from profiles table
  Future<void> _loadProfile(User user) async {
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      _state = AuthAuthenticated(user, profile);
    } catch (e) {
      debugPrint('⚠️ Failed to load profile: $e');
      _state = AuthAuthenticated(user, null);
    }
    notifyListeners();
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadProfile(response.user!);
      } else {
        _state = AuthError('Login failed. Invalid credentials.');
        notifyListeners();
      }
    } on AuthException catch (e) {
      _state = AuthError(e.message);
      notifyListeners();
    } catch (e) {
      _state = AuthError('Login failed: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Sign in with phone OTP
  Future<void> signInWithPhone({required String phone}) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      await _client.auth.signInWithOtp(phone: phone);
      // OTP sent — UI should show the OTP input screen
      _state = AuthUnauthenticated(); // Waiting for OTP verification
      notifyListeners();
    } on AuthException catch (e) {
      _state = AuthError(e.message);
      notifyListeners();
    } catch (e) {
      _state = AuthError('Failed to send OTP: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Verify phone OTP
  Future<void> verifyOtp({required String phone, required String token}) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );

      if (response.user != null) {
        await _loadProfile(response.user!);
      } else {
        _state = AuthError('OTP verification failed.');
        notifyListeners();
      }
    } on AuthException catch (e) {
      _state = AuthError(e.message);
      notifyListeners();
    } catch (e) {
      _state = AuthError('OTP verification failed: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Sign in with registration number (lookup → then auth)
  Future<void> signInWithRegNo({
    required String registrationNumber,
    required String password,
  }) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      // Look up student email by reg number
      final student = await _client
          .from('students')
          .select('email')
          .eq('registration_number', registrationNumber)
          .maybeSingle();

      if (student == null || student['email'] == null) {
        _state = AuthError('Registration number not found.');
        notifyListeners();
        return;
      }

      // Sign in with the student's email
      await signIn(email: student['email'], password: password);
    } catch (e) {
      _state = AuthError('Login failed: ${e.toString()}');
      notifyListeners();
    }
  }

  /// Admin login
  Future<void> adminLogin({
    required String loginId,
    required String password,
  }) async {
    // Admin uses normal email login — role is determined by profiles table
    await signIn(email: loginId, password: password);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _state = AuthUnauthenticated();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Sign out error: $e');
      _state = AuthUnauthenticated();
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign up (currently disabled — students are enrolled by admin)
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? registrationNumber,
    String? phone,
  }) async {
    _state = AuthLoading();
    notifyListeners();
    // Registration is disabled for now — students are enrolled by admin
    await Future.delayed(const Duration(seconds: 1));
    _state = AuthError(
      'Registration is disabled. Please contact the school admin.',
    );
    notifyListeners();
  }

  /// Update profile
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    // Will be implemented when profile editing is needed
  }

  /// Get current user's role
  String? get currentRole {
    if (_state is AuthAuthenticated) {
      return (_state as AuthAuthenticated).profile?['role'];
    }
    return null;
  }

  /// Check if current user is admin
  bool get isAdmin {
    final role = currentRole;
    return role == 'super_admin' || role == 'branch_admin';
  }
}

// ============================================
// PROVIDERS
// ============================================

// Use ChangeNotifierProvider instead of NotifierProvider
final supabaseAuthNotifierProvider = Provider<SupabaseAuthNotifier>((ref) {
  final notifier = SupabaseAuthNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

// Backward compatibility for consumers watching the state
final supabaseAuthProvider = Provider<SupabaseAuthState>((ref) {
  return ref.watch(supabaseAuthNotifierProvider).state;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(supabaseAuthProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

final userProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(supabaseAuthProvider);
  if (authState is AuthAuthenticated) {
    return authState.profile;
  }
  return null;
});

final userRoleProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?['role'];
});

// Note: isAdminProvider is defined in admin_repository.dart
// It checks both profiles.role AND the admins table for comprehensive access control.

// Backward compatibility
final studentDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(userProfileProvider);
});
