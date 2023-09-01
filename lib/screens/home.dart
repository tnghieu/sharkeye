import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sharkeye/screens/run_inference_screen.dart';
import 'package:sharkeye/widgets/video_thumbnail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? videoFile = null;

  // Widget _buildVideoGrid() {
  //   return Flexible(
  //     child: GridView.builder(
  //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 3,
  //       ),
  //       itemCount: _videoFiles.length,
  //       itemBuilder: (context, index) {
  //         String filePath = _videoFiles[index].path;
  //         return GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => VideoPlayerScreen(
  //                   filePath: filePath,
  //                   fileStat: _videoFiles[index].stat(),
  //                 ),
  //               ),
  //             );
  //           },
  //           child: VideoThumbnail(
  //             filePath: filePath,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharkEye'),
        actions: videoFile != null
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RunInferenceScreen(
                          videoFile: videoFile!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.next_plan_outlined),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32.0, horizontal: 64.0),
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.video,
                  );

                  if (result != null) {
                    setState(() {
                      videoFile = File(result.paths[0]!);
                    });
                  }
                },
                child: const Center(
                  child: Text('Upload Video'),
                ),
              ),
            ),
            videoFile == null
                ? const SizedBox.shrink()
                : VideoThumbnail(
                    filePath: videoFile!.path,
                  ),
          ],
        ),
      ),
    );
  }
}
