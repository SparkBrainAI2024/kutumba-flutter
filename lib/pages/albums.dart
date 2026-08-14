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

import '../components/header_logo.dart';
import '../main_drawer.dart';

class Albums extends StatefulWidget {
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  bool loading = true;

  final ApiService _api = ApiService();

  List<Album> albums = [];
  List<Partner> partners = [];

  User? user;

  bool allowAccess = false;
  String subscriptionType = 'subscription';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.wait([
      getAlbums(),
      getPartners(),
    ]);
  }

  Future<void> getAlbums() async {
    final UserService userApi = UserService();

    final Map statusResult = await userApi.fetchProfile();

    if (statusResult['status'] == true) {
      user = statusResult['data'] as User;

      allowAccess = user!.subscribed && !user!.expired!;

      subscriptionType =
      user!.subscribed ? 'renew' : 'subscription';
    } else {
      final int? statusCode = statusResult['statusCode'] as int?;

      if (statusCode == 402 || statusCode == 401) {
        final Map refreshResponse =
        await RefreshToken.refresh(context);

        if (refreshResponse['status'] == true) {
          await init();
        }

        return;
      }

      if (statusCode == 409) {
        await RefreshToken.logout(
          context,
          statusResult['message']?.toString() ?? '',
        );

        return;
      }
    }

    final Map jsonResult = await _api.fetchAlbums();

    if (jsonResult['status'] == true) {
      albums = List<Album>.from(
        jsonResult['data'] ?? [],
      );
    } else {
      if (mounted) {
        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ?? 'Unable to load albums.',
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getPartners() async {
    final Map jsonResult = await _api.fetchPartners();

    if (jsonResult['status'] == true) {
      partners = List<Partner>.from(
        jsonResult['data'] ?? [],
      );
    } else {
      if (mounted) {
        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ?? 'Unable to load partners.',
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openPartnerLink(String link) async {
    final Uri? uri = Uri.tryParse(link);

    if (uri == null) {
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
          'Unable to open the link.',
        );
      }
    } catch (e) {
      debugPrint('Unable to launch partner URL: $e');

      if (mounted) {
        Alert.errorSnackbar(
          context,
          'Unable to open the link.',
        );
      }
    }
  }

  void _openAlbum(Album album) {
    if (allowAccess) {
      Navigator.of(context).pushNamed(
        '/albumDetail',
        arguments: {
          'album': album,
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Payment(
                subscriptionType,
                hasBackBtn: true,
              ),
        ),
      );
    }
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
          if (user != null && (user!.reminder || user!.expired!))
            Container(
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
                      'Your subscription ${user!.expired!
                          ? 'has expired'
                          : 'will expire'} on '
                          '<b>${DateFormater.dateParser(
                          user!.expiryDate!)}</b>. '
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ALL ALBUMS',
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
                      const Divider(),

                      for (final album in albums)
                        Column(
                          children: [
                            InkWell(
                              onTap: () => _openAlbum(album),
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
                                              album.coverPhoto,
                                        ),
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
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding:
                                            const EdgeInsets.all(20),
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
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .stretch,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  album.name,
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 20,
                                                    letterSpacing: 3,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromARGB(
                                                      255,
                                                      214,
                                                      214,
                                                      214,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${album
                                                          .trackCount} TRACKS',
                                                      style:
                                                      const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                        Color.fromARGB(
                                                          255,
                                                          214,
                                                          214,
                                                          214,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      album.releaseDate,
                                                      style:
                                                      const TextStyle(
                                                        fontSize: 16,
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        ),

                      const Divider(),

                      const Text(
                        'OUR PARTNERS',
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

                      const SizedBox(height: 20),

                      Wrap(
                        direction: Axis.horizontal,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final partner in partners)
                            GestureDetector(
                              onTap: () =>
                                  _openPartnerLink(partner.link),
                              child: SizedBox(
                                width: 100,
                                child: Image.network(
                                  AppUrl.baseURL +
                                      partner.imageFile,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        ],
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