import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '/src/base/constants.dart';

//TODO: check type safe for this as battery info +
//TODO: throw error from native
class AudioWaveformsInterface {
  AudioWaveformsInterface._();

  static AudioWaveformsInterface instance = AudioWaveformsInterface._();

  static const MethodChannel _methodChannel =
      MethodChannel(Constants.methodChannelName);

  static const EventChannel _eventChannel =
      EventChannel(Constants.durationEventChannel);

  ///platform call to start recording
  Future<bool> record(int audioFormat, int sampleRate, [String? path]) async {
    final _isRecording = await _methodChannel.invokeMethod(
        Constants.startRecording,
        Platform.isIOS
            ? {
                Constants.path: path,
                Constants.codec: audioFormat,
                Constants.sampleRate: sampleRate,
              }
            : null);
    return _isRecording ?? false;
  }

  ///platform call to initialise the recorder.
  ///This method is only required for Android platform
  Future<bool> initRecorder(
      String? path, int audioFormat, int sampleRate) async {
    final initialized = await _methodChannel.invokeMethod(
      Constants.initRecorder,
      {
        Constants.path: path,
        Constants.codec: audioFormat,
        Constants.sampleRate: sampleRate,
      },
    );
    return initialized ?? false;
  }

  ///platform call to pause recording
  Future<bool?> pause() async {
    final _isRecording =
        await _methodChannel.invokeMethod(Constants.pauseRecording);
    return _isRecording;
  }

  ///platform call to stop recording
  Future<String?> stop() async {
    final _isRecording =
        await _methodChannel.invokeMethod(Constants.stopRecording);
    return _isRecording;
  }

  ///platform call to resume recording.
  ///This method is only required for Android platform
  Future<bool> resume() async {
    final _isRecording =
        await _methodChannel.invokeMethod(Constants.resumeRecording);
    return _isRecording ?? false;
  }

  ///platform call to get decibel
  Future<double?> getDecibel() async {
    var db = await _methodChannel.invokeMethod(Constants.getDecibel);
    return db;
  }

  ///platform call to check microphone permission
  Future<bool> checkPermission() async {
    var hasPermission =
        await _methodChannel.invokeMethod(Constants.checkPermission);
    return hasPermission ?? false;
  }

  Future<Uint8List?> readAudioFile(String path) async {
    var result = await _methodChannel.invokeMethod(
      Constants.convertToBytes,
      {
        Constants.path: path,
      },
    );
    return result;
  }

  Future<bool> preparePlayer(String path, [double? volume]) async {
    var result = await _methodChannel.invokeMethod(Constants.preparePlayer, {
      Constants.path: path,
      Constants.volume: volume,
    });

    return result ?? false;
  }

  Future<Map> getMetaData(String path) async {
    var result = await _methodChannel.invokeMethod(Constants.getMetaData, {
      Constants.path: path,
    });

    return result;
  }

  Future<bool> startPlayer(bool seekToStart) async {
    var result = await _methodChannel.invokeMethod(
        Constants.startPlayer, {Constants.seekToStart: seekToStart});
    return result ?? false;
  }

  Future<bool> stopPlayer() async {
    var result = await _methodChannel.invokeMethod(Constants.stopPlayer);
    return result ?? false;
  }

  Future<bool> pausePlayer() async {
    var result = await _methodChannel.invokeMethod(Constants.pausePlayer);
    return result ?? false;
  }

  Future<int?> getDuration(int durationType) async {
    var duration = await _methodChannel.invokeMethod(Constants.getDuration, {
      Constants.durationType: durationType,
    });
    return duration;
  }

  Future<bool> setVolume(double volume) async {
    var result = await _methodChannel.invokeMethod(Constants.setVolume, {
      Constants.volume: volume,
    });
    return result ?? false;
  }

  Future<bool> seekTo(int progress) async {
    //TODO:test from here
    var result = await _methodChannel
        .invokeMethod(Constants.seekTo, {Constants.progress: progress});
    return result ?? false;
  }

  Stream<dynamic> listenToDurationStream() {
    return _eventChannel.receiveBroadcastStream();
  }
}