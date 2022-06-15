import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/user_preferences.dart';
import 'package:kutumba/utils/app_url.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Map<String, dynamic> loginData = {
      'log_name': email,
      'log_pwd': password
    };

    var url = Uri.parse(AppUrl.login);

    return await post(url, body: json.encode(loginData), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }).then(onValue).catchError(onError);
  }

  Future<Map<String, dynamic>> register(
      String firstName,
      String address,
      String email,
      String password,
      String passwordConfirmation,
      String referralCode) async {
    final Map<String, dynamic> registrationData = {
      'name': firstName,
      'address': address,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'referral_code': referralCode,
    };

    var url = Uri.parse(AppUrl.register);

    return await post(url, body: json.encode(registrationData), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }).then(onValue).catchError(onError);
  }

  Future<Map<String, dynamic>> logout() async {
    Map<String, Object> result;

    String token = await UserPreferences().getToken();

    var url = Uri.parse(AppUrl.logout);
    Response response = await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      await UserService().unsubscribe();

      UserPreferences().removeUser();

      _isAuthenticated = false;
      notifyListeners();
      result = {
        'status':
            (responseData['status'] == '1' || responseData['status'] == 1),
        'message': responseData['message']
      };
    } else if (response.statusCode == 402 || response.statusCode == 401) {
      await UserService().unsubscribe();
      UserPreferences().removeUser();
      _isAuthenticated = false;
      notifyListeners();

      result = {'status': true, 'message': 'Logout Successful'};
    } else {
      result = {'status': false, 'message': 'Something went wrong.'};
    }
    return result;
  }

  Future<User> autoLogin() async {
    User user = await UserPreferences().getUser();

    if (user == null) {
      return null;
    }

    // if(user.expiresAt != null && DateTime.now().isAfter(DateTime.parse(user.expiresAt))){
    //   await logout();
    //   return null;
    // }

    Map result = await refresh(user);

    if (result['status']) {
      user = result['data'];
      _isAuthenticated = true;
      notifyListeners();
    } else {
      if (result['forceLogout']) {
        await UserService().unsubscribe();
        UserPreferences().removeUser();
        return null;
      }
    }

    return user;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    Map<String, dynamic> result;

    final Map<String, dynamic> data = {
      'email': email,
    };

    var url = Uri.parse(AppUrl.forgotPassword);

    return await post(url, body: json.encode(data), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message']
        };
      } else {
        result = {'status': false, 'message': responseData['message']};
      }
      return result;
    }).catchError(onError);
  }

  Future<Map<String, dynamic>> refresh(User user,
      {bool allowRefreshToken = true}) async {
    var url = Uri.parse(AppUrl.refresh);
    Map<String, Object> result;

    Response response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + user.token
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      user.userId = responseData['response']['session_id'];
      user.username = responseData['response']['username'];
      user.email = responseData['response']['email'];

      await UserPreferences().saveUser(user);

      result = {
        'status':
            (responseData['status'] == '1' || responseData['status'] == 1),
        'data': user
      };
    } else if (response.statusCode == 500 ||
        response.statusCode == 401 ||
        response.statusCode == 402) {
      if (allowRefreshToken) {
        Map statusResult = await refreshToken();
        if (statusResult['status']) {
          user.token = statusResult['data'];
          return await refresh(user, allowRefreshToken: false);
        }
      }

      result = {'status': false, 'forceLogout': true};
    } else {
      result = {'status': false, 'forceLogout': false};
    }
    return result;
  }

  Future<Map<String, dynamic>> refreshToken() async {
    String token = await UserPreferences().getToken();

    var url = Uri.parse(AppUrl.refreshToken);
    Map<String, dynamic> result;

    Response response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
      },
    );
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      String newToken = responseData['response']['refresh'];

      await UserPreferences().saveData('token', newToken);

      result = {
        'status': (responseData['status'] == 200 ||
            responseData['status'] == '1' ||
            responseData['status'] == 1),
        'data': newToken
      };
    } else {
      await UserService().unsubscribe();
      UserPreferences().removeUser();
      _isAuthenticated = false;
      notifyListeners();

      result = {'status': false, 'message': responseData['message']};
    }
    return result;
  }

  Future<FutureOr> onValue(Response response) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var userData = {
        'id': responseData['response']['session_id'],
        'username': responseData['response']['username'],
        'email': responseData['response']['email'],
        'api_token': responseData['api_token'],
        'expires_at': responseData['expires_at'],
      };

      User authUser = User.fromJson(userData);

      await UserService().subscribe(responseData['api_token']);
      await UserPreferences().saveUser(authUser);

      _isAuthenticated = true;

      notifyListeners();

      result = {
        'status':
            (responseData['status'] == '1' || responseData['status'] == 1),
        'message': responseData['message'],
        'user': authUser
      };
    } else {
      result = {'status': false, 'message': responseData['message']};
    }
    return result;
  }

  static onError(error) {
    // print("the error is $error.detail");
    return {'status': false, 'message': 'Something went wrong!', 'data': error};
  }
}
