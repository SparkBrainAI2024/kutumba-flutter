import 'package:kutumba/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("userId", user.userId);
    await prefs.setString("username", user.username);
    await prefs.setString("email", user.email);
    await prefs.setString("token", user.token);
    // await prefs.setString("expiresAt", user.expiresAt);
  }

  Future saveData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, value);
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString("userId");
    String name = prefs.getString("username");
    String email = prefs.getString("email");
    String token = prefs.getString("token");
    String expiresAt = prefs.getString("expiresAt");

    if (userId == null) return null;

    if (expiresAt != null &&
        DateTime.now().isAfter(DateTime.parse(expiresAt))) {
      return null;
    }

    return User(
        userId: userId,
        username: name,
        email: email,
        token: token,
        expiresAt: expiresAt);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("userId");
    await prefs.remove("username");
    await prefs.remove("email");
    await prefs.remove("token");
    await prefs.remove("expiresAt");
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String expiresAt = prefs.getString("expiresAt");

    if (expiresAt != null &&
        DateTime.now().isAfter(DateTime.parse(expiresAt))) {
      return null;
    }

    return token;
  }
}
