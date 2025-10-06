import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/auth_requests.dart';
import '../../domain/entities/auth_responses.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);

    if (response.success &&
        response.token != null &&
        response.refreshToken != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
      );
      if (response.user?.id != null) {
        await _localDataSource.saveUserId(response.user!.id!);
      }
    }

    return response;
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    final response = await _remoteDataSource.signup(request);

    if (response.success &&
        response.token != null &&
        response.refreshToken != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
      );
      if (response.user?.id != null) {
        await _localDataSource.saveUserId(response.user!.id!);
      }
    }

    return response;
  }

  @override
  Future<GoogleCheckResponse> googleCheck(GoogleCheckRequest request) async {
    final response = await _remoteDataSource.googleCheck(request);

    // If user exists and tokens are provided, save them
    if (response.success &&
        response.userExists &&
        response.token != null &&
        response.refreshToken != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
      );
      if (response.user?.id != null) {
        await _localDataSource.saveUserId(response.user!.id!);
      }
    }

    return response;
  }

  @override
  Future<AuthResponse> googleSignup(GoogleSignupRequest request) async {
    final response = await _remoteDataSource.googleSignup(request);

    if (response.success &&
        response.token != null &&
        response.refreshToken != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
      );
      if (response.user?.id != null) {
        await _localDataSource.saveUserId(response.user!.id!);
      }
    }

    return response;
  }

  @override
  Future<ProfileResponse> getProfile() async {
    final token = await _localDataSource.getAccessToken();
    if (token == null) {
      throw Exception('No access token available');
    }

    return await _remoteDataSource.getProfile(token);
  }

  @override
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    final token = await _localDataSource.getAccessToken();
    if (token == null) {
      throw Exception('No access token available');
    }

    return await _remoteDataSource.updateProfile(request, token);
  }

  @override
  Future<EmailCheckResponse> checkEmailExists(String email) async {
    return await _remoteDataSource.checkEmailExists(email);
  }

  @override
  Future<TokenResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await _remoteDataSource.refreshToken(request);

    if (response.success &&
        response.token != null &&
        response.refreshToken != null) {
      await _localDataSource.saveTokens(
        response.token!,
        response.refreshToken!,
      );
    }

    return response;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAll();
  }

  @override
  Future<String?> getAccessToken() async {
    return await _localDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _localDataSource.getRefreshToken();
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _localDataSource.saveTokens(accessToken, refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _localDataSource.clearAll();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _localDataSource.hasTokens();
  }
}
