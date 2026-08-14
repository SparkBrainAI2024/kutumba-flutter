import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:kutumba/components/audio_service/seekbar.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/components/loader.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/models/track.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/services/service_locator.dart';
import 'package:kutumba/utils/app_url.dart';

import '../utils/user_preferences.dart';

class Playlist extends StatefulWidget {
  final Album album;

  const Playlist(
    this.album, {
    super.key,
  });

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  late Album album;

  bool loading = true;

  final ApiService _api = ApiService();

  late String? token = '';

  final ScrollController controller = ScrollController();

  final AudioHandler _audioHandler = getIt<AudioHandler>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      token = await UserPreferences().getToken();

      // Clear existing queue.
      final List<MediaItem> existingQueue = List<MediaItem>.from(
        _audioHandler.queue.value,
      );

      for (final MediaItem mediaItem in existingQueue) {
        await _audioHandler.removeQueueItem(
          mediaItem,
        );
      }

      album = widget.album;

      album.track = <Track>[];

      final Map<String, dynamic> jsonResult = await _api.fetchTracks(album.id);

      if (jsonResult['status'] == true) {
        final dynamic tracks = jsonResult['data'];

        if (tracks is List) {
          album.track = tracks
              .map<Track>(
                (dynamic item) => item is Track
                    ? item
                    : Track.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
              )
              .toList();
        }
      } else {
        if (!mounted) {
          return;
        }

        // Keep the same behavior as your original code.
        // You can display an API error here if required.
      }

      // ------------------------------------------------
      // TEST DATA
      // Remove this section when using real API tracks.
      // ------------------------------------------------
      // album.track = List<Track>.generate(
      //   10,
      //   (int index) {
      //     final int songNumber = index + 1;
      //
      //     return Track.fromJson({
      //       'id': songNumber,
      //       'title': 'Song $songNumber',
      //       'album_id': album.id.toString(),
      //       'music_url': 'https://www.soundhelix.com/examples/mp3/'
      //           'SoundHelix-Song-$songNumber.mp3',
      //     });
      //   },
      // );

      // ------------------------------------------------
      // Add tracks to audio queue.
      // ------------------------------------------------
      final List<MediaItem> mediaItems = album.track.map(
        (Track track) {
          return MediaItem(
            id: track.id.toString(),
            album: album.name,
            title: track.title,
            extras: <String, dynamic>{
              'url': track.musicUrl,
              'apikey': token,
            },
          );
        },
      ).toList();

      await _audioHandler.addQueueItems(
        mediaItems,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Playlist initialization error: $e',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> _handleBackNavigation() async {
    await _audioHandler.stop();
    return true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loader();
    }

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) {
            return;
          }

          final bool shouldPop = await _handleBackNavigation();

          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              _buildAlbumInformation(),
              _buildAudioPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumInformation() {
    return Padding(
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
                  AppUrl.baseURL + (album.coverPhoto ?? ''),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            album.name ?? '',
            style: const TextStyle(
              color: Color.fromARGB(
                255,
                175,
                175,
                175,
              ),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildAlbumRow(
            'Artist:',
            album.artist ?? '',
          ),
          const SizedBox(height: 10),
          _buildAlbumRow(
            'Release Date:',
            album.releaseDate ?? '',
          ),
          const SizedBox(height: 10),
          _buildAlbumRow(
            'Label:',
            album.label ?? '',
          ),
          const SizedBox(height: 10),
          _buildAlbumRow(
            'Tracks:',
            '${album.track.length} tracks',
            secondFlex: 3,
          ),
          const SizedBox(height: 10),
          _buildAlbumRow(
            'Duration:',
            album.totalTime ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumRow(
    String label,
    String value, {
    int secondFlex = 3,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 2,
          child: SizedBox(),
        ),
        Expanded(
          flex: secondFlex,
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color.fromARGB(
                      255,
                      175,
                      175,
                      175,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color.fromARGB(
                      255,
                      175,
                      175,
                      175,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Center(
      child: StreamBuilder<PlaybackState>(
        stream: _audioHandler.playbackState,
        builder: (
          BuildContext context,
          AsyncSnapshot<PlaybackState> snapshot,
        ) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const SizedBox();
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCurrentTrack(),
              _buildSeekBar(),
              _buildQueue(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTrack() {
    return StreamBuilder<MediaItem?>(
      stream: _audioHandler.mediaItem,
      builder: (
        BuildContext context,
        AsyncSnapshot<MediaItem?> snapshot,
      ) {
        final MediaItem? mediaItem = snapshot.data;

        final List<MediaItem> queue = _audioHandler.queue.value;

        if (queue.isEmpty) {
          return const SizedBox();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Image.network(
                    AppUrl.baseURL + (album.coverPhoto ?? ''),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const SizedBox(
                        height: 100,
                        width: 100,
                        child: Icon(
                          Icons.music_note,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _getTrackTitle(mediaItem),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        letterSpacing: 1,
                        color: Color.fromARGB(
                          255,
                          175,
                          175,
                          175,
                        ),
                      ),
                    ),
                  ),
                  _buildPlaybackControls(
                    mediaItem,
                    queue,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTrackTitle(
    MediaItem? mediaItem,
  ) {
    if (mediaItem == null) {
      return '';
    }

    final String title = mediaItem.title.trim();

    final String artist = (mediaItem.artist ?? '').trim();

    if (artist.isEmpty) {
      return title;
    }

    return '$title - $artist';
  }

  Widget _buildPlaybackControls(
    MediaItem? mediaItem,
    List<MediaItem> queue,
  ) {
    final bool isFirst =
        mediaItem == null || queue.isEmpty || mediaItem.id == queue.first.id;

    final bool isLast =
        mediaItem == null || queue.isEmpty || mediaItem.id == queue.last.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
          ),
          color: const Color.fromARGB(
            255,
            175,
            175,
            175,
          ),
          iconSize: 42,
          onPressed: isFirst
              ? null
              : () {
                  _audioHandler.skipToPrevious();
                },
        ),
        StreamBuilder<PlaybackState>(
          stream: _audioHandler.playbackState,
          builder: (
            BuildContext context,
            AsyncSnapshot<PlaybackState> snapshot,
          ) {
            final PlaybackState? state = snapshot.data;

            final AudioProcessingState? processingState =
                state?.processingState;

            final bool playing = state?.playing ?? false;

            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8),
                width: 42,
                height: 42,
                child: const CircularProgressIndicator(),
              );
            }

            if (playing) {
              return pauseButton();
            }

            return playButton();
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
          ),
          color: const Color.fromARGB(
            255,
            175,
            175,
            175,
          ),
          iconSize: 42,
          onPressed: isLast
              ? null
              : () {
                  _audioHandler.skipToNext();
                },
        ),
      ],
    );
  }

  Widget _buildSeekBar() {
    return StreamBuilder<MediaItem?>(
      stream: _audioHandler.mediaItem,
      builder: (
        BuildContext context,
        AsyncSnapshot<MediaItem?> snapshot,
      ) {
        final MediaItem? mediaItem = snapshot.data;

        if (mediaItem == null) {
          return const SizedBox();
        }

        return StreamBuilder<Duration>(
          stream: AudioService.position,
          builder: (
            BuildContext context,
            AsyncSnapshot<Duration> snapshot,
          ) {
            final Duration position = snapshot.data ?? Duration.zero;

            final Duration duration = mediaItem.duration ?? Duration.zero;

            final Duration safePosition =
                position > duration ? duration : position;

            return SeekBar(
              duration: duration,
              position: safePosition,
              onChangeEnd: (Duration newPosition) {
                _audioHandler.seek(
                  newPosition,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQueue() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      child: StreamBuilder<List<MediaItem>>(
        stream: _audioHandler.queue,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<MediaItem>> snapshot,
        ) {
          final List<MediaItem> queue = snapshot.data ?? <MediaItem>[];

          final MediaItem? mediaItem = _audioHandler.mediaItem.value;

          if (queue.isEmpty) {
            return const Center(
              child: Text(
                'No tracks available',
                style: TextStyle(
                  color: Color.fromARGB(
                    255,
                    175,
                    175,
                    175,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            controller: ScrollController(),
            itemCount: queue.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              final MediaItem item = queue[index];

              final bool isCurrent =
                  mediaItem != null && mediaItem.id == item.id;

              return Material(
                color:
                    isCurrent ? Theme.of(context).primaryColor : Colors.black12,
                child: ListTile(
                  key: ValueKey(item.id),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.black
                          : const Color.fromARGB(
                              255,
                              175,
                              175,
                              175,
                            ),
                    ),
                  ),
                  trailing: isCurrent
                      ? const Icon(
                          Icons.equalizer,
                          color: Colors.black,
                        )
                      : null,
                  onTap: () {
                    _audioHandler.skipToQueueItem(
                      index,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconButton playButton() {
    return IconButton(
      icon: const Icon(
        Icons.play_arrow,
      ),
      color: const Color.fromARGB(
        255,
        175,
        175,
        175,
      ),
      iconSize: 42,
      onPressed: () {
        _audioHandler.play();
      },
    );
  }

  IconButton pauseButton() {
    return IconButton(
      icon: const Icon(
        Icons.pause,
      ),
      color: const Color.fromARGB(
        255,
        175,
        175,
        175,
      ),
      iconSize: 42,
      onPressed: () {
        _audioHandler.pause();
      },
    );
  }

  IconButton stopButton() {
    return IconButton(
      icon: const Icon(
        Icons.stop,
      ),
      iconSize: 64,
      onPressed: () {
        _audioHandler.stop();
      },
    );
  }
}
