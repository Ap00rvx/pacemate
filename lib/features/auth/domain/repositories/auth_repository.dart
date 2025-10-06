import '../entities/auth_requests.dart';
import '../entities/auth_responses.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request);

  /// Sign up new user
  Future<AuthResponse> signup(SignupRequest request);

  /// Google check - Step 1: Check if user exists
  Future<GoogleCheckResponse> googleCheck(GoogleCheckRequest request);

  /// Google signup - Step 2: Create new user with Google credentials
  Future<AuthResponse> googleSignup(GoogleSignupRequest request);

  /// Get user profile
  Future<ProfileResponse> getProfile();

  /// Update user profile
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request);

  /// Check if email exists
  Future<EmailCheckResponse> checkEmailExists(String email);

  /// Refresh access token
  Future<TokenResponse> refreshToken(RefreshTokenRequest request);

  /// Logout user (clear local tokens)
  Future<void> logout();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Save tokens locally
  Future<void> saveTokens(String accessToken, String refreshToken);

  /// Clear stored tokens
  Future<void> clearTokens();

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated();
}
