import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Gradient;

class FileWaveformsPainter extends CustomPainter {
  List<int> waveData;
  double multiplier;
  double density;
  int maxDuration, currentDuration;
  LinearGradient? linearGradient;

  FileWaveformsPainter({
    required this.waveData,
    required this.multiplier,
    required this.density,
    required this.maxDuration,
    required this.currentDuration,
    this.linearGradient,
  });

  Paint wavePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  Paint playingAudioPaint = Paint()
    ..color = Colors.deepOrange
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  int visualizerHieght = 28;
  double denseness = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(size, canvas);
  }

  @override
  bool shouldRepaint(FileWaveformsPainter oldDelegate) => true;

  void _drawWave(Size size, Canvas canvas) {
    playingAudioPaint.shader = _createGradientShaderRightToLeft(size);
    double totalBarsCount = size.width / dp(3);
    int samplesCount = (waveData.length * 8 / 5).ceil();
    double samplesPerBar = samplesCount / totalBarsCount;
    double barCounter = 0;
    int nextBarNum = 0;
    int y = (size.height.toInt() - dp(visualizerHieght.toDouble()));
    int barNum = 0;
    int lastBarNum; //
    int drawBarCount; //
    int byteSize = 8;
    int byte; //
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
        double right = x.toDouble() + dp(2);
        double bottom =
            y.toDouble() + dp(visualizerHieght.toDouble()).toDouble();
        if (x < denseness && x + dp(2) < denseness) {
        } else {
          canvas.drawLine(Offset(left, size.height),
              Offset(left, (size.height + (bottom - top) * 0.5)), wavePaint);
          canvas.drawLine(Offset(left, size.height),
              Offset(left, size.height + (top - bottom) * 0.5), wavePaint);
          //------------------------------------------------------------------------>
          canvas.clipPath(progressClip());
          canvas.drawLine(
              Offset(left, size.height),
              Offset(left, (size.height + (bottom - top) * 0.5)),
              playingAudioPaint);
          canvas.drawLine(
              Offset(left, size.height),
              Offset(left, size.height + (top - bottom) * 0.5),
              playingAudioPaint);
        }
      }
      barNum++;
    }
  }

  Path progressClip() {
    Path path = Path()

    ;
    return path;
  }

  int dp(double value) {
    return (density * value).ceil();
  }

  double scrubberProgress() {
    print(currentDuration / maxDuration);
    if (maxDuration == 0) return 0;
    return currentDuration / maxDuration;
  }

  Shader _createGradientShaderRightToLeft(Size size) {
    LinearGradient gradient = LinearGradient(
        colors: const [Colors.deepOrangeAccent, Colors.white],
        stops: [scrubberProgress(), 1.0]);

    Offset maxOffset = Offset(scrubberProgress(), size.height);
    return gradient.createShader(
        Rect.fromPoints(Offset(size.width, size.height), maxOffset));
  }
}
