import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // Keys to store user data in SharedPreferences
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUsername = 'username';
  static const _keyEmail = 'email';
  static const _keyUserId = 'userId';

  // Save login state
  static Future<void> setLoggedIn(bool isLoggedIn, {String? username, String? email, int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (username != null) prefs.setString(_keyUsername, username);
    if (email != null) prefs.setString(_keyEmail, email);
    if (userId != null) prefs.setInt(_keyUserId, userId);
  }

  // Get login state
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get user data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final email = prefs.getString(_keyEmail);
    final userId = prefs.getInt(_keyUserId);

    return {
      'username': username ?? '',
      'email': email ?? '',
      'userId': userId ?? -1,
    };
  }

  // Clear user data (logout)
  static Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_keyIsLoggedIn);
    prefs.remove(_keyUsername);
    prefs.remove(_keyEmail);
    prefs.remove(_keyUserId);
  }
}
