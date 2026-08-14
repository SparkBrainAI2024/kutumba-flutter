import 'package:flutter/material.dart';
import 'package:kutumba/components/version_check.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/pages/home.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  void autoLogin() async {
    User? user = await AuthProvider().autoLogin();
    Provider.of<UserProvider>(context, listen: false).setUser(user);
  }

  versionCheck() async {
    VersionCheck.checkLatestVersion(context);
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
    versionCheck();
  }

  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}
