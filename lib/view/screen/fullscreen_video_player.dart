// lib/view/screen/fullscreen_video_player.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../widget/video_player_widget.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "مشغل الفيديو",
          style: TextStyle(color: Colors.white),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        child: VideoPlayerWidget(
          videoUrl: videoUrl,
          autoPlay: true,
          showControls: true,
          preload: true,
        ),
      ),
    );
  }
}
