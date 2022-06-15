import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/models/advertisement.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/artist.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/utils/app_url.dart';

import './../main_drawer.dart';
import './../components/header_logo.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  final ApiService _api = ApiService();
  bool isAuthenticated = false;

  List<Artist> artists = [];
  List<Advertisement> advertisements = [];

  String fbLink;
  String instagramLink;
  String youtubeLink;
  String twitterLink;

  bool loading = true;
  AudioPlayer audioPlayer = AudioPlayer();
  ConcatenatingAudioSource audiolist;

  void getHomePage() async {
    try {
      Map jsonResult = await _api.fetchHomepage();

      if (jsonResult == null) {
        Alert.errorSnackbar(context, 'Something went wrong!');
        return;
      }

      final List artistsList = jsonResult['artists'];
      artists = artistsList.map((val) => Artist.fromJson(val)).toList();

      Map siteConfig = jsonResult['site_config'];

      fbLink = siteConfig['facebook_link'];
      instagramLink = siteConfig['instagram_link'];
      twitterLink = siteConfig['twitter_link'];
      youtubeLink = siteConfig['youtube_link'];

      audiolist = ConcatenatingAudioSource(children: [
        AudioSource.uri(
          Uri.parse(AppUrl.baseURL + siteConfig['home_page_audio']),
        ),
        if (siteConfig['home_page_audio2'] != null)
          AudioSource.uri(
            Uri.parse(AppUrl.baseURL + siteConfig['home_page_audio2']),
          ),
        if (siteConfig['home_page_audio3'] != null)
          AudioSource.uri(
            Uri.parse(AppUrl.baseURL + siteConfig['home_page_audio3']),
          ),
      ]);

      await audioPlayer.setAudioSource(audiolist);
      audioPlayer.setLoopMode(LoopMode.all);
      audioPlayer.play();

      setState(() {
        loading = false;
      });
    } catch (e) {
      Alert.errorSnackbar(context, 'Something went wrong!');
      setState(() {
        loading = false;
      });
    }
  }

  void getAdvertisements() async {
    Map jsonResult = await _api.fetchAdvertisements();

    if (jsonResult['status']) {
      advertisements = jsonResult['data'];
    } else {
      Alert.errorSnackbar(context, jsonResult['message']);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getHomePage();
    getAdvertisements();
  }

  @override
  void didChangeDependencies() {
    final user = Provider.of<UserProvider>(context).user;

    isAuthenticated = user != null;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (audioPlayer != null) audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loader()
        : Scaffold(
            backgroundColor: Colors.black12,
            endDrawer: isAuthenticated ? const MainDrawer() : null,
            appBar: AppBar(
              backgroundColor: Colors.black12,
              title: const HeaderLogo(),
              centerTitle: false,
              actions: !isAuthenticated
                  ? [
                      TextButton(
                        child: const Text('LOG IN',
                            style: TextStyle(
                              color: Color.fromARGB(255, 162, 162, 162),
                            )),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      TextButton(
                        child: const Text('SIGN UP',
                            style: TextStyle(
                              color: Color.fromARGB(255, 162, 162, 162),
                            )),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                      )
                    ]
                  : [],
            ),
            body: Stack(children: [
              ListView(children: [
                Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        height: MediaQuery.of(context).size.height * 0.65,
                        viewportFraction: 1.0,
                        autoPlayInterval: const Duration(seconds: 6),
                      ),
                      items: artists.map((artist) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        AppUrl.baseURL + artist.photo,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                              child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                            child: Image.asset(
                                              "assets/images/loading.gif",
                                              height: 100,
                                            ),
                                          ));
                                        },
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 20, 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  artist.firstName
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      color:
                                                          Color.fromARGB(255,
                                                              162, 162, 162),
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 12)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              if (artist.sliderText != null)
                                                Text(
                                                  artist.sliderText,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 162, 162, 162),
                                                      fontSize: 14,
                                                      height: 1.4),
                                                )
                                            ],
                                          )),
                                    ]));
                          },
                        );
                      }).toList(),
                    ),
                    CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          height: MediaQuery.of(context).size.height * 0.15,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 4),
                        ),
                        items: advertisements.map((advertisement) {
                          return Builder(builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                launch(advertisement.url);
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      AppUrl.baseURL +
                                          advertisement.imageFile,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.12,
                                    ),
                                    Flexible(
                                      // padding: EdgeInsets.only(left:20),
                                      child: Text(
                                        advertisement.title,
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 162, 162, 162),
                                            fontSize: 14,
                                            height: 1.4),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        }).toList()),
                  ],
                )
              ]),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Material(
                  color: Colors.black,
                  // decoration: BoxDecoration(color: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.facebook),
                        onPressed: () {
                          launch(fbLink);
                        },
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.instagram),
                        onPressed: () {
                          launch(instagramLink);
                        },
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.twitter),
                        onPressed: () {
                          launch(twitterLink);
                        },
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.youtube),
                        onPressed: () {
                          launch(youtubeLink);
                        },
                      ),
                      TextButton(
                        child: Image.network(
                          AppUrl.baseURL +
                              'themes/asterisk/images/redirect.png',
                          height: 30,
                        ),
                        onPressed: () {
                          launch('http://www.kutumbaband.com/');
                        },
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: StreamBuilder<PlayerState>(
                    stream: audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final playing = playerState?.playing ?? false;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.black),
                                  ),
                                  child: Image.asset(
                                    playing
                                        ? "assets/images/audio_play.gif"
                                        : "assets/images/audio_pause.png",
                                    height: 30,
                                    alignment: Alignment.topRight,
                                  ),
                                  onPressed: () async {
                                    if (playing) {
                                      await audioPlayer.pause();
                                    } else {
                                      await audioPlayer.play();
                                    }
                                  })),
                        ],
                      );
                    }),
              ),
            ]));
  }
}
