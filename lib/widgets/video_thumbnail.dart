import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumbnail;
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({super.key, required this.filePath});

  final String filePath;

  Future<Image> generateThumbnail() async {
    final uint8list = await thumbnail.VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return Image.memory(uint8list!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: generateThumbnail(),
            builder: (context, image) {
              if (image.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              return image.data!;
            },
          ),
          const Icon(Icons.play_circle_fill, size: 50),
        ],
      ),
    );
  }
}
