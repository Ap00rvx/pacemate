import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pacemate/features/profile/domain/model/profle_model.dart';
import '../../domain/entities/auth_requests.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/model/user_model.dart';

part 'auth_events.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final GoogleCheckUseCase _googleCheckUseCase;
  final GoogleSignupUseCase _googleSignupUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final CheckEmailExistsUseCase _checkEmailExistsUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required GoogleCheckUseCase googleCheckUseCase,
    required GoogleSignupUseCase googleSignupUseCase,
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required CheckEmailExistsUseCase checkEmailExistsUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _signupUseCase = signupUseCase,
       _googleCheckUseCase = googleCheckUseCase,
       _googleSignupUseCase = googleSignupUseCase,
       _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _checkEmailExistsUseCase = checkEmailExistsUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(const AuthState()) {
    on<InitialAuthEvent>(_onInitialAuthEvent);
    on<LoginEvent>(_onLoginEvent);
    on<SignupEvent>(_onSignupEvent);
    on<GoogleCheckEvent>(_onGoogleCheckEvent);
    on<GoogleSignupEvent>(_onGoogleSignupEvent);
    on<GetProfileEvent>(_onGetProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<CheckEmailExistsEvent>(_onCheckEmailExistsEvent);
    on<RefreshTokenEvent>(_onRefreshTokenEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<ClearErrorEvent>(_onClearErrorEvent);
  }

  /// Check initial auth status
  Future<void> _onInitialAuthEvent(
    InitialAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final isAuthenticated = await _checkAuthStatusUseCase(const NoParams());

      if (isAuthenticated) {
        // Try to get user profile
        final profileResponse = await _getProfileUseCase(const NoParams());
        if (profileResponse.success && profileResponse.user != null) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              profile: profileResponse.user,
            ),
          );
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: 'Authentication check failed',
        ),
      );
    }
  }

  /// Login user
  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );
      final response = await _loginUseCase(request);

      if (response.success && response.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: response.user,
            message: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Login failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Sign up user
  Future<void> _onSignupEvent(
    SignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final request = SignupRequest(
        fullname: event.fullname,
        email: event.email,
        password: event.password,
        dob: event.dob,
        gender: event.gender,
        age: event.age,
        height: event.height,
        weight: event.weight,
        location: event.location,
        avatar: event.avatar,
      );

      final response = await _signupUseCase(request);

      if (response.success && response.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: response.user,
            message: response.message,
            isNewUser: true,
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Signup failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Google check - Step 1 of Google authentication
  Future<void> _onGoogleCheckEvent(
    GoogleCheckEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final request = GoogleCheckRequest(
        googleId: event.googleId,
        email: event.email,
      );

      final response = await _googleCheckUseCase(request);

      if (response.success) {
        if (response.userExists && response.user != null) {
          // User exists, login successful
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              message: response.message,
            ),
          );
        } else {
          // User doesn't exist, need to proceed to signup
          emit(
            state.copyWith(
              status: AuthStatus.googleSignupRequired,
              message: response.message,
              googleSignupData: GoogleSignupData(
                email: response.email ?? event.email,
                googleId: response.googleId ?? event.googleId,
              ),
            ),
          );
        }
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Google authentication failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Google signup - Step 2 of Google authentication
  Future<void> _onGoogleSignupEvent(
    GoogleSignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final request = GoogleSignupRequest(
        googleId: event.googleId,
        email: event.email,
        fullname: event.fullname,
        avatar: event.avatar,
        dob: event.dob,
        gender: event.gender,
        age: event.age,
        height: event.height,
        weight: event.weight,
        location: event.location,
      );

      final response = await _googleSignupUseCase(request);

      if (response.success && response.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: response.user,
            message: response.message,
            isNewUser: response.isNewUser ?? true,
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Google signup failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Get user profile
  Future<void> _onGetProfileEvent(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await _getProfileUseCase(const NoParams());

      if (response.success && response.user != null) {
        emit(state.copyWith(message: response.message,profile: response.user));
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Failed to get profile: ${e.toString()}',
        ),
      );
    }
  }

  /// Update user profile
  Future<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final request = UpdateProfileRequest(
        fullname: event.fullname,
        location: event.location,
        avatar: event.avatar,
        dob: event.dob,
        gender: event.gender,
        age: event.age,
        height: event.height,
        weight: event.weight,
      );

      final response = await _updateProfileUseCase(request);

      if (response.success && response.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            profile: response.user,
            message: 'Profile updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.error, message: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Profile update failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Check if email exists
  Future<void> _onCheckEmailExistsEvent(
    CheckEmailExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _checkEmailExistsUseCase(event.email);

      emit(
        state.copyWith(emailExists: response.exists, message: response.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Email check failed: ${e.toString()}',
        ),
      );
    } finally {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  /// Refresh access token
  Future<void> _onRefreshTokenEvent(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final request = RefreshTokenRequest(refreshToken: event.refreshToken);
      final response = await _refreshTokenUseCase(request);

      if (!response.success) {
        // If refresh failed, logout user
        add(const LogoutEvent());
      }
    } catch (e) {
      // If refresh failed, logout user
      add(const LogoutEvent());
    }
  }

  /// Logout user
  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logoutUseCase(const NoParams());
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          message: 'Logged out successfully',
          googleSignupData: null,
          emailExists: null,
          isNewUser: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          message: 'Logout failed: ${e.toString()}',
          googleSignupData: null,
          emailExists: null,
          isNewUser: false,
        ),
      );
    }
  }

  /// Clear error state
  void _onClearErrorEvent(ClearErrorEvent event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.error) {
      emit(
        state.copyWith(
          status: state.user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          message: null,
        ),
      );
    }
  }
}
