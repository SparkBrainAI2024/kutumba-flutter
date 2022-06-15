import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

import './components/nav_items.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  User user;
  bool isAuthenticated;

  @override
  void initState() {
    super.initState();
  }

  Map styles = {
    'nav_item_text': {'fontSize': 16}
  };

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    user = Provider.of<UserProvider>(context).user;

    onLogout() async {
      // Navigator.pop(context);
      final Future<Map<String, dynamic>> successfulMessage = auth.logout();

      successfulMessage.then((response) {
        if (response['status']) {
          Provider.of<UserProvider>(context, listen: false).setUser(null);
          Navigator.pushReplacementNamed(context, '/home');
          // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

          Alert.successSnackbar(context, response['message']);
        } else {
          Alert.errorSnackbar(context, response['message']);
        }
      }).catchError((e) {
        Alert.errorSnackbar(context, 'Something went wrong!');
      });
    }

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        decoration: const BoxDecoration(color: Colors.black12),
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              child: user == null
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/avatar.png',
                          height: 80,
                          width: 80,
                        ),
                        Text(user.username ?? "",
                            style: const TextStyle(fontSize: 17))
                      ],
                    ),
              decoration: const BoxDecoration(
                color: Colors.black38,
              ),
            ),
            Column(
              children: [
                ListTile(
                  title: NavItem('Home', Icons.home),
                  onTap: () {
                    // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    Navigator.of(context).pushReplacementNamed('/home');
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: NavItem('Albums', Icons.album),
                  onTap: () {
                    // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    Navigator.of(context).pushReplacementNamed('/albums');
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: NavItem('Videos', Icons.video_library),
                  onTap: () {
                    // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    Navigator.of(context).pushReplacementNamed('/videos');
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: NavItem('Profile', Icons.account_circle),
                  onTap: () {
                    // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    Navigator.of(context).pushReplacementNamed('/profile');
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: NavItem('Notes', Icons.notes),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/notes');
                  },
                ),
                ListTile(
                  title: NavItem('Log Out', Icons.login),
                  onTap: () {
                    onLogout();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
