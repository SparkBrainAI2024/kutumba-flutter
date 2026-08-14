import 'dart:convert';

import 'package:kutumba/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _userKey = 'user';

  // ---------------------------------------------------------------------------
  // SAVE USER
  // ---------------------------------------------------------------------------

  Future<void> saveUser(User user) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE INDIVIDUAL DATA
  // ---------------------------------------------------------------------------

  Future<void> saveData(String key, String value) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(key, value);
  }

  // ---------------------------------------------------------------------------
  // GET USER
  // ---------------------------------------------------------------------------

  Future<User?> getUser() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final String? userJson = prefs.getString(_userKey);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> json =
      jsonDecode(userJson);

      return User.fromJson(json);
    } catch (e) {
      // Invalid/corrupted user data.
      await removeUser();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // GET TOKEN
  // ---------------------------------------------------------------------------

  Future<String?> getToken() async {
    final User? user = await getUser();

    if (user == null) {
      return null;
    }

    if (user.token!.isEmpty) {
      return null;
    }

    return user.token;
  }

  // ---------------------------------------------------------------------------
  // UPDATE TOKEN
  // ---------------------------------------------------------------------------

  Future<void> updateToken(String token) async {
    final User? user = await getUser();

    if (user == null) {
      return;
    }

    user.token = token;

    await saveUser(user);
  }

  // ---------------------------------------------------------------------------
  // REMOVE USER
  // ---------------------------------------------------------------------------

  Future<void> removeUser() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(_userKey);

    // Remove old keys as well.
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('address');
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('expiresAt');
  }

  // ---------------------------------------------------------------------------
  // CHECK LOGIN
  // ---------------------------------------------------------------------------

  Future<bool> isLoggedIn() async {
    final User? user = await getUser();

    return user != null && user.token!.isNotEmpty;
  }
}