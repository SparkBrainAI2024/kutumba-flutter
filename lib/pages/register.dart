import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  String firstName = '';
  String address = '---';
  String email = '';
  String password = '';
  String passwordConfirmation = '';
  String referralCode = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    onRegister() async {
      setState(() => error = '');

      if (_formKey.currentState.validate()) {
        setState(() => loading = true);

        final Future<Map<String, dynamic>> successfulMessage = auth.register(
            firstName,
            address,
            email,
            password,
            passwordConfirmation,
            referralCode);

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
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          children: [
            const Text(
              "Sign up for Kutumba's Paid all Digital Albums",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            if (error.isNotEmpty) const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (val) {
                          setState(() => firstName = val);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) =>
                            val.isEmpty ? 'First Name is required' : null,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.person),
                          labelText: 'Your Name',
                        ),
                      ),
                      // SizedBox(height: 5),
                      // TextFormField(
                      //   onChanged: (val) {
                      //     setState(() => address = val);
                      //   },
                      //   autovalidateMode: AutovalidateMode.onUserInteraction,
                      //   validator: (val) => val.isEmpty ? 'Address is required' : null,
                      //   decoration: InputDecoration(
                      //     suffixIcon: Icon(Icons.location_on),
                      //     labelText: 'Your Address',
                      //   ),
                      // ),
                      const SizedBox(height: 5),
                      TextFormField(
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val.isEmpty) return 'Email address is required';

                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val)) {
                            return 'Must be a valid email address';
                          }

                          return null;
                        },
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.email),
                          labelText: 'Your E-mail',
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val.isEmpty) return 'Password is required';

                          if (val.length < 6) {
                            return 'Must be at least 6 characters';
                          }

                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.vpn_key),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        onChanged: (val) {
                          setState(() => passwordConfirmation = val);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          suffixIcon: Icon(Icons.vpn_key),
                          labelText: 'Confirm Password',
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        onChanged: (val) {
                          setState(() => referralCode = val);
                        },
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.card_membership),
                          labelText: 'Referral Code (Optional)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : MaterialButton(
                              onPressed: () {
                                onRegister();
                              },
                              minWidth: double.infinity,
                              height: 45,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              textColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(letterSpacing: 1.5),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
