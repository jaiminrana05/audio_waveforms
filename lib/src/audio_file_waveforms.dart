import 'package:audio_waveforms/src/painters/player_wave_painter.dart';
import 'package:flutter/material.dart';
import '../audio_waveforms.dart';

class AudioFileWaveforms extends StatefulWidget {
  final Size size;
  final PlayerController playerController;
  final WaveStyle waveStyle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final Color? backgroundColor;
  final bool enableGesture;

  const AudioFileWaveforms({
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
  State<AudioFileWaveforms> createState() => _AudioFileWaveformsState();
}

class _AudioFileWaveformsState extends State<AudioFileWaveforms>
    with SingleTickerProviderStateMixin {
  int _currentDuration = 0;

  late AnimationController animationController;
  late Animation<double> animation;
  double _progress = 0.0;
  bool showSeekLine = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut))
      ..addListener(() {
        setState(() {
          _progress = animation.value;
        });
      });
    widget.playerController.addListener(() {
      if (widget.playerController.playerState == PlayerState.playing) {
        animationController.forward();
        widget.playerController.durationStreamController.stream.listen((event) {
          if (event != null) _currentDuration = event;
          showSeekLine = true;
          setState(() {});
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.playerController.removeListener(() { });
    super.dispose();
  }

  final double _multiplier = 1.0;
  double _currentSeekPositon = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.playerController.bufferData != null) {
      return GestureDetector(
        onHorizontalDragUpdate: _handleScrubberSeekUpdate,
        onHorizontalDragStart: _handleScrubberSeekStart,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: FileWaveformsPainter(
              waveData: widget.playerController.bufferData!.toList(),
              multiplier: _multiplier,
              density: MediaQuery.of(context).devicePixelRatio,
              maxDuration: widget.playerController.maxDuration,
              currentDuration: _currentDuration,
              animValue: _progress,
              currentSeekPostion: _currentSeekPositon,
              showSeekLine: showSeekLine,
              scaleFactor: widget.waveStyle.scaleFactor,
            ),
            size: widget.size,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _handleScrubberSeekUpdate(DragUpdateDetails details) {
    var proportion = details.localPosition.dx / widget.size.width;
    var seekPostion = widget.playerController.maxDuration * proportion;
    widget.playerController.seekTo(seekPostion.toInt());
    _currentSeekPositon = details.globalPosition.dx;
    setState(() {});
  }

  void _handleScrubberSeekStart(DragStartDetails details) {
    var proportion = details.localPosition.dx / widget.size.width;
    var seekPostion = widget.playerController.maxDuration * proportion;
    widget.playerController.seekTo(seekPostion.toInt());
    _currentSeekPositon = details.globalPosition.dx;
    setState(() {});
  }
}
