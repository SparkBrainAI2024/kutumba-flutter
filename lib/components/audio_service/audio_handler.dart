import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'Asteriskhubs.Kutumba.audio',
      androidNotificationChannelName: 'Kutumba',
      androidNotificationIcon: 'mipmap/ic_launcher',
      notificationColor: Color(0xFF2196f3),
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer(
    useProxyForRequestHeaders: false,
  );
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;

      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          repeatMode: const {
            LoopMode.off: AudioServiceRepeatMode.none,
            LoopMode.one: AudioServiceRepeatMode.one,
            LoopMode.all: AudioServiceRepeatMode.all,
          }[_player.loopMode]!,
          shuffleMode: _player.shuffleModeEnabled
              ? AudioServiceShuffleMode.all
              : AudioServiceShuffleMode.none,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      int? index = _player.currentIndex;
      final newQueue = List<MediaItem>.from(queue.value);

      if (index == null || newQueue.isEmpty) return;

      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices?[index];
      }

      if (index == null) return;

      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);

      newQueue[index] = newMediaItem;

      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;

      if (index == null || playlist.isEmpty) return;

      int newIndex = index;

      if (_player.shuffleModeEnabled) {
        newIndex = _player.shuffleIndices?[index] ?? index;
      }

      mediaItem.add(playlist[newIndex]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;

      if (sequence == null || sequence.isEmpty) return;

      final items = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(items);
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSources = mediaItems.map(_createAudioSource).toList();

    await _playlist.addAll(audioSources);

    final newQueue = List<MediaItem>.from(queue.value)..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);

    await _playlist.add(audioSource);

    final newQueue = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final url = mediaItem.extras?['url'] as String?;
    final apiKey = mediaItem.extras?['apikey'] as String?;

    debugPrint('====================================');
    debugPrint('Creating AudioSource');
    debugPrint('MediaItem ID: ${mediaItem.id}');
    debugPrint('Title: ${mediaItem.title}');
    debugPrint('URL: $url');
    debugPrint('API Key exists: ${apiKey}');
    debugPrint('====================================');

    if (url == null || apiKey == null) {
      throw Exception("MediaItem extras must contain 'url' and accessed");
    }

    return AudioSource.uri(
      Uri.parse(url),
      headers: {
        'Authorization': "Bearer " + apiKey,
      },
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _playlist.removeAt(index);

    final newQueue = List<MediaItem>.from(queue.value)..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;

    int newIndex = index;

    if (_player.shuffleModeEnabled) {
      newIndex = _player.shuffleIndices?[index] ?? index;
    }

    await _player.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;

      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;

      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      await _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      await _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      return super.stop();
    }
    return null;
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
