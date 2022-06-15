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
  const Notes({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Notes();
  }
}

class _Notes extends State<Notes> {
  bool loading = true;
  final ApiService _api = ApiService();
  List<Note> notes = [];

  User user;
  String subscriptionType = 'subscription';

  getNotes() async {
    UserService _userapi = UserService();
    Map statusResult = await _userapi.fetchProfile();
    if (statusResult['status']) {
      user = statusResult['data'];

      // if(user.expired){
      //   Navigator.of(context).pushReplacementNamed('/profile');
      //   return;
      // }
      if (!user.subscribed || user.expired) {
        subscriptionType = user.subscribed ? 'renew' : 'subscription';

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                Payment(subscriptionType, redirectPage: '/notes')));
        return;
      }
    } else {
      if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 402 ||
              statusResult['statusCode'] == 401)) {
        Map refreshResponse = await RefreshToken.refresh(context);
        if (refreshResponse != null) {
          getNotes();
        }

        return;
      } else if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 409)) {
        await RefreshToken.logout(context, statusResult['message']);
        return;
      }

      Alert.errorSnackbar(context, statusResult['message']);
      return;
    }

    Map jsonResult = await _api.fetchNotes();

    if (jsonResult['status']) {
      notes = jsonResult['data'];
    } else {
      if (jsonResult['statusCode'] != null && jsonResult['statusCode'] == 403) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                Payment(subscriptionType, redirectPage: '/notes')));
        return;
      }
      Alert.errorSnackbar(context, jsonResult['message']);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Row(children: [
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
                      )
                    ]),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DOWNLOAD NOTES',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const Divider(),
                            for (var note in notes)
                              Column(
                                children: [
                                  const Divider(
                                    color: Color.fromARGB(255, 200, 200, 200),
                                  ),
                                  InkWell(
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(160, 0, 0, 0),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(note.title,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    letterSpacing: 3,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 214, 214, 214))),
                                            if (note.description != null)
                                              Html(
                                                data: note.description,
                                                style: {
                                                  'html': Style.fromTextStyle(
                                                    const TextStyle(
                                                      height: 1.4,
                                                      fontSize: 14,
                                                      letterSpacing: 3,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 214, 214, 214),
                                                    ),
                                                  ),
                                                },
                                              ),
                                            const SizedBox(height: 10),
                                            GestureDetector(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                  children: const [
                                                    Icon(Icons
                                                        .download_outlined),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Download",
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          letterSpacing: 3,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color.fromARGB(
                                                                  255,
                                                                  214,
                                                                  214,
                                                                  214)),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  launch(AppUrl.baseURL +
                                                      note.filePath +
                                                      '?type=api');
                                                })
                                          ],
                                        )),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            const Divider(
                              color: Color.fromARGB(255, 200, 200, 200),
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
