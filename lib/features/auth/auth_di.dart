import 'package:logger/logger.dart';

import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/bloc/auth_bloc.dart';

/// Dependency injection container for auth feature
class AuthDI {
  // Data sources
  static final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  static final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSource();

  // Repository
  static final AuthRepository _repository = AuthRepositoryImpl(
    remoteDataSource: _remoteDataSource,
    localDataSource: _localDataSource,
  );

  // Use cases
  static final LoginUseCase _loginUseCase = LoginUseCase(_repository);
  static final SignupUseCase _signupUseCase = SignupUseCase(_repository);
  static final GoogleCheckUseCase _googleCheckUseCase = GoogleCheckUseCase(
    _repository,
  );
  static final GoogleSignupUseCase _googleSignupUseCase = GoogleSignupUseCase(
    _repository,
  );
  static final GetProfileUseCase _getProfileUseCase = GetProfileUseCase(
    _repository,
  );
  static final UpdateProfileUseCase _updateProfileUseCase =
      UpdateProfileUseCase(_repository);
  static final CheckEmailExistsUseCase _checkEmailExistsUseCase =
      CheckEmailExistsUseCase(_repository);
  static final RefreshTokenUseCase _refreshTokenUseCase = RefreshTokenUseCase(
    _repository,
  );
  static final LogoutUseCase _logoutUseCase = LogoutUseCase(_repository);
  static final CheckAuthStatusUseCase _checkAuthStatusUseCase =
      CheckAuthStatusUseCase(_repository);

  /// Get AuthBloc instance
  static AuthBloc getAuthBloc() {
    Logger().d('Creating AuthBloc instance');
    return AuthBloc(
      loginUseCase: _loginUseCase,
      signupUseCase: _signupUseCase,
      googleCheckUseCase: _googleCheckUseCase,
      googleSignupUseCase: _googleSignupUseCase,
      getProfileUseCase: _getProfileUseCase,
      updateProfileUseCase: _updateProfileUseCase,
      checkEmailExistsUseCase: _checkEmailExistsUseCase,
      refreshTokenUseCase: _refreshTokenUseCase,
      logoutUseCase: _logoutUseCase,
      checkAuthStatusUseCase: _checkAuthStatusUseCase,
    );
  }

  /// Get repository instance (for direct use if needed)
  static AuthRepository getRepository() => _repository;
}
