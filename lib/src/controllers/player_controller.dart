import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import '../base/audio_waveforms_interface.dart';

class PlayerController extends ChangeNotifier {
  Uint8List? _bufferData;

  Uint8List? get bufferData => _bufferData;

  PlayerState _playerState = PlayerState.stopped;

  PlayerState get playerState => _playerState;

  String? _audioFilePath;

  Timer? timer;

  StreamController<int?> durationStreamController = StreamController<int?>();

  StreamSubscription<int?>? _durationStreamSubscribtion;

  StreamSubscription? durationStreamSubscribtion;

  int _maxDuration = 0;

  int get maxDuration => _maxDuration;

  bool _seekToStart = true;

  ///Reads bytes from audio file
  Future<void> _readAudioFile(String path) async {
    _audioFilePath = path;
    File file = File(path);
    if (file.existsSync()) {
      var bytes = await file.readAsBytes();
      _bufferData = bytes;
      if (_bufferData != null) {
        _playerState = PlayerState.readingComplete;
      }else {
        throw "Can't read given audio file";
      }
      notifyListeners();
    } else {
      throw "Please provide a valid file path";
    }
  }

  ///Call this to prepare player with optional [valume] parameters (has to be between 0.0 to 1.0).
  ///
  ///It first reads bytes from audio file so as soon as it completes it will show waveform
  /// and then prepares audio player.
  ///
  ///[playerState] has to be PlayerState.readingComplete otherwise throws [Exception].
  ///
  ///This behavior is set to ensure that player is only re-initialised for new audio file.
  Future<void> preparePlayer(String path, [double? volume]) async {
    await _readAudioFile(path);
    if ((_playerState == PlayerState.readingComplete &&
        _audioFilePath != null)) {
      final isPrepared =
          await AudioWaveformsInterface.instance.preparePlayer(path, volume);
      if (isPrepared) {
        _maxDuration = await getDuration();
        _playerState = PlayerState.initialized;
      }
      notifyListeners();
    } else {
      throw "Can not call without reading new audio file";
    }
  }

  ///when playing audio is finished player will be seeked to [start]. To change
  ///this behaviour pass false for [seekToStart] parameter and player position will
  ///stay at last
  Future<void> startPlayer([bool? seekToStart]) async {
    _seekToStart = seekToStart ?? true;
    final isStarted =
        await AudioWaveformsInterface.instance.startPlayer(seekToStart ?? true);
    if (isStarted) {
      _playerState = PlayerState.playing;
      _startDurationStream();
    }
    notifyListeners();
  }

  Future<void> pausePlayer() async {
    timer?.cancel();
    _durationStreamSubscribtion?.pause();
    final isPaused = await AudioWaveformsInterface.instance.pausePlayer();
    if (isPaused) {
      _playerState = PlayerState.paused;
    }
    notifyListeners();
  }

  Future<void> resumePlayer() async {
    final isResumed =
        await AudioWaveformsInterface.instance.startPlayer(_seekToStart);
    if (isResumed) {
      durationStreamSubscribtion?.resume();
      _playerState = PlayerState.resumed;
    }
    notifyListeners();
  }

  Future<void> stopPlayer() async {
    timer?.cancel();
    await durationStreamSubscribtion?.cancel();
    final isStopped = await AudioWaveformsInterface.instance.stopPlayer();
    if (isStopped) {
      _playerState = PlayerState.stopped;
    }
    notifyListeners();
  }

  ///Sets valume for this player. Dosen't throw Exception.
  /// Returns false if it couldn't set the [volume].
  ///
  ///Volume has to be between 0.0 to 1.0.
  Future<bool> setVolume(double leftVolume) async {
    final result = await AudioWaveformsInterface.instance.setVolume(leftVolume);
    return result;
  }

  ///Return [maximum] duration for [DurationType.max] and
  /// [current] duration for [DurationType.current] for playing content.
  ///The duration is in milliseconds, if no duration is available -1 is returned.
  ///
  /// Default is Duration.max.
  Future<int> getDuration([DurationType? durationType]) async {
    final duration = await AudioWaveformsInterface.instance
        .getDuration(durationType?.index ?? 1);
    return duration ?? -1;
  }

  ///Moves the media to specified time position. pass progress parameter in milliseconds.
  ///
  /// There is at most one active seekTo processed at any time.
  ///
  /// If there is a to-be-completed seekTo, new seekTo requests will be queued in such a way that only the last request is kept.
  ///
  /// When current seekTo is completed, the queued request will be processed if that request is different from just-finished seekTo operation,
  ///
  /// Minimum Android O is required to use this funtion otherwise nothing happens.
  Future<void> seekTo(int progress) async {
    if (_playerState == PlayerState.playing) {
      await AudioWaveformsInterface.instance.seekTo(progress);
    }
  }

  void _startDurationStream() {
    durationStreamSubscribtion = AudioWaveformsInterface.instance
        .listenToDurationStream()
        .listen((currentDuration) {
      durationStreamController.add(currentDuration);
    });
    durationStreamController.stream.asBroadcastStream();
    // durationStreamController.stream.asBroadcastStream();
    // timer = Timer.periodic(
    //   const Duration(seconds: 1),
    //   (timer) async {
    //     var duration = await getDuration(DurationType.current);
    //     durationStreamController.add(duration);
    //   },
    // );
  }

  Stream<dynamic> listenToCurrentDurationStream() {
    return AudioWaveformsInterface.instance.listenToDurationStream();
  }
}
