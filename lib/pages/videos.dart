import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/user_api.dart';

import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/video.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/date_formater.dart';
import 'package:kutumba/utils/refresh_token.dart';

import './../main_drawer.dart';
import './../components/header_logo.dart';

class Videos extends StatefulWidget {
  const Videos({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Videos();
  }
}

class _Videos extends State<Videos> {
  bool loading = true;
  final ApiService _api = ApiService();
  List<Video> videos = [];

  User user;
  bool allowAccess = false;
  String subscriptionType = 'subscription';

  getVideos() async {
    UserService _userapi = UserService();
    Map statusResult = await _userapi.fetchProfile();
    if (statusResult['status']) {
      user = statusResult['data'];

      // if(user.expired){
      //   Navigator.of(context).pushReplacementNamed('/profile');
      //   return;
      // }

      allowAccess = user.subscribed && !user.expired;
      subscriptionType = user.subscribed ? 'renew' : 'subscription';

      if (!user.subscribed || user.expired) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                Payment(subscriptionType, redirectPage: '/videos')));
        return;
      }
    } else {
      if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 402 ||
              statusResult['statusCode'] == 401)) {
        Map refreshResponse = await RefreshToken.refresh(context);
        if (refreshResponse != null) {
          getVideos();
        }

        return;
      } else if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 409)) {
        await RefreshToken.logout(context, statusResult['message']);
        return;
      }
    }

    Map jsonResult = await _api.fetchVideos();

    if (jsonResult['status']) {
      videos = jsonResult['data'];
    } else {
      if (jsonResult['statusCode'] != null && jsonResult['statusCode'] == 403) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                Payment(subscriptionType, redirectPage: '/videos')));
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

    getVideos();
  }

  @override
  void dispose() {
    super.dispose();
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
              // Here we take the value from the MyVideosPage object that was created by
              // the App.build method, and use it to set our appbar title.
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
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ALL VIDEOS',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const Divider(),
                            const Divider(),
                            for (var video in videos)
                              Column(children: [
                                InkWell(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 400,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                AppUrl.baseURL +
                                                    video.thumbnail),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 400,
                                        child: Column(
                                          children: [
                                            Expanded(
                                                flex: 5,
                                                child: Container()),
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                  width: double.maxFinite,
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromARGB(
                                                        160, 0, 0, 0),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(video.title,
                                                          style: const TextStyle(
                                                              fontSize: 24,
                                                              letterSpacing:
                                                                  1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      214,
                                                                      214,
                                                                      214))),
                                                      if (video.description !=
                                                          null)
                                                        Flexible(
                                                          child: Text(video.description,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  height: 1.4,
                                                                  fontSize:
                                                                      14,
                                                                  letterSpacing:
                                                                      1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          214,
                                                                          214,
                                                                          214))),
                                                        )
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (allowAccess) {
                                      Navigator.of(context).pushNamed(
                                          '/videoDetail',
                                          arguments: video);
                                    } else {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) => Payment(
                                                  subscriptionType,
                                                  redirectPage: '/videos',
                                                  hasBackBtn: true)));
                                    }
                                  },
                                ),
                                const Divider(),
                              ]),
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
