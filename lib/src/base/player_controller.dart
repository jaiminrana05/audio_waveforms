import 'dart:async';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import 'audio_waveforms_interface.dart';

class PlayerController extends ChangeNotifier {
  Uint8List? _bufferData;

  Uint8List? get bufferData => _bufferData;

  PlayerState _playerState = PlayerState.stopped;

  PlayerState get playerState => _playerState;

  String? _audioFilePath;

  Timer? timer;

  StreamController<int?> durationStreamController = StreamController<int?>();

  int _maxDuration = 0;

  int get maxDuration => _maxDuration;


  //TODO: remove this and do it on flutter side
  ///Reads bytes from audio file
  Future<void> _readAudioFile(String path) async {
    _audioFilePath = path;
    final bytes = await AudioWaveformsInterface.instance.readAudioFile(path);
    _bufferData = bytes;
    if (_bufferData != null) {
      _playerState = PlayerState.readingComplete;
    }
    notifyListeners();
  }

  ///Call this to prepare player with optional [valume] parameters (has to be between 0.0 to 1.0).
  ///
  ///It first reads bytes from audio file and then prepares audio player.
  ///
  ///[playerState] has to be PlayerState.readingComplete otherwise throws [Exception].
  ///
  ///This behavior is set to ensure that player is only re-initialised for new audio file.
  Future<void> preparePlayer(String path, [double? leftVolume, double? rightVolume]) async {
    await _readAudioFile(path);
    if (_playerState == PlayerState.readingComplete && _audioFilePath != null) {
      final isPrepared = await AudioWaveformsInterface.instance
          .preparePlayer(_audioFilePath!, leftVolume, rightVolume);
      if (isPrepared) {
        _maxDuration = await getDuration() ?? 0;
        _playerState = PlayerState.initialized;
      }
      notifyListeners();
    } else {
      throw "Can not call without reading new audio file";
    }
  }

  Future<void> startPlayer() async {
    final isStarted = await AudioWaveformsInterface.instance.startPlayer();
    if (isStarted) {
      _playerState = PlayerState.playing;
      _startDurationStream();
    }
    notifyListeners();
  }

  Future<void> pausePlayer() async {
    timer?.cancel();
    final isPaused = await AudioWaveformsInterface.instance.pausePlayer();
    if (isPaused) {
      _playerState = PlayerState.paused;

    }
    notifyListeners();
  }

  Future<void> stopPlayer() async {
    timer?.cancel();

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
  Future<bool> setVolume(double leftVolume, double rightVolume) async {
    final result =
        await AudioWaveformsInterface.instance.setVolume(leftVolume, rightVolume);
    return result;
  }

  ///Return maximum duration for Duration.max and current duration for Duration.current
  ///for the content.
  ///
  ///The duration in milliseconds, if no duration is available -1 is returned.
  ///
  /// Default is Duration.max.
  Future<int?> getDuration([DurationType? durationType]) async {
    final duration =
        await AudioWaveformsInterface.instance.getDuration(durationType?.index ?? 1);
    return duration;
    //TODO: make it nullable
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
    await AudioWaveformsInterface.instance.seekTo(progress);
  }

  void _startDurationStream() {
    durationStreamController.stream.asBroadcastStream();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        var duration = await getDuration(DurationType.current);
        durationStreamController.add(duration);
      },
    );
  }
  Stream<int> listenToCurrentDurationStream(){
   return AudioWaveformsInterface.instance.listenToDurationStream();
  }
}
