import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = '';
  String error = '';
  bool loading = false;

  Future<void> onForgotPassword() async {
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
      await auth.forgotPassword(email);

      if (!mounted) {
        return;
      }

      if (response['status'] == true) {
        Alert.successSnackbar(
          context,
          response['message']?.toString() ?? 'Reset link sent successfully.',
        );

        setState(() {
          email = '';
          loading = false;
        });

        _formKey.currentState!.reset();
      } else {
        setState(() {
          error = response['message']?.toString() ??
              'Unable to send reset link.';
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
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
                  const SizedBox(height: 10),

                TextFormField(
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
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
                  onFieldSubmitted: (_) {
                    if (!loading) {
                      onForgotPassword();
                    }
                  },
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.email),
                    labelText: 'Your E-mail',
                  ),
                ),

                const SizedBox(height: 20),

                if (loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: MaterialButton(
                      onPressed: onForgotPassword,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'SEND RESET LINK',
                        style: TextStyle(
                          letterSpacing: 1.5,
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