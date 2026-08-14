import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  Future<void> onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      error = '';
      loading = true;
    });

    try {
      final AuthProvider auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final Map<String, dynamic> response =
      await auth.login(email, password);

      if (!mounted) {
        return;
      }

      if (response['status'] == true) {
        final User user = response['user'] as User;

        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(user);

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/albums',
              (Route<dynamic> route) => false,
        );

        Alert.successSnackbar(
          context,
          response['message']?.toString() ?? 'Login successful!',
        );
      } else {
        setState(() {
          error = response['message']?.toString() ??
              'Invalid email or password.';
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Login error: $e');

      if (!mounted) {
        return;
      }

      Alert.errorSnackbar(
        context,
        'Something went wrong!',
      );

      setState(() {
        loading = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    final String emailValue = value?.trim() ?? '';

    if (emailValue.isEmpty) {
      return 'Email address is required';
    }

    final bool isValidEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
      r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]"
      r"(?:[a-zA-Z0-9-]{0,61}"
      r"[a-zA-Z0-9])?)+$",
    ).hasMatch(emailValue);

    if (!isValidEmail) {
      return 'Must be a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String passwordValue = value ?? '';

    if (passwordValue.isEmpty) {
      return 'Password is required';
    }

    if (passwordValue.length < 6) {
      return 'Must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                if (error.isNotEmpty)
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),

                if (error.isNotEmpty)
                  const SizedBox(height: 15),

                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  onChanged: (String value) {
                    setState(() {
                      email = value;

                      if (error.isNotEmpty) {
                        error = '';
                      }
                    });
                  },
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.person),
                    labelText: 'Email Address',
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  onChanged: (String value) {
                    setState(() {
                      password = value;

                      if (error.isNotEmpty) {
                        error = '';
                      }
                    });
                  },
                  onFieldSubmitted: (_) {
                    if (!loading) {
                      onLogin();
                    }
                  },
                  validator: _validatePassword,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                ),

                const SizedBox(height: 30),

                if (loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: MaterialButton(
                      onPressed: onLogin,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/forgot-password',
                    );
                  },
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: Color.fromARGB(
                        255,
                        162,
                        162,
                        162,
                      ),
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