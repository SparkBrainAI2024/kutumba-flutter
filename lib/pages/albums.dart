import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/models/partner.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/date_formater.dart';
import 'package:kutumba/utils/refresh_token.dart';
import 'package:url_launcher/url_launcher.dart';

import './../main_drawer.dart';
import './../components/header_logo.dart';

class Albums extends StatefulWidget {
  const Albums({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Albums();
  }
}

class _Albums extends State<Albums> {
  bool loading = true;
  final ApiService _api = ApiService();
  List<Album> albums = [];
  List<Partner> partners = [];

  User user;
  bool allowAccess = false;
  String subscriptionType = 'subscription';

  getAlbums() async {
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

      // if(user.expired){
      //   Navigator.of(context).pushReplacementNamed('/payment', arguments: subscriptionType);
      //   return;
      // }
    } else {
      if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 402 ||
              statusResult['statusCode'] == 401)) {
        Map refreshResponse = await RefreshToken.refresh(context);
        if (refreshResponse != null) {
          init();
        }

        return;
      } else if (statusResult['statusCode'] != null &&
          (statusResult['statusCode'] == 409)) {
        await RefreshToken.logout(context, statusResult['message']);
        return;
      }
    }

    Map jsonResult = await _api.fetchAlbums();

    if (jsonResult['status']) {
      albums = jsonResult['data'];
    } else {
      Alert.errorSnackbar(context, jsonResult['message']);
    }
    setState(() {
      loading = false;
    });
  }

  getPartners() async {
    Map jsonResult = await _api.fetchPartners();

    if (jsonResult['status']) {
      partners = jsonResult['data'];
    } else {
      Alert.errorSnackbar(context, jsonResult['message']);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  init() {
    getAlbums();
    getPartners();
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
              // Here we take the value from the MyAlbumsPage object that was created by
              // the App.build method, and use it to set our appbar title.
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
                            const Text('ALL ALBUMS',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const Divider(),
                            const Divider(),
                            for (var album in albums)
                              Column(
                                children: [
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
                                                      album.coverPhoto),
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
                                                flex: 2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(20),
                                                    decoration: const BoxDecoration(
                                                      color: Color.fromARGB(
                                                          160, 0, 0, 0),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(album.name,
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                letterSpacing:
                                                                    3,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        214,
                                                                        214,
                                                                        214))),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                album.trackCount
                                                                        .toString() +
                                                                    ' TRACKS',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color.fromARGB(
                                                                        255,
                                                                        214,
                                                                        214,
                                                                        214))),
                                                            Text(
                                                                album
                                                                    .releaseDate,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color.fromARGB(
                                                                        255,
                                                                        214,
                                                                        214,
                                                                        214)))
                                                          ],
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
                                      if (!allowAccess) {
                                        Navigator.of(context).pushNamed(
                                            '/albumDetail',
                                            arguments: album);
                                      } else {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) => Payment(
                                                    subscriptionType,
                                                    hasBackBtn: true)));
                                      }
                                    },
                                  ),
                                  const Divider(),
                                ],
                              ),
                            const Divider(),
                            const Text('OUR PARTNERS',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                for (var partner in partners)
                                  GestureDetector(
                                    child: SizedBox(
                                      child: Image.network(
                                        AppUrl.baseURL + partner.imageFile,
                                        fit: BoxFit.contain,
                                      ),
                                      width: 100,
                                    ),
                                    onTap: () {
                                      launch(partner.link);
                                    },
                                  ),
                              ],
                            )
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
