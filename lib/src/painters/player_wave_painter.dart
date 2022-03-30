import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Gradient;

///Referenced from https://stackoverflow.com/questions/38744579/show-waveform-of-audio
class FileWaveformsPainter extends CustomPainter {
  List<int> waveData;
  double multiplier;
  double density;
  int maxDuration, currentDuration;
  LinearGradient? linearGradient;
  double animValue;
  double currentSeekPostion;
  bool showSeekLine;
  double scaleFactor;

  FileWaveformsPainter({
    required this.waveData,
    required this.multiplier,
    required this.density,
    required this.maxDuration,
    required this.currentDuration,
    required this.animValue,
    required this.currentSeekPostion,
    required this.showSeekLine,
    required this.scaleFactor,
    this.linearGradient,
  });

  Paint wavePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  Paint liveAudioPaint = Paint()
    ..color = Colors.deepOrange
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  Paint seeklinePaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  int visualizerHieght = 28;
  double denseness = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    _updatePlayerPercent(size);
    _drawWave(size, canvas);
    if (showSeekLine) _drawSeekLine(size, canvas);
  }

  @override
  bool shouldRepaint(FileWaveformsPainter oldDelegate) => true;

  void _drawSeekLine(Size size, Canvas canvas) {
    canvas.drawLine(
      Offset(denseness, 0),
      Offset(denseness, size.height),
      seeklinePaint,
    );
  }

  void _drawWave(Size size, Canvas canvas) {
    double totalBarsCount = size.width / dp(3);
    int samplesCount = (waveData.length * 8 / 5).ceil();
    double samplesPerBar = samplesCount / totalBarsCount;
    double barCounter = 0;
    int nextBarNum = 0;
    int y = (size.height.toInt() - dp(visualizerHieght.toDouble()));
    int barNum = 0;
    int lastBarNum;
    int drawBarCount;
    int byteSize = 8;
    int byte;
    for (int i = 0; i < samplesCount; i++) {
      if (i != nextBarNum) {
        continue;
      }
      drawBarCount = 0;
      lastBarNum = nextBarNum;

      while (lastBarNum == nextBarNum) {
        barCounter += samplesPerBar;
        nextBarNum = barCounter.toInt();
        drawBarCount++;
      }
      int bitPointer = i * 5;
      double byteNum = bitPointer / byteSize;
      double byteBitOffset = bitPointer - byteNum * byteSize;
      int currentByteCount = (byteSize - byteBitOffset).toInt();
      int nextByteRest = 5 - currentByteCount;
      byte = (waveData[byteNum.toInt()].toInt() >> byteBitOffset.toInt() &
          ((2 << min(5, currentByteCount) - 1)) - 1);
      if (nextByteRest > 0) {
        byte <<= nextByteRest;
        byte |= waveData[byteNum.toInt() + 1].toInt() &
            ((2 << (nextByteRest - 1)) - 1);
      }
      for (int j = 0; j < drawBarCount; j++) {
        int x = barNum * dp(3);
        double left = x.toDouble();
        double top = y.toDouble() +
            dp(visualizerHieght - max(1, visualizerHieght * byte / 31));
        double bottom =
            y.toDouble() + dp(visualizerHieght.toDouble()).toDouble();
        if (x < denseness && x + dp(2) < denseness) {
          print('here 1 ');
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left, size.height / 2 + (bottom - top) * scaleFactor),
              liveAudioPaint);
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left, size.height / 2 + (top - bottom) * scaleFactor),
              liveAudioPaint);
        } else {
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left,
                  size.height / 2 + ((bottom - top) * animValue) * scaleFactor),
              wavePaint);
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left,
                  size.height / 2 + ((top - bottom) * animValue) * scaleFactor),
              wavePaint);
          if (x < denseness) {
            print('here 2');
            canvas.drawLine(
                Offset(left, size.height / 2),
                Offset(left, size.height / 2 + (bottom - top) * scaleFactor),
                liveAudioPaint);
            canvas.drawLine(
                Offset(left, size.height / 2),
                Offset(left, size.height / 2 + (top - bottom) * scaleFactor),
                liveAudioPaint);
          }
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left,
                  size.height / 2 + ((bottom - top) * animValue) * scaleFactor),
              wavePaint);
          canvas.drawLine(
              Offset(left, size.height / 2),
              Offset(left,
                  size.height / 2 + ((top - bottom) * animValue) * scaleFactor),
              wavePaint);
        }
        barNum++;
      }
    }
  }

  void _updatePlayerPercent(Size size) {
    denseness = (size.width * scrubberProgress()).ceilToDouble();
    if (denseness < 0) {
      denseness = 0;
    } else if (denseness > size.width) {
      denseness = size.width;
    }
  }

  int dp(double value) {
    return (density / 2 * value).ceil();
  }

  double scrubberProgress() {
    if (maxDuration == 0) return 0;
    return currentDuration / maxDuration;
  }
}
