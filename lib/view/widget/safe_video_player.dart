// lib/view/widget/safe_video_player.dart
import 'package:flutter/material.dart';
import 'video_player_widget.dart';

class SafeVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final bool preload;

  const SafeVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.preload = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return VideoPlayerWidget(
            key: ValueKey('video_$videoUrl'),
            videoUrl: videoUrl,
            autoPlay: autoPlay,
            showControls: showControls,
            preload: preload,
          );
        } catch (e) {
          print("خطأ في SafeVideoPlayer: $e");
          return Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "خطأ في تحميل مشغل الفيديو",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
