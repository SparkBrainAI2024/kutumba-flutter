import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    onForgotPassword() async {
      setState(() => error = '');

      if (_formKey.currentState.validate()) {
        setState(() => loading = true);

        final Future<Map<String, dynamic>> successfulMessage =
            auth.forgotPassword(email);

        successfulMessage.then((response) {
          if (response['status']) {
            Alert.successSnackbar(context, response['message']);

            setState(() {
              email = '';
              loading = false;
            });
            _formKey.currentState.reset();
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
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
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
                // Container(
                //   width: width*0.7,
                //   height: height*0.3,
                //   child: Image.asset(
                //     'assets/images/logo.png',
                //   ),
                // ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 10),
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
                        .hasMatch(val)) return 'Must be a valid email address';

                    return null;
                  },
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.email),
                    labelText: 'Your E-mail',
                  ),
                ),
                const SizedBox(height: 20),
                loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : MaterialButton(
                        onPressed: () {
                          onForgotPassword();
                        },
                        minWidth: double.infinity,
                        height: 45,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        child: const Text(
                          'SEND RESET LINK',
                          style: TextStyle(
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
