import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/main_drawer.dart';
import 'package:kutumba/models/advertisement.dart';
import 'package:kutumba/models/artist.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiService _api = ApiService();

  bool isAuthenticated = false;
  bool loading = false;

  List<Artist> artists = [];
  List<Advertisement> advertisements = [];

  String? fbLink;
  String? instagramLink;
  String? youtubeLink;
  String? twitterLink;

  final AudioPlayer audioPlayer = AudioPlayer();

  ConcatenatingAudioSource? audioList;

  @override
  void initState() {
    super.initState();

    getHomePage();
    getAdvertisements();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = Provider.of<UserProvider>(context).user;

    isAuthenticated = user != null;
  }

  Future<void> getHomePage() async {
    try {
      final Map jsonResult = await _api.fetchHomepage();

      if (!mounted) {
        return;
      }

      if (jsonResult['status'] == false) {
        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ??
              'Something went wrong!',
        );

        setState(() {
          loading = false;
        });

        return;
      }

      final List artistsList =
          jsonResult['artists'] as List? ?? [];

      artists = artistsList
          .map(
            (val) => Artist.fromJson(
          Map<String, dynamic>.from(val as Map),
        ),
      )
          .toList();

      final Map siteConfig =
      Map<String, dynamic>.from(
        jsonResult['site_config'] as Map? ?? {},
      );

      fbLink = siteConfig['facebook_link']?.toString();
      instagramLink = siteConfig['instagram_link']?.toString();
      twitterLink = siteConfig['twitter_link']?.toString();
      youtubeLink = siteConfig['youtube_link']?.toString();

      final List<AudioSource> audioSources = [];

      final String? homePageAudio =
      siteConfig['home_page_audio']?.toString();

      final String? homePageAudio2 =
      siteConfig['home_page_audio2']?.toString();

      final String? homePageAudio3 =
      siteConfig['home_page_audio3']?.toString();

      if (homePageAudio != null && homePageAudio.isNotEmpty) {
        audioSources.add(
          AudioSource.uri(
            Uri.parse(
              AppUrl.baseURL + homePageAudio,
            ),
          ),
        );
      }

      if (homePageAudio2 != null && homePageAudio2.isNotEmpty) {
        audioSources.add(
          AudioSource.uri(
            Uri.parse(
              AppUrl.baseURL + homePageAudio2,
            ),
          ),
        );
      }

      if (homePageAudio3 != null && homePageAudio3.isNotEmpty) {
        audioSources.add(
          AudioSource.uri(
            Uri.parse(
              AppUrl.baseURL + homePageAudio3,
            ),
          ),
        );
      }

      if (audioSources.isNotEmpty) {
        audioList = ConcatenatingAudioSource(
          children: audioSources,
        );

        await audioPlayer.setAudioSource(audioList!);
        await audioPlayer.setLoopMode(LoopMode.all);
        await audioPlayer.play();
      }

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Home page error: $e');

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

  Future<void> getAdvertisements() async {
    try {
      final Map jsonResult =
      await _api.fetchAdvertisements();

      if (!mounted) {
        return;
      }

      if (jsonResult['status'] == true) {
        advertisements = List<Advertisement>.from(
          jsonResult['data'] ?? [],
        );
      } else {
        Alert.errorSnackbar(
          context,
          jsonResult['message']?.toString() ??
              'Unable to load advertisements.',
        );
      }

      setState(() {});
    } catch (e) {
      debugPrint('Advertisements error: $e');

      if (!mounted) {
        return;
      }

      Alert.errorSnackbar(
        context,
        'Unable to load advertisements.',
      );
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return;
    }

    final Uri? uri = Uri.tryParse(url);

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
      debugPrint('Unable to launch URL: $e');

      if (mounted) {
        Alert.errorSnackbar(
          context,
          'Unable to open the link.',
        );
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loader();
    }

    return Scaffold(
      backgroundColor: Colors.black12,
      endDrawer:
      isAuthenticated ? MainDrawer() : null,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
        actions: !isAuthenticated
            ? [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/login',
              );
            },
            child: const Text(
              'LOG IN',
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
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/register',
              );
            },
            child: const Text(
              'SIGN UP',
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
        ]
            : [],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      height:
                      MediaQuery.of(context).size.height *
                          0.65,
                      viewportFraction: 1.0,
                      autoPlayInterval:
                      const Duration(seconds: 6),
                    ),
                    items: artists.map((artist) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context)
                                .size
                                .width,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  AppUrl.baseURL +
                                      artist.photo,
                                  height:
                                  MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.4,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent?
                                      loadingProgress,
                                      ) {
                                    if (loadingProgress ==
                                        null) {
                                      return child;
                                    }

                                    return Center(
                                      child: SizedBox(
                                        height:
                                        MediaQuery.of(
                                            context)
                                            .size
                                            .height *
                                            0.4,
                                        child: Image.asset(
                                          'assets/images/loading.gif',
                                          height: 100,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return SizedBox(
                                      height:
                                      MediaQuery.of(
                                          context)
                                          .size
                                          .height *
                                          0.4,
                                      child: const Center(
                                        child: Icon(
                                          Icons
                                              .image_not_supported,
                                          color: Colors.grey,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artist.firstName
                                            .toUpperCase(),
                                        style:
                                        const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            162,
                                            162,
                                            162,
                                          ),
                                          fontSize: 24,
                                          fontWeight:
                                          FontWeight.bold,
                                          letterSpacing: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (artist
                                          .sliderText
                                          .isNotEmpty)
                                        Text(
                                          artist.sliderText,
                                          style:
                                          const TextStyle(
                                            color:
                                            Color.fromARGB(
                                              255,
                                              162,
                                              162,
                                              162,
                                            ),
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      height:
                      MediaQuery.of(context).size.height *
                          0.15,
                      viewportFraction: 1.0,
                      autoPlayInterval:
                      const Duration(seconds: 4),
                    ),
                    items: advertisements.map((advertisement) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              _launchUrl(
                                advertisement.url,
                              );
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context)
                                  .size
                                  .width,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceAround,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    AppUrl.baseURL +
                                        advertisement
                                            .imageFile!,
                                    height:
                                    MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.12,
                                    fit: BoxFit.contain,
                                  ),
                                  Flexible(
                                    child: Text(
                                      advertisement.title!,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          162,
                                          162,
                                          162,
                                        ),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Material(
              color: Colors.black,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                    ),
                    onPressed: () {
                      _launchUrl(fbLink);
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.instagram,
                    ),
                    onPressed: () {
                      _launchUrl(instagramLink);
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.twitter,
                    ),
                    onPressed: () {
                      _launchUrl(twitterLink);
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.youtube,
                    ),
                    onPressed: () {
                      _launchUrl(youtubeLink);
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      _launchUrl(
                        'http://www.kutumbaband.com/',
                      );
                    },
                    child: Image.network(
                      AppUrl.baseURL +
                          'themes/asterisk/images/redirect.png',
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (
                  BuildContext context,
                  AsyncSnapshot<PlayerState> snapshot,
                  ) {
                final PlayerState? playerState =
                    snapshot.data;

                final bool playing =
                    playerState?.playing ?? false;

                return Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.zero,
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                          WidgetStateProperty.all(
                            Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          if (playing) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.play();
                          }
                        },
                        child: Image.asset(
                          playing
                              ? 'assets/images/audio_play.gif'
                              : 'assets/images/audio_pause.png',
                          height: 30,
                          alignment: Alignment.topRight,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}