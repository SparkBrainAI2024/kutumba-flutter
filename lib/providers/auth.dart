import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/user_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login(
      String email, String password) async {
    final Map<String, dynamic> loginData = {
      'log_name': email.trim(),
      'log_pwd': password,
    };

    try {
      final Uri url = Uri.parse(AppUrl.login);

      final Response response = await post(
        url,
        body: json.encode(loginData),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return await onValue(response);
    } catch (e) {
      return onError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> register(
      String firstName,
      String address,
      String email,
      String password,
      String passwordConfirmation,
      String referralCode,
      ) async {
    final Map<String, dynamic> registrationData = {
      'name': firstName.trim(),
      'address': address.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      'referral_code': referralCode.trim(),
    };

    try {
      final Uri url = Uri.parse(AppUrl.register);

      final Response response = await post(
        url,
        body: json.encode(registrationData),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return await onValue(response);
    } catch (e) {
      return onError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> logout() async {
    try {
      final String? token = await UserPreferences().getToken();

      final Uri url = Uri.parse(AppUrl.logout);

      final Response response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> responseData = {};

      try {
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body);
        }
      } catch (_) {
        responseData = {};
      }

      if (response.statusCode == 200) {
        await _clearSession();

        return {
          'status': responseData['status'] == '1' ||
              responseData['status'] == 1 ||
              responseData['status'] == true,
          'message':
          responseData['message'] ?? 'Logout Successful',
        };
      }

      // Token already expired.
      if (response.statusCode == 401 ||
          response.statusCode == 402) {
        await _clearSession();

        return {
          'status': true,
          'message': 'Logout Successful',
        };
      }

      return {
        'status': false,
        'message':
        responseData['message'] ?? 'Something went wrong.',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Something went wrong.',
        'data': e,
      };
    }
  }

  // ---------------------------------------------------------------------------
  // AUTO LOGIN
  // ---------------------------------------------------------------------------

  Future<User?> autoLogin() async {
    try {
      User? user = await UserPreferences().getUser();

      if (user == null) {
        _isAuthenticated = false;
        return null;
      }

      final Map<String, dynamic> result = await refresh(user);

      if (result['status'] == true) {
        User refreshedUser = result['data'];

        _isAuthenticated = true;
        notifyListeners();

        return refreshedUser;
      }

      if (result['forceLogout'] == true) {
        await _clearSession();
      }

      return null;
    } catch (e) {
      _isAuthenticated = false;
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final Map<String, dynamic> data = {
      'email': email.trim(),
    };

    try {
      final Uri url = Uri.parse(AppUrl.forgotPassword);

      final Response response = await post(
        url,
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Map<String, dynamic> responseData = {};

      try {
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body);
        }
      } catch (_) {}

      if (response.statusCode == 200) {
        return {
          'status': responseData['status'] == '1' ||
              responseData['status'] == 1 ||
              responseData['status'] == true,
          'message':
          responseData['message'] ?? 'Request successful.',
        };
      }

      return {
        'status': false,
        'message':
        responseData['message'] ?? 'Something went wrong.',
      };
    } catch (e) {
      return onError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH USER SESSION
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> refresh(
      User user, {
        bool allowRefreshToken = true,
      }) async {
    try {
      final Uri url = Uri.parse(AppUrl.refresh);

      final Response response = await get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      Map<String, dynamic> responseData = {};

      try {
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body);
        }
      } catch (_) {
        return {
          'status': false,
          'forceLogout': true,
          'message': 'Invalid server response.',
        };
      }

      if (response.statusCode == 200) {
        final responseBody = responseData['response'];

        if (responseBody != null) {
          user.userId = responseBody['session_id'];
          user.username = responseBody['username'];
          user.email = responseBody['email'];
        }

        await UserPreferences().saveUser(user);

        _isAuthenticated = true;
        notifyListeners();

        return {
          'status': responseData['status'] == '1' ||
              responseData['status'] == 1 ||
              responseData['status'] == true,
          'data': user,
        };
      }

      // Access token expired.
      if (response.statusCode == 401 ||
          response.statusCode == 402 ||
          response.statusCode == 500) {
        if (allowRefreshToken) {
          final Map<String, dynamic> refreshResponse =
          await refreshToken();

          if (refreshResponse['status'] == true) {
            final String newToken = refreshResponse['data'];

            user.token = newToken;

            return await refresh(
              user,
              allowRefreshToken: false,
            );
          }
        }

        return {
          'status': false,
          'forceLogout': true,
          'message':
          responseData['message'] ?? 'Session expired.',
        };
      }

      return {
        'status': false,
        'forceLogout': false,
        'message':
        responseData['message'] ?? 'Something went wrong.',
      };
    } catch (e) {
      return {
        'status': false,
        'forceLogout': false,
        'message': 'Something went wrong.',
        'data': e,
      };
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH TOKEN
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final String? token = await UserPreferences().getToken();

      if (token == null || token.isEmpty) {
        await _clearSession();

        return {
          'status': false,
          'message': 'Session expired.',
        };
      }

      final Uri url = Uri.parse(AppUrl.refreshToken);

      final Response response = await get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> responseData = {};

      try {
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body);
        }
      } catch (_) {
        await _clearSession();

        return {
          'status': false,
          'message': 'Invalid server response.',
        };
      }

      if (response.statusCode == 200) {
        final responseBody = responseData['response'];

        final String? newToken =
        responseBody != null
            ? responseBody['refresh']?.toString()
            : null;

        if (newToken == null || newToken.isEmpty) {
          return {
            'status': false,
            'message': 'Unable to refresh session.',
          };
        }

        await UserPreferences().saveData(
          'token',
          newToken,
        );

        return {
          'status': responseData['status'] == 200 ||
              responseData['status'] == '200' ||
              responseData['status'] == '1' ||
              responseData['status'] == 1 ||
              responseData['status'] == true,
          'data': newToken,
        };
      }

      await _clearSession();

      return {
        'status': false,
        'message':
        responseData['message'] ?? 'Session expired.',
      };
    } catch (e) {
      await _clearSession();

      return {
        'status': false,
        'message': 'Something went wrong.',
        'data': e,
      };
    }
  }

  // ---------------------------------------------------------------------------
  // COMMON LOGIN / REGISTER RESPONSE
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> onValue(Response response) async {
    Map<String, dynamic> responseData = {};

    try {
      if (response.body.isNotEmpty) {
        responseData = json.decode(response.body);
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Invalid server response.',
        'data': e,
      };
    }

    if (response.statusCode == 200) {
      final responseBody = responseData['response'];

      if (responseBody == null) {
        return {
          'status': false,
          'message': 'Invalid server response.',
        };
      }

      final Map<String, dynamic> userData = {
        'id': responseBody['session_id'],
        'username': responseBody['username'],
        'email': responseBody['email'],
        'api_token': responseData['api_token'],
        'expires_at': responseData['expires_at'],
      };

      final User authUser = User.fromJson(userData);

      final String? apiToken =
      responseData['api_token']?.toString();

      if (apiToken != null && apiToken.isNotEmpty) {
        await UserService().subscribe(apiToken);
      }

      await UserPreferences().saveUser(authUser);

      _isAuthenticated = true;
      notifyListeners();

      return {
        'status': responseData['status'] == '1' ||
            responseData['status'] == 1 ||
            responseData['status'] == true,
        'message':
        responseData['message'] ?? 'Successful.',
        'user': authUser,
      };
    }

    return {
      'status': false,
      'message':
      responseData['message'] ?? 'Something went wrong.',
    };
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLER
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> onError(dynamic error) {
    return {
      'status': false,
      'message': 'Something went wrong!',
      'data': error,
    };
  }

  // ---------------------------------------------------------------------------
  // CLEAR SESSION
  // ---------------------------------------------------------------------------

  Future<void> _clearSession() async {
    try {
      await UserService().unsubscribe();
    } catch (_) {}

    await UserPreferences().removeUser();

    _isAuthenticated = false;
    notifyListeners();
  }
}