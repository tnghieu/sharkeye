import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(
      {super.key, required this.filePath, required this.fileStat});

  final String filePath;
  final Future<FileStat> fileStat;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayer() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: widget.fileStat,
          builder: (context, fileStat) {
            if (fileStat.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            return Text(
              DateFormat.yMd().add_jm().format(fileStat.data!.changed),
            );
          },
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => togglePlayer(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  VideoProgressIndicator(
                    _controller, //controller
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).primaryColor,
                      bufferedColor: Colors.red,
                      backgroundColor: Colors.black,
                    ),
                  )
                ],
              ),
              Visibility(
                visible: !_controller.value.isPlaying,
                child: const Icon(Icons.play_circle_fill, size: 50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
