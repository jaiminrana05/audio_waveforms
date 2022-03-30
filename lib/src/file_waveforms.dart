import 'package:audio_waveforms/src/file_waveform_painter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../audio_waveforms.dart';

class FileWaveforms extends StatefulWidget {
  final Size size;
  final PlayerController playerController;
  final WaveStyle waveStyle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final Color? backgroundColor;
  final bool enableGesture;

  const FileWaveforms({
    Key? key,
    required this.size,
    required this.playerController,
    this.waveStyle = const WaveStyle(),
    this.enableGesture = false,
    this.padding,
    this.margin,
    this.decoration,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<FileWaveforms> createState() => _FileWaveformsState();
}

class _FileWaveformsState extends State<FileWaveforms> {
  int _currentDuration = 0;

  @override
  void initState() {
    super.initState();
    widget.playerController.addListener(() {
      if (widget.playerController.playerState == PlayerState.playing) {
        widget.playerController.durationStreamController.stream.listen((event) {
          if (event != null) _currentDuration = event;
          setState(() {});
        });
      }
      setState(() {});
    });
  }

  final double _multiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.playerController.bufferData != null) {
      return GestureDetector(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: FileWaveformsPainter(
              waveData: widget.playerController.bufferData!.toList(),
              multiplier: _multiplier,
              density: MediaQuery.of(context).devicePixelRatio,
              maxDuration: widget.playerController.maxDuration,
              currentDuration: _currentDuration,
            ),
            size: widget.size,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
