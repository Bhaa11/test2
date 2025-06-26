// lib/view/widget/video_thumbnail_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/linkapi.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String videoUrl;
  final VoidCallback? onTap;

  const VideoThumbnailWidget({
    Key? key,
    required this.videoUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = _getThumbnailUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            if (thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildDefaultThumbnail(),
                  errorWidget: (context, url, error) => _buildDefaultThumbnail(),
                ),
              )
            else
              _buildDefaultThumbnail(),

            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "فيديو",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white54,
          size: 64,
        ),
      ),
    );
  }

  String _getThumbnailUrl() {
    if (videoUrl.endsWith('.mp4')) {
      return "${AppLink.imagestItems}/${videoUrl.replaceAll('.mp4', '_thumb.jpg')}";
    }
    return '';
  }
}
