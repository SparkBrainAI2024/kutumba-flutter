import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/note.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/date_formater.dart';
import 'package:kutumba/utils/refresh_token.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main_drawer.dart';
import '../components/header_logo.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  bool loading = false;

  final ApiService _api = ApiService();

  List<Note> notes = [];

  User? user;

  String subscriptionType = 'subscription';

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  Future<void> getNotes() async {
    try {
      final UserService userApi = UserService();

      final Map<String, dynamic> statusResult =
      await userApi.fetchProfile();

      if (statusResult['status'] == true) {
        user = statusResult['data'] as User;

        if (!user!.subscribed || user!.expired!) {
          subscriptionType =
          user!.subscribed ? 'renew' : 'subscription';

          if (!mounted) {
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Payment(
                subscriptionType,
                redirectPage: '/notes',
              ),
            ),
          );

          return;
        }
      } else {
        final dynamic statusCode = statusResult['statusCode'];

        if (statusCode == 402 || statusCode == 401) {
          final Map<String, dynamic>? refreshResponse =
          await RefreshToken.refresh(context);

          if (refreshResponse != null) {
            await getNotes();
          }

          return;
        }

        if (statusCode == 409) {
          await RefreshToken.logout(
            context,
            statusResult['message']?.toString() ??
                'Session expired.',
          );

          return;
        }

        if (mounted) {
          Alert.errorSnackbar(
            context,
            statusResult['message']?.toString() ??
                'Unable to fetch profile.',
          );

          setState(() {
            loading = false;
          });
        }

        return;
      }

      final Map<String, dynamic> jsonResult =
      await _api.fetchNotes();

      if (jsonResult['status'] == true) {
        final List<dynamic> data =
            jsonResult['data'] as List<dynamic>? ?? [];

        notes = data
            .map(
              (item) => item is Note
              ? item
              : Note.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
            .toList();
      } else {
        if (jsonResult['statusCode'] == 403) {
          if (!mounted) {
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Payment(
                subscriptionType,
                redirectPage: '/notes',
              ),
            ),
          );

          return;
        }

        if (mounted) {
          Alert.errorSnackbar(
            context,
            jsonResult['message']?.toString() ??
                'Unable to fetch notes.',
          );
        }
      }

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Get notes error: $e');

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

  Future<void> _downloadNote(Note note) async {
    final String filePath = note.filePath ?? '';

    if (filePath.isEmpty) {
      Alert.errorSnackbar(
        context,
        'File is not available.',
      );
      return;
    }

    final Uri? uri = Uri.tryParse(
      '${AppUrl.baseURL}$filePath?type=api',
    );

    if (uri == null) {
      Alert.errorSnackbar(
        context,
        'Invalid download URL.',
      );
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        Alert.errorSnackbar(
          context,
          'Unable to download the file.',
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');

      if (mounted) {
        Alert.errorSnackbar(
          context,
          'Unable to download the file.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loader();
    }

    return Scaffold(
      backgroundColor: Colors.black12,
      endDrawer: MainDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (user != null &&
              (user!.reminder || user!.expired!))
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Color.fromARGB(
                      255,
                      204,
                      50,
                      50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Html(
                      data:
                      'Your subscription ${user!.expired! ? 'has expired' : 'will expire'} '
                          'on <b>${DateFormater.dateParser(user!.expiryDate!)}</b>. '
                          'Please renew your account.',
                      style: {
                        'html': Style(
                          textAlign: TextAlign.left,
                          color: const Color.fromARGB(
                            255,
                            204,
                            50,
                            50,
                          ),
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOWNLOAD NOTES',
                        style: TextStyle(
                          color: Color.fromARGB(
                            255,
                            175,
                            175,
                            175,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      if (notes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 30,
                          ),
                          child: Center(
                            child: Text(
                              'No notes available.',
                              style: TextStyle(
                                color: Color.fromARGB(
                                  255,
                                  175,
                                  175,
                                  175,
                                ),
                              ),
                            ),
                          ),
                        ),

                      for (final Note note in notes)
                        Column(
                          children: [
                            const Divider(
                              color: Color.fromARGB(
                                255,
                                200,
                                200,
                                200,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding:
                                const EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                ),
                                decoration:
                                const BoxDecoration(
                                  color: Color.fromARGB(
                                    160,
                                    0,
                                    0,
                                    0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      textAlign:
                                      TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 3,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        Color.fromARGB(
                                          255,
                                          214,
                                          214,
                                          214,
                                        ),
                                      ),
                                    ),

                                    if (note.description
                                        .isNotEmpty)
                                      Html(
                                        data:
                                        note.description,
                                        style: {
                                          'html':
                                          Style.fromTextStyle(
                                            const TextStyle(
                                              height: 1.4,
                                              fontSize: 14,
                                              letterSpacing: 3,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color:
                                              Color.fromARGB(
                                                255,
                                                214,
                                                214,
                                                214,
                                              ),
                                            ),
                                          ),
                                        },
                                      ),

                                    const SizedBox(height: 10),

                                    GestureDetector(
                                      onTap: () {
                                        _downloadNote(note);
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: [
                                          Icon(
                                            Icons
                                                .download_outlined,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Download',
                                            style:
                                            TextStyle(
                                              fontSize: 17,
                                              letterSpacing: 3,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color:
                                              Color.fromARGB(
                                                255,
                                                214,
                                                214,
                                                214,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      const Divider(
                        color: Color.fromARGB(
                          255,
                          200,
                          200,
                          200,
                        ),
                      ),
                    ],
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