import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/api_client.dart';
import 'package:gokul_shree_app/src/features/auth/domain/student_user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String registrationNumber, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'registrationNumber': registrationNumber, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final user = StudentUser.fromJson(data['user']);
        final token = data['token'] as String;

        // Set token for future requests
        _apiClient.setAuthToken(token);

        return AuthResponse(success: true, user: user, token: token);
      } else {
        return AuthResponse(
          success: false,
          error: response.data['error'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<bool> register({
    required String registrationNumber,
    required String name,
    required String password,
    String? email,
    String? phone,
    int? courseId,
    String? sessionYear,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'registrationNumber': registrationNumber,
          'name': name,
          'password': password,
          'email': email,
          'phone': phone,
          'courseId': courseId,
          'sessionYear': sessionYear,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _apiClient.setAuthToken(null);
  }

  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.get('/auth/verify');
      return response.statusCode == 200 && response.data['valid'] == true;
    } catch (e) {
      return false;
    }
  }
}

class AuthResponse {
  final bool success;
  final StudentUser? user;
  final String? token;
  final String? error;

  AuthResponse({required this.success, this.user, this.token, this.error});
}

// Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});
