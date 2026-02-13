import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/features/auth/data/auth_service.dart';
import 'package:gokul_shree_app/src/features/auth/domain/student_user.dart';

// Auth State
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final StudentUser user;
  final String token;
  AuthAuthenticated(this.user, this.token);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {}

// Auth Notifier using standard Notifier pattern
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthInitial();
  }

  Future<void> login(String registrationNumber, String password) async {
    state = AuthLoading();

    final authService = ref.read(authServiceProvider);
    final response = await authService.login(registrationNumber, password);

    if (response.success && response.user != null && response.token != null) {
      state = AuthAuthenticated(response.user!, response.token!);
    } else {
      state = AuthError(response.error ?? 'Login failed');
    }
  }

  Future<void> loginOffline(String registrationNumber, String password) async {
    // Fallback mock login when backend is unavailable
    state = AuthLoading();

    await Future.delayed(const Duration(seconds: 1));

    if (registrationNumber == '12345' && password == 'password') {
      state = AuthAuthenticated(
        const StudentUser(
          id: '1',
          registrationNumber: '12345',
          name: 'Test Student (Offline)',
          email: 'test@example.com',
          courseName: 'ADCA',
          sessionYear: '2025-26',
        ),
        'offline_token',
      );
    } else {
      state = AuthError('Invalid credentials (Offline mode)');
    }
  }

  void logout() {
    final authService = ref.read(authServiceProvider);
    authService.logout();
    state = AuthUnauthenticated();
  }
}

// Provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
