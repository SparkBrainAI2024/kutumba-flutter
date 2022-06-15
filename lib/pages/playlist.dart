import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kutumba/components/audio_service/audio_handler.dart';
import 'package:kutumba/components/audio_service/seekbar.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/models/track.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/services/service_locator.dart';
import 'package:kutumba/utils/refresh_token.dart';
import 'package:kutumba/utils/user_preferences.dart';
import 'package:kutumba/utils/app_url.dart';

class Playlist extends StatefulWidget {
  final Album album;
  Playlist(this.album);

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  Album album;
  bool loading = true;
  final ApiService _api = ApiService();
  ScrollController controller = ScrollController();

  final _audioHandler = getIt<AudioHandler>();

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    for (var mediaItem in _audioHandler.queue.value) {
      _audioHandler.removeQueueItem(mediaItem);
    }

    album = widget.album;

    album.track = [];
    Map jsonResult = await _api.fetchTracks(album.id);

    if (jsonResult['status']) {
      album.track = jsonResult['data'];
    } else {
      // if (jsonResult['statusCode'] != null &&
      //     (jsonResult['statusCode'] == 402 ||
      //         jsonResult['statusCode'] == 401)) {
      //   Map refreshResponse = await RefreshToken.refresh(context);
      //   if (refreshResponse != null) {
      //     init();
      //   }
      //   return;
      // } else if (jsonResult['statusCode'] != null &&
      //     (jsonResult['statusCode'] == 409)) {
      //   await RefreshToken.logout(context, jsonResult['message']);
      //   return;
      // } else if (jsonResult['statusCode'] != null &&
      //     jsonResult['statusCode'] == 403) {
      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (context) => Payment('renew', hasBackBtn: true)));
      //   return;
      // }

      // Alert.errorSnackbar(context, jsonResult['message']);
      // return;
    }

    // String token = await UserPreferences().getToken();

    // final mediaItems = album.track
    //     .map((track) => MediaItem(
    //         id: track.id.toString(),
    //         album: album.name,
    //         title: track.title,
    //         extras: {"url": track.musicUrl + "?token=" + token}))
    //     .toList();
    // _audioHandler.addQueueItems(mediaItems);

    //// For testing only
    album.track = List.generate(
        10,
        (index) => Track.fromJson({
              'id': (index+1),
              'title': 'Song ${index+1}',
              'album_id': album.id.toString(),
              'music_url':
                  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${index+1}.mp3',
            }));

    final mediaItems = album.track
        .map((track) => MediaItem(
            id: track.id.toString(),
            album: album.name,
            title: track.title,
            extras: {"url": track.musicUrl}))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
    ////

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    // if (_audioHandler != null) {
    //   _audioHandler.customAction('dispose');
    // }

    // controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loader()
        : Scaffold(
            backgroundColor: Colors.black12,
            // endDrawer: MainDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.black12,
              title: const HeaderLogo(),
              centerTitle: false,
            ),
            body: WillPopScope(
              onWillPop: () {
                _audioHandler.stop();
                return Future.value(true);
              },
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        AppUrl.baseURL + album.coverPhoto),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 15),
                                  Text(album.name,
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 175, 175, 175),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1)),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 2,
                                        child: Text('Artist:',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(album.artist,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 2,
                                        child: Text('Release Date:',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(album.releaseDate,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 2,
                                        child: Text('Label:',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(album.label,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            album.track.length.toString() +
                                                ' tracks',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(album.totalTime,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 175, 175),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ])),
                    Center(
                      child: StreamBuilder<PlaybackState>(
                        stream: _audioHandler.playbackState,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.active) {
                            // Don't show anything until we've ascertained whether or not the
                            // service is running, since we want to show a different UI in
                            // each case.
                            return const SizedBox();
                          }
                          // final running = snapshot.data ?? false;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // if (!running) ...[
                              //   // UI to show when we're not running, i.e. a menu.
                              //   audioPlayerButton(),

                              // ] else ...[
                              // UI to show when we're running, i.e. player state/controls.

                              // Queue display/controls.
                              StreamBuilder<MediaItem>(
                                stream: _audioHandler.mediaItem,
                                builder: (context, snapshot) {
                                  final mediaItem = snapshot.data;
                                  final queue = _audioHandler.queue.value;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (queue != null && queue.isNotEmpty)
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              //Cover Photo
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Image.network(
                                                    AppUrl.baseURL +
                                                        album.coverPhoto,
                                                    height: 100,
                                                    width: 100,
                                                  )),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      // song title
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          mediaItem != null
                                                              ? (mediaItem
                                                                      .title ??
                                                                  "" +
                                                                      ' - ' +
                                                                      mediaItem
                                                                          .artist ??
                                                                  "")
                                                              : '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                            letterSpacing: 1,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    175,
                                                                    175,
                                                                    175),
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          //skip previous button
                                                          IconButton(
                                                            icon: const Icon(Icons
                                                                .skip_previous),
                                                            color: const Color
                                                                    .fromARGB(
                                                                255,
                                                                175,
                                                                175,
                                                                175),
                                                            iconSize: 42.0,
                                                            onPressed: mediaItem ==
                                                                    queue.first
                                                                ? null
                                                                : _audioHandler
                                                                    .skipToPrevious,
                                                          ),
                                                          // Play/pause/stop buttons.
                                                          StreamBuilder<
                                                              PlaybackState>(
                                                            stream: _audioHandler
                                                                .playbackState,
                                                            // .map((state) => state.playing)
                                                            // .distinct(),
                                                            builder: (context,
                                                                snapshot) {
                                                              final playerState =
                                                                  snapshot.data;
                                                              final processingState =
                                                                  playerState
                                                                      ?.processingState;
                                                              final playing =
                                                                  playerState
                                                                          ?.playing ??
                                                                      false;
                                                              // final playing = snapshot.data ?? false;
                                                              if (processingState ==
                                                                      AudioProcessingState
                                                                          .loading ||
                                                                  processingState ==
                                                                      AudioProcessingState
                                                                          .buffering) {
                                                                return Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  width: 42.0,
                                                                  height: 42.0,
                                                                  child:
                                                                      const CircularProgressIndicator(),
                                                                );
                                                              } else {
                                                                return Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    if (playing)
                                                                      pauseButton()
                                                                    else
                                                                      playButton(),
                                                                    // stopButton(),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          //skip next button
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons
                                                                    .skip_next),
                                                            color: const Color
                                                                    .fromARGB(
                                                                255,
                                                                175,
                                                                175,
                                                                175),
                                                            iconSize: 42.0,
                                                            onPressed: mediaItem ==
                                                                    queue.last
                                                                ? null
                                                                : _audioHandler
                                                                    .skipToNext,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ))
                                            ]),
                                    ],
                                  );
                                },
                              ),

                              // A seek bar.
                              StreamBuilder<MediaItem>(
                                stream: _audioHandler.mediaItem,
                                builder: (context, snapshot) {
                                  final mediaItem = snapshot.data;
                                  if (mediaItem != null) {
                                    return StreamBuilder<Duration>(
                                        stream: AudioService.position,
                                        builder: (context, snapshot) {
                                          final currentPosition = snapshot.data;
                                          return SeekBar(
                                            duration: mediaItem.duration ??
                                                Duration.zero,
                                            position: currentPosition ??
                                                Duration.zero,
                                            onChangeEnd: (newPosition) {
                                              _audioHandler.seek(newPosition);
                                            },
                                          );
                                        });
                                  } else {
                                    return Container();
                                  }
                                },
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: StreamBuilder<List<MediaItem>>(
                                  stream: _audioHandler.queue,
                                  builder: (context, snapshot) {
                                    final queue = snapshot.data;
                                    final mediaItem =
                                        _audioHandler.mediaItem.value;
                                    return NotificationListener<
                                        OverscrollNotification>(
                                      onNotification:
                                          (OverscrollNotification value) {
                                        if (value.overscroll < 0 &&
                                            controller.offset +
                                                    value.overscroll <=
                                                0) {
                                          if (controller.offset != 0) {
                                            controller.jumpTo(0);
                                          }
                                          return true;
                                        }
                                        if (controller.offset +
                                                value.overscroll >=
                                            controller
                                                .position.maxScrollExtent) {
                                          if (controller.offset !=
                                              controller
                                                  .position.maxScrollExtent) {
                                            controller.jumpTo(controller
                                                .position.maxScrollExtent);
                                          }
                                          return true;
                                        }
                                        controller.jumpTo(controller.offset +
                                            value.overscroll);
                                        return true;
                                      },
                                      child: ListView(
                                        children: [
                                          if (queue != null && queue.isNotEmpty)
                                            for (var i = 0;
                                                i < queue.length;
                                                i++)
                                              Container(
                                                key: ValueKey(queue[i]),
                                                child: Material(
                                                  color: (mediaItem != null &&
                                                          mediaItem.id ==
                                                              queue[i].id)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.black12,
                                                  child: ListTile(
                                                    title: Text(queue[i].title,
                                                        style: TextStyle(
                                                          color: (mediaItem !=
                                                                      null &&
                                                                  mediaItem
                                                                          .id ==
                                                                      queue[i]
                                                                          .id)
                                                              ? Colors.black
                                                              : const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  175,
                                                                  175,
                                                                  175),
                                                        )),
                                                    onTap: () {
                                                      _audioHandler
                                                          .skipToQueueItem(i);
                                                      // AudioService.customAction(
                                                      //     'updateMedia',
                                                      //     queue[i].id);
                                                    },
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  ElevatedButton startButton(String label, VoidCallback onPressed) =>
      ElevatedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: const Icon(Icons.play_arrow),
        color: const Color.fromARGB(255, 175, 175, 175),
        iconSize: 42.0,
        onPressed: _audioHandler.play,
      );

  IconButton pauseButton() => IconButton(
        icon: const Icon(Icons.pause),
        color: const Color.fromARGB(255, 175, 175, 175),
        iconSize: 42.0,
        onPressed: _audioHandler.pause,
      );

  IconButton stopButton() => IconButton(
        icon: const Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: _audioHandler.stop,
      );
}
