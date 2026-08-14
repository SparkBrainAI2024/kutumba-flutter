import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/date_formater.dart';
import 'package:kutumba/utils/refresh_token.dart';

import '../main_drawer.dart';
import '../components/header_logo.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserService _api = UserService();

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  User? user;

  String name = '';
  String address = '';

  String oldPassword = '';
  String password = '';
  String passwordConfirmation = '';

  String error = '';

  bool loading = true;
  bool profileSubmitting = false;
  bool passwordSubmitting = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final Map<String, dynamic> jsonResult = await _api.fetchProfile();

      if (!mounted) return;

      if (jsonResult['status'] == true) {
        user = jsonResult['data'] as User?;

        if (user != null) {
          name = user!.name ?? '';
          address = user!.address ?? '';
        }

        setState(() {
          loading = false;
        });
      } else {
        final int? statusCode = jsonResult['statusCode'] as int?;

        if (statusCode == 402 || statusCode == 401) {
          final Map<String, dynamic>? refreshResponse =
          await RefreshToken.refresh(context);

          if (!mounted) return;

          if (refreshResponse != null) {
            await getUserData();
          }

          return;
        }

        if (statusCode == 409) {
          await RefreshToken.logout(
            context,
            jsonResult['message']?.toString() ?? 'Session expired',
          );
          return;
        }

        setState(() {
          loading = false;
        });

        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ?? 'Unable to load profile.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Alert.errorSnackbar(
        context,
        'Something went wrong!',
      );
    }
  }

  Future<void> onUpdateProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      profileSubmitting = true;
    });

    try {
      final Map<String, dynamic> jsonResult =
      await _api.editProfile(name, address);

      if (!mounted) return;

      if (jsonResult['status'] == true) {
        if (user != null) {
          user!.name = name;
          user!.address = address;
        }

        Alert.successSnackbar(
          context,
          jsonResult['message']?.toString() ?? 'Profile updated successfully.',
        );
      } else {
        final int? statusCode = jsonResult['statusCode'] as int?;

        if (statusCode == 402 || statusCode == 401) {
          final Map<String, dynamic>? refreshResponse =
          await RefreshToken.refresh(context);

          if (!mounted) return;

          if (refreshResponse != null) {
            await onUpdateProfile();
          }

          return;
        }

        if (statusCode == 409) {
          await RefreshToken.logout(
            context,
            jsonResult['message']?.toString() ?? 'Session expired',
          );
          return;
        }

        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ?? 'Unable to update profile.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      Alert.errorSnackbar(
        context,
        'Something went wrong!',
      );
    } finally {
      if (mounted) {
        setState(() {
          profileSubmitting = false;
        });
      }
    }
  }

  Future<void> changePasswordDialog() async {
    // Reset values every time the dialog opens.
    oldPassword = '';
    password = '';
    passwordConfirmation = '';
    error = '';
    passwordSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            Future<void> onChangePassword() async {
              dialogSetState(() {
                error = '';
              });

              if (!_passwordFormKey.currentState!.validate()) {
                return;
              }

              FocusScope.of(context).unfocus();

              dialogSetState(() {
                passwordSubmitting = true;
              });

              try {
                final Map<String, dynamic> jsonResult =
                await _api.changePassword(oldPassword, password);

                if (!mounted) return;

                if (jsonResult['status'] == true) {
                  Navigator.of(dialogContext).pop();

                  Alert.successSnackbar(
                    context,
                    jsonResult['message']?.toString() ??
                        'Password changed successfully.',
                  );
                } else {
                  dialogSetState(() {
                    error =
                        jsonResult['message']?.toString() ??
                            'Unable to change password.';
                  });
                }
              } catch (e) {
                if (!mounted) return;

                dialogSetState(() {
                  error = 'Something went wrong!';
                });
              } finally {
                if (mounted) {
                  dialogSetState(() {
                    passwordSubmitting = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error.isNotEmpty) ...[
                        Text(
                          error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // Current password
                      TextFormField(
                        onChanged: (value) {
                          oldPassword = value;
                        },
                        autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }

                          if (value.length < 6) {
                            return 'Must be at least 6 characters';
                          }

                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          labelText: 'Current Password',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // New password
                      TextFormField(
                        onChanged: (value) {
                          password = value;
                        },
                        autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }

                          if (value.length < 6) {
                            return 'Must be at least 6 characters';
                          }

                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          labelText: 'New Password',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Confirm password
                      TextFormField(
                        onChanged: (value) {
                          passwordConfirmation = value;
                        },
                        autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          }

                          if (value.length < 6) {
                            return 'Must be at least 6 characters';
                          }

                          if (value != password) {
                            return 'Password and confirm password do not match';
                          }

                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          labelText: 'Confirm Password',
                        ),
                      ),

                      const SizedBox(height: 20),

                      passwordSubmitting
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: onChangePassword,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                              textColor: Colors.white,
                              color:
                              Theme.of(context).primaryColor,
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                              textColor: Colors.white,
                              color: Colors.black12,
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _subscriptionWarning() {
    if (user == null || (!user!.reminder && !user!.expired!)) {
      return const SizedBox.shrink();
    }

    final String expiryText =
    user!.expiryDate != null && user!.expiryDate!.isNotEmpty
        ? DateFormater.dateParser(user!.expiryDate!)
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
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
              'Your subscription ${user!.expired! ? 'has expired' : 'will expire'} on <b>$expiryText</b>. Please renew your account.',
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
    );
  }

  Widget _profileForm() {
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color.fromARGB(255, 230, 230, 230),
            ),
          ),

          TextFormField(
            initialValue: user?.name ?? '',
            onChanged: (value) {
              name = value;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: 'Name',
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Address',
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color.fromARGB(255, 230, 230, 230),
            ),
          ),

          TextFormField(
            initialValue: user?.address ?? '',
            onChanged: (value) {
              address = value;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Address',
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Email',
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color.fromARGB(255, 230, 230, 230),
            ),
          ),

          TextFormField(
            initialValue: user?.email ?? '',
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),

          const SizedBox(height: 15),

          profileSubmitting
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : MaterialButton(
            color: const Color.fromARGB(255, 33, 33, 33),
            textColor: Colors.white,
            onPressed: onUpdateProfile,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _passwordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
        ),
        const SizedBox(height: 12),
        MaterialButton(
          color: const Color.fromARGB(255, 33, 33, 33),
          textColor: Colors.white,
          onPressed: changePasswordDialog,
          child: const Text('Change Password'),
        ),
      ],
    );
  }

  Widget _subscriptionSection() {
    final String expiryDate = user?.expiryDate ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription',
          style: TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          expiryDate.isEmpty
              ? 'Subscription till: (Not Subscribed)'
              : 'Subscription till: ${DateFormater.dateParser(expiryDate)}',
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.w300,
            fontSize: 15,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loader();
    }

    return Scaffold(
      backgroundColor: Colors.black12,
      endDrawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _subscriptionWarning(),

          Expanded(
            child: ListView(
              children: [
                Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'MY PROFILE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(
                                255,
                                200,
                                200,
                                200,
                              ),
                            ),
                          ),
                        ),

                        const Divider(),

                        _profileForm(),

                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),

                        _passwordSection(),

                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),

                        _subscriptionSection(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}