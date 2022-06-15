import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    // User user = Provider.of<UserProvider>(context).user;
    // bool isAuthenticated  = Provider.of<AuthProvider>(context).isAuthenticated;

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    onLogin() async {
      setState(() => error = '');

      if (_formKey.currentState.validate()) {
        setState(() => loading = true);

        final Future<Map<String, dynamic>> successfulMessage =
            auth.login(email, password);

        successfulMessage.then((response) {
          if (response['status']) {
            User user = response['user'];

            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/albums', (Route<dynamic> route) => false);

            Alert.successSnackbar(context, response['message']);
          } else {
            setState(() {
              error = response['message'].toString();
              loading = false;
            });
          }
        }).catchError((e) {
          Alert.errorSnackbar(context, 'Something went wrong!');
          setState(() {
            loading = false;
          });
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // endDrawer: MainDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        // Here we take the value from the MyAlbumsPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val.isEmpty) return 'Email address is required';

                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val)) return 'Must be a valid email address';

                    return null;
                  },
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.person),
                    labelText: 'Email Address',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val.isEmpty) return 'Password is required';

                    if (val.length < 6) return 'Must be at least 6 characters';

                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 30),
                loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : MaterialButton(
                        onPressed: () {
                          onLogin();
                        },
                        minWidth: double.infinity,
                        height: 45,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(letterSpacing: 1.5),
                        ),
                      ),
                TextButton(
                  child: const Text('Forgot Password ?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 162, 162, 162),
                      )),
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
