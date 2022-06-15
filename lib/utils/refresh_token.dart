import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RefreshToken {
  static refresh(BuildContext context) async {
    AuthProvider _auth = AuthProvider();
    Map statusResult = await _auth.refreshToken();
    if (statusResult['status']) {
      return statusResult;
    } else {
      Provider.of<UserProvider>(context, listen: false).setUser(null);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      Navigator.of(context).pushNamed('/login');
      Alert.errorSnackbar(context, statusResult['message']);
    }
  }

  static logout(BuildContext context, String message) async {
    AuthProvider _auth = AuthProvider();
    Map statusResult = await _auth.logout();
    if (statusResult['status']) {
      Provider.of<UserProvider>(context, listen: false).setUser(null);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      Navigator.of(context).pushNamed('/login');

      Alert.errorSnackbar(context, message ?? statusResult['message']);
    } else {
      Alert.errorSnackbar(context, statusResult['message']);
    }
  }
}
