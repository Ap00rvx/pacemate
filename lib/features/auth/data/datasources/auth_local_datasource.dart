import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for storing authentication tokens and user data
class AuthLocalDataSource {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  final _logger = Logger();

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    _logger.f('Access token saved');
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
    _logger.f('Refresh token saved');
  }

  /// Save both tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _logger.f('Both tokens saved');
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _logger.f('Access token retrieved');
    return prefs.getString(_accessTokenKey);
    
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    _logger.f('Refresh token retrieved');
    return prefs.getString(_refreshTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    _logger.f('User ID saved');
    await prefs.setString(_userIdKey, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _logger.f('User ID retrieved');
    return prefs.getString(_userIdKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    _logger.f('All stored data cleared');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Check if user has stored tokens
  Future<bool> hasTokens() async {
    _logger.f('Checking for stored tokens');
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    return accessToken != null && refreshToken != null;
  }
}
