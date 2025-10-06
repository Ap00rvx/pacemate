import '../entities/auth_requests.dart';
import '../entities/auth_responses.dart';
import '../repositories/auth_repository.dart';

/// Base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}

/// Login use case
class LoginUseCase implements UseCase<AuthResponse, LoginRequest> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<AuthResponse> call(LoginRequest params) async {
    return await repository.login(params);
  }
}

/// Signup use case
class SignupUseCase implements UseCase<AuthResponse, SignupRequest> {
  final AuthRepository repository;

  const SignupUseCase(this.repository);

  @override
  Future<AuthResponse> call(SignupRequest params) async {
    return await repository.signup(params);
  }
}

/// Google check use case (Step 1)
class GoogleCheckUseCase
    implements UseCase<GoogleCheckResponse, GoogleCheckRequest> {
  final AuthRepository repository;

  const GoogleCheckUseCase(this.repository);

  @override
  Future<GoogleCheckResponse> call(GoogleCheckRequest params) async {
    return await repository.googleCheck(params);
  }
}

/// Google signup use case (Step 2)
class GoogleSignupUseCase
    implements UseCase<AuthResponse, GoogleSignupRequest> {
  final AuthRepository repository;

  const GoogleSignupUseCase(this.repository);

  @override
  Future<AuthResponse> call(GoogleSignupRequest params) async {
    return await repository.googleSignup(params);
  }
}

/// Get profile use case
class GetProfileUseCase implements UseCase<ProfileResponse, NoParams> {
  final AuthRepository repository;

  const GetProfileUseCase(this.repository);

  @override
  Future<ProfileResponse> call(NoParams params) async {
    return await repository.getProfile();
  }
}

/// Update profile use case
class UpdateProfileUseCase
    implements UseCase<ProfileResponse, UpdateProfileRequest> {
  final AuthRepository repository;

  const UpdateProfileUseCase(this.repository);

  @override
  Future<ProfileResponse> call(UpdateProfileRequest params) async {
    return await repository.updateProfile(params);
  }
}

/// Check email exists use case
class CheckEmailExistsUseCase implements UseCase<EmailCheckResponse, String> {
  final AuthRepository repository;

  const CheckEmailExistsUseCase(this.repository);

  @override
  Future<EmailCheckResponse> call(String params) async {
    return await repository.checkEmailExists(params);
  }
}

/// Refresh token use case
class RefreshTokenUseCase
    implements UseCase<TokenResponse, RefreshTokenRequest> {
  final AuthRepository repository;

  const RefreshTokenUseCase(this.repository);

  @override
  Future<TokenResponse> call(RefreshTokenRequest params) async {
    return await repository.refreshToken(params);
  }
}

/// Logout use case
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.logout();
  }
}

/// Check authentication status use case
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  const CheckAuthStatusUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}
