import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class RunInferenceScreen extends StatefulWidget {
  const RunInferenceScreen({
    super.key,
    required this.videoFile,
  });

  final File videoFile;

  @override
  State<RunInferenceScreen> createState() => _RunInferenceScreenState();
}

class _RunInferenceScreenState extends State<RunInferenceScreen> {
  late VideoPlayerController _videoPlayerController;

  List<String> prediction = [];
  bool objectDetection = false;

  List<Image> images = [];

  late ClassificationModel classificationModel;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _loadModel();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future _loadModel() async {
    try {
      classificationModel = await PytorchLite.loadClassificationModel(
        "assets/models/best.pt",
        640,
        480,
        9,
        labelPath: "assets/labels/labels.txt",
      );
    } catch (e) {
      print("Error is $e");
    }
  }

  Future runModel() async {
    setState(() {
      images.clear();
      _videoPlayerController.seekTo(Duration.zero);
      _videoPlayerController.play();
    });

    int currentVideoTime = 0;

    final tempDir = await getTemporaryDirectory();

    while (_videoPlayerController.value.isPlaying) {
      final fileName = await VideoThumbnail.thumbnailFile(
          video: widget.videoFile.path,
          // thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 480,
          maxWidth: 640,
          quality: 75,
          timeMs: currentVideoTime);

      final uniqueFileName = 'frame_$currentVideoTime.png';
      final destinationFile = File('${tempDir.path}/$uniqueFileName');

      // Copy the generated thumbnail to the temporary directory
      await File(fileName!).copy(destinationFile.path);

      images.add(Image.file(File(destinationFile.path)));
      currentVideoTime += 500; // Increment the time position

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      try {
        String imagePrediction = await classificationModel
            .getImagePrediction(await File(fileName).readAsBytes());
        print(imagePrediction);
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      _videoPlayerController.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inference'),
      ),
      body: Center(
        child: (!_videoPlayerController.value.isInitialized)
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                    Visibility(
                      visible: !_videoPlayerController.value.isPlaying,
                      child: ElevatedButton(
                        onPressed: () {
                          runModel();
                        },
                        child: const Text('Run'),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: images.length,
                        itemBuilder: ((context, index) => images[index])),
                  ],
                ),
              ),
      ),
    );
  }
}
