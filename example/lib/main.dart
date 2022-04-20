import 'dart:io';
import 'dart:ui' as ui show Gradient;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Audio Waveforms',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final RecorderController recorderController;
  late final PlayerController playerController;
  String? path;
  String? musicFile;

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController()
      ..encoder = Encoder.aac
      ..sampleRate = 16000;
    playerController = PlayerController();
    Future.delayed(const Duration(seconds: 10)).then((value) {
      _pickFile();
    });
  }

  void _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    ScrollController();
    if (result != null) {
      musicFile = result.files.single.path;
    } else {
      debugPrint("File not picked");
    }
  }

  void _getDir() async {
    final dir = await getApplicationDocumentsDirectory();
    musicFile = "${dir.path}/music.aac";
  }

  @override
  void dispose() {
    recorderController.disposeFunc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int lastIndex = musicFile.toString().lastIndexOf("/");
    int? totalLenght = musicFile?.length;
    return Scaffold(
      backgroundColor: const Color(0xFF394253),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          playerController.audioMetaData != null
              ? Column(
                  children: [
                    playerController.audioMetaData?.imageData != null
                        ? Image.memory(
                            playerController.audioMetaData!.imageData!,
                            scale: 6,
                          )
                        : const SizedBox.shrink(),
                    Text(musicFile
                        .toString()
                        .substring(lastIndex + 1, totalLenght)),
                    Text(
                      playerController.audioMetaData?.genre ?? " GENRE",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      playerController.audioMetaData?.albumTitle ??
                          "Album TITLE",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      playerController.audioMetaData?.artist ?? "Artist",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      playerController.audioMetaData?.title ?? "Title",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      Platform.isAndroid
                          ? playerController.audioMetaData?.year ?? "YEAR"
                          : playerController.audioMetaData?.releaseDate ??
                              "RELEASE-DATE",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
          AudioWaveforms(
            enableGesture: true,
            size: Size(MediaQuery.of(context).size.width, 100.0),
            waveController: recorderController,
            margin: const EdgeInsets.all(20.0),
            waveStyle: WaveStyle(
              waveColor: Colors.white,
              middleLineColor: Colors.white,
              durationLinesColor: Colors.white,
              durationLinesHeight: 8.0,
              extendWaveform: true,
              showMiddleLine: false,
              labelSpacing: 8.0,
              showDurationLabel: true,
              durationStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              gradient: ui.Gradient.linear(
                const Offset(70, 50),
                Offset(MediaQuery.of(context).size.width / 2, 0),
                [Colors.red, Colors.green],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFF615766),
                  Color(0xFF394253),
                  Color(0xFF412B4F),
                ],
                begin: Alignment.bottomLeft,
                stops: <double>[0.2, 0.45, 0.8],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xff2D3548), Color(0xff151922)],
                    stops: [0.1, 0.45],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () {
                        recorderController.record(musicFile);
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.mic),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: recorderController.pause,
                      color: Colors.white,
                      icon: const Icon(Icons.pause),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async {
                        path = await recorderController.stop(false);
                        setState(() {});
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.stop),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: recorderController.refresh,
                      color: Colors.white,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xff2D3548), Color(0xff151922)],
                    stops: [0.1, 0.45],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async {
                        _pickFile();

                        await playerController.getMetaData(musicFile!);
                      },
                      color: Colors.red,
                      icon: const Icon(Icons.library_music),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async {
                        await playerController.preparePlayer(musicFile!, 1.0);

                        await playerController.getMetaData(musicFile!);

                        setState(() {});
                      },
                      color: Colors.green,
                      icon: const Icon(Icons.library_music),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async {
                        await playerController.startPlayer(false);
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async {
                        await playerController.pausePlayer();
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.pause),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async =>
                          await playerController.stopPlayer(),
                      color: Colors.white,
                      icon: const Icon(Icons.stop),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () async =>
                          await playerController.resumePlayer(),
                      color: Colors.white,
                      icon: const Icon(Icons.sync),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          AudioFileWaveforms(
            size: Size(MediaQuery.of(context).size.width - 50, 100.0),
            playerController: playerController,
          )
        ],
      ),
    );
  }
}
