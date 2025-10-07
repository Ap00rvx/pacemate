import 'package:dio/dio.dart';
import 'package:pacemate/core/network/dio.dart';
import '../../domain/entities/auth_requests.dart';
import '../../domain/entities/auth_responses.dart';

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, [this.statusCode]);

  @override
  String toString() => 'AuthException: $message';
}

/// Remote data source for authentication API calls
class AuthRemoteDataSource {
  final DioNetworkClient _networkClient;

  AuthRemoteDataSource() : _networkClient = DioNetworkClient();

  /// Login user with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _networkClient.client.post(
        '/api/users/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw AuthException('Login failed', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error during login',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error during login');
    }
  }

  /// Sign up new user
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await _networkClient.client.post(
        '/api/users/signup',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw AuthException('Signup failed', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error during signup',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error during signup');
    }
  }

  /// Google check - Step 1: Check if user exists
  Future<GoogleCheckResponse> googleCheck(GoogleCheckRequest request) async {
    try {
      final response = await _networkClient.client.post(
        '/api/users/google-check',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return GoogleCheckResponse.fromJson(response.data);
      } else {
        throw AuthException('Google check failed', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error during Google check',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error during Google check');
    }
  }

  /// Google signup - Step 2: Create new user with Google credentials
  Future<AuthResponse> googleSignup(GoogleSignupRequest request) async {
    try {
      final response = await _networkClient.client.post(
        '/api/users/google-signup',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw AuthException('Google signup failed', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error during Google signup',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error during Google signup');
    }
  }

  /// Get user profile
  Future<ProfileResponse> getProfile(String token) async {
    try {
      final response = await _networkClient.client.get(
        '/api/users/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      } else {
        throw AuthException('Failed to get profile', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error while getting profile',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error while getting profile');
    }
  }

  /// Update user profile
  Future<ProfileResponse> updateProfile(
    UpdateProfileRequest request,
    String token,
  ) async {
    try {
      final json = request.toJson();
      final avatar = json.remove('avatar');

      Response response;
      // If avatar looks like a local file path (not http/https/data uri),
      // use multipart/form-data so backend multer can populate req.file
      if (avatar is String &&
          avatar.isNotEmpty &&
          !(avatar.startsWith('http://') ||
              avatar.startsWith('https://') ||
              avatar.startsWith('data:'))) {
        final form = FormData();
        // Append non-null fields
        json.forEach((key, value) {
          if (value != null) form.fields.add(MapEntry(key, value.toString()));
        });
        form.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(avatar, filename: 'avatar.jpg'),
          ),
        );
        response = await _networkClient.client.put(
          '/api/users/profile',
          data: form,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      } else {
        // Send JSON; server will treat avatar as URL/base64 if provided
        if (avatar != null) json['avatar'] = avatar;
        response = await _networkClient.client.put(
          '/api/users/profile',
          data: json,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      } else {
        throw AuthException('Failed to update profile', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error while updating profile',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error while updating profile');
    }
  }

  /// Check if email exists
  Future<EmailCheckResponse> checkEmailExists(String email) async {
    try {
      final response = await _networkClient.client.get(
        '/api/users/check-email',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return EmailCheckResponse.fromJson(response.data);
      } else {
        throw AuthException('Failed to check email', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error while checking email',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error while checking email');
    }
  }

  /// Refresh access token
  Future<TokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _networkClient.client.post(
        '/api/users/refresh-token',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return TokenResponse.fromJson(response.data);
      } else {
        throw AuthException('Failed to refresh token', response.statusCode);
      }
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] ?? 'Network error while refreshing token',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException('Unexpected error while refreshing token');
    }
  }
}
