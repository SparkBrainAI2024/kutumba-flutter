import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/date_formater.dart';
import 'package:kutumba/utils/refresh_token.dart';

import './../main_drawer.dart';
import './../components/header_logo.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  final UserService _api = UserService();
  User user;
  String oldPassword;
  String password;
  String passwordConfirmation;
  String name;
  String address;
  String error = '';
  bool loading = true;
  bool profileSubmitting = false;
  bool passwordSubmitting = false;
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    getUserData();
  }

  getUserData() async {
    Map jsonResult = await _api.fetchProfile();

    if (jsonResult['status']) {
      user = jsonResult['data'];
      name = user.name;
      address = user.address;
      setState(() {
        loading = false;
      });
    } else {
      if (jsonResult['statusCode'] != null &&
          (jsonResult['statusCode'] == 402 ||
              jsonResult['statusCode'] == 401)) {
        Map refreshResponse = await RefreshToken.refresh(context);
        if (refreshResponse != null) {
          getUserData();
        }

        return;
      } else if (jsonResult['statusCode'] != null &&
          (jsonResult['statusCode'] == 409)) {
        await RefreshToken.logout(context, jsonResult['message']);
        return;
      }

      Alert.errorSnackbar(context, jsonResult['message']);
    }
  }

  onUpdateProfile() async {
    if (_profileFormKey.currentState.validate()) {
      setState(() {
        profileSubmitting = true;
      });

      Map jsonResult = await _api.editProfile(name, address);

      if (jsonResult['status']) {
        user.name = name;
        user.address = address;

        // User authUser = Provider.of<UserProvider>(context).user;
        // user.username = name;
        // Provider.of<UserProvider>(context, listen: false).setUser(user);

        Alert.successSnackbar(context, jsonResult['message']);
      } else {
        if (jsonResult['statusCode'] != null &&
            (jsonResult['statusCode'] == 402 ||
                jsonResult['statusCode'] == 401)) {
          Map refreshResponse = await RefreshToken.refresh(context);
          if (refreshResponse != null) {
            onUpdateProfile();
          }

          return;
        } else if (jsonResult['statusCode'] != null &&
            (jsonResult['statusCode'] == 409)) {
          await RefreshToken.logout(context, jsonResult['message']);
          return;
        }

        Alert.errorSnackbar(context, jsonResult['message']);
      }

      setState(() {
        profileSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void changePasswordDialog() {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              onChangePassword() async {
                setState(() => error = '');
                if (_passwordFormKey.currentState.validate()) {
                  setState(() {
                    passwordSubmitting = true;
                  });

                  Map jsonResult =
                      await _api.changePassword(oldPassword, password);

                  if (jsonResult['status']) {
                    Navigator.of(context).pop();
                    Alert.successSnackbar(context, jsonResult['message']);
                  } else {
                    setState(() {
                      error = jsonResult['message'].toString();
                    });
                  }

                  setState(() {
                    passwordSubmitting = false;
                  });
                }
              }

              return AlertDialog(
                  title: const Text('Change Password'),
                  // contentPadding: EdgeInsets.all(20),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          if (error.isNotEmpty)
                            Text(
                              error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          if (error.isNotEmpty) const SizedBox(height: 15),
                          TextFormField(
                            onChanged: (val) {
                              setState(() => oldPassword = val);
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) {
                              if (val.isEmpty) return 'Current is required';

                              if (val.length < 6) {
                                return 'Must be at least 6 characters';
                              }

                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              labelText: 'Current Password',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) {
                              if (val.isEmpty) return 'Password is required';

                              if (val.length < 6) {
                                return 'Must be at least 6 characters';
                              }

                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              labelText: 'New Password',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            onChanged: (val) {
                              setState(() => passwordConfirmation = val);
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Confirm Password is required';
                              }

                              if (val.length < 6) {
                                return 'Must be at least 6 characters';
                              }

                              if (val != password) {
                                return 'Password and confirm password does not match';
                              }

                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              labelText: 'Confirm Password',
                            ),
                          ),
                          const SizedBox(height: 15),
                          passwordSubmitting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          onChangePassword();
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        textColor: Colors.white,
                                        color: Theme.of(context).primaryColor,
                                        child: const Text(
                                          'Change',
                                          style: TextStyle(letterSpacing: 1.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        // minWidth: double.infinity,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        textColor: Colors.white,
                                        color: Colors.black12,
                                        child: const Text(
                                          'Back',
                                          style: TextStyle(letterSpacing: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    ),
                  ));
            });
          });
    }

    return loading
        ? const Loader()
        : Scaffold(
            backgroundColor: Colors.black12,
            endDrawer: const MainDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.black12,
              title: const HeaderLogo(),
              centerTitle: false,
            ),
            body: Column(
              children: [
                if (user != null && (user.reminder || user.expired))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Color.fromARGB(255, 204, 50, 50),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Html(
                            data:
                                'Your subscription ${user.expired ? 'has expired' : 'will expire'} on <b>${DateFormater.dateParser(user.expiryDate)}</b>. Please renew your account.',
                            style: {
                              'html': Style(
                                textAlign: TextAlign.left,
                                color: const Color.fromARGB(255, 204, 50, 50),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(),
                                  const Text(
                                    'MY PROFILE',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      // fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 200, 200, 200),
                                    ),
                                  ),
                                  // Icon(
                                  //   Icons.person_add_alt_1,
                                  //   color: Color.fromARGB(255, 232, 122, 82),
                                  //   size: 18,
                                  // )
                                ],
                              ),
                              const Divider(),
                              Form(
                                key: _profileFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Name",
                                        style: TextStyle(
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 230, 230, 230))),
                                    TextFormField(
                                      onChanged: (val) {
                                        setState(() => name = val);
                                      },
                                      initialValue: user.name ?? '',
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (val) {
                                        if (val.isEmpty) {
                                          return 'Name is required';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          // suffixIcon: Icon(Icons.person),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15,
                                              color: Colors.white),
                                          hintText: 'Name'),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text("Address",
                                        style: TextStyle(
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 230, 230, 230))),
                                    TextFormField(
                                      onChanged: (val) {
                                        setState(() => address = val);
                                      },
                                      initialValue: user.address ?? '',
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (val) {
                                        if (val.isEmpty) {
                                          return 'Address is required';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          // border: const OutlineInputBorder(),
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15,
                                              color: Colors.white),
                                          hintText: 'Address'),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text("Email",
                                        style: TextStyle(
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 230, 230, 230))),
                                    TextField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          // border: const OutlineInputBorder(),
                                          hintStyle: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15,
                                              color: Colors.white),
                                          hintText: user.email ?? ''),
                                    ),
                                    const SizedBox(height: 10),
                                    profileSubmitting
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : MaterialButton(
                                            color:
                                                const Color.fromARGB(255, 33, 33, 33),
                                            onPressed: () {
                                              onUpdateProfile();
                                            },
                                            child: const Text("Save"),
                                          ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Password",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          height: 1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                              255, 230, 230, 230))),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      MaterialButton(
                                        color: const Color.fromARGB(255, 33, 33, 33),
                                        onPressed: () {
                                          changePasswordDialog();
                                        },
                                        child: const Text("Change Password"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Subscription",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          height: 1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                              255, 230, 230, 230))),
                                  const SizedBox(height: 10),
                                  Text(
                                      "Subscription till: " +
                                          (user.expiryDate.isEmpty
                                              ? '(Not Subscribed)'
                                              : DateFormater.dateParser(
                                                  user.expiryDate)),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          height: 1,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                              255, 230, 230, 230))),
                                  const SizedBox(height: 12),
                                  // Row(children: [
                                  //   MaterialButton(
                                  //     disabledColor: Color.fromARGB(255, 69, 68, 68),
                                  //     color: Color.fromARGB(255, 33, 33, 33),
                                  //     onPressed: (user.expired || user.reminder) ?
                                  //       () {
                                  //         Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment('renew', hasBackBtn: true, redirectPage: '/profile')));
                                  //       }
                                  //       : null,
                                  //     child: Text("Renew"),
                                  //   ),
                                  // ])
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
