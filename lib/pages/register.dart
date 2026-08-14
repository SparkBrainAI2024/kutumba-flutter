import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String firstName = '';
  String address = '---';
  String email = '';
  String password = '';
  String passwordConfirmation = '';
  String referralCode = '';

  String error = '';
  bool loading = false;

  Future<void> onRegister() async {
    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final AuthProvider auth =
      Provider.of<AuthProvider>(context, listen: false);

      final Map<String, dynamic> response = await auth.register(
        firstName.trim(),
        address.trim(),
        email.trim(),
        password,
        passwordConfirmation,
        referralCode.trim(),
      );

      if (!mounted) {
        return;
      }

      if (response['status'] == true) {
        final User user = response['user'];

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
          response['message']?.toString() ?? 'Registration successful',
        );
      } else {
        setState(() {
          error = response['message']?.toString() ??
              'Unable to create your account.';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      Alert.errorSnackbar(
        context,
        'Something went wrong. Please try again.',
      );

      setState(() {
        loading = false;
      });
    }
  }

  String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  String? validateEmail(String value) {
    final String emailValue = value.trim();

    if (emailValue.isEmpty) {
      return 'Email address is required';
    }

    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );

    if (!emailRegex.hasMatch(emailValue)) {
      return 'Must be a valid email address';
    }

    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Must be at least 6 characters';
    }

    return null;
  }

  String? validatePasswordConfirmation(String value) {
    if (value.isEmpty) {
      return 'Confirm Password is required';
    }

    if (value.length < 6) {
      return 'Must be at least 6 characters';
    }

    if (value != password) {
      return 'Password and confirm password do not match';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
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
                const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            firstName = value;
                          },
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            return validateName(value ?? '');
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.person),
                            labelText: 'Your Name',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Email
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          onChanged: (value) {
                            email = value;
                          },
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            return validateEmail(value ?? '');
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.email),
                            labelText: 'Your E-mail',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Password
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            return validatePassword(value ?? '');
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.vpn_key),
                            labelText: 'Password',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Confirm Password
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          onChanged: (value) {
                            passwordConfirmation = value;
                          },
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            return validatePasswordConfirmation(
                              value ?? '',
                            );
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.vpn_key),
                            labelText: 'Confirm Password',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Referral Code
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            referralCode = value;
                          },
                          onFieldSubmitted: (_) {
                            if (!loading) {
                              onRegister();
                            }
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.card_membership),
                            labelText: 'Referral Code (Optional)',
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Register button
                        loading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: MaterialButton(
                            onPressed: onRegister,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(5.0),
                            ),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}