import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/favorite_controller.dart';
import 'package:ecommercecourse/controller/productdetails_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../data/model/itemsmodel.dart';

class TopProductPageDetails extends StatelessWidget {
  final ItemsModel itemsModel;
  const TopProductPageDetails(this.itemsModel, {Key? key}) : super(key: key);

  // دوال مساعدة للحصول على الصور والفيديوهات
  List<String> _getImagesList() {
    if (itemsModel.itemsImage == null || itemsModel.itemsImage == "empty") {
      return [];
    }

    try {
      Map<String, dynamic> filesData = jsonDecode(itemsModel.itemsImage!);
      if (filesData['images'] != null) {
        return List<String>.from(filesData['images']);
      }
    } catch (e) {
      // إذا كان النص ليس JSON (النظام القديم)
      return [itemsModel.itemsImage!];
    }
    return [];
  }

  List<String> _getVideosList() {
    if (itemsModel.itemsImage == null || itemsModel.itemsImage == "empty") {
      return [];
    }

    try {
      Map<String, dynamic> filesData = jsonDecode(itemsModel.itemsImage!);
      if (filesData['videos'] != null) {
        return List<String>.from(filesData['videos']);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  List<Map<String, dynamic>> _getAllMediaList() {
    List<Map<String, dynamic>> allMedia = [];

    // إضافة الصور
    for (String image in _getImagesList()) {
      allMedia.add({'type': 'image', 'url': image});
    }

    // إضافة الفيديوهات
    for (String video in _getVideosList()) {
      allMedia.add({'type': 'video', 'url': video});
    }

    return allMedia;
  }

  // دالة لتنظيف وترميز URL
  String _encodeVideoUrl(String videoName) {
    // ترميز الأحرف العربية والخاصة
    String encodedName = Uri.encodeComponent(videoName);
    String fullUrl = "${AppLink.imagestItems}/$encodedName";
    print("Original video name: $videoName");
    print("Encoded video URL: $fullUrl");
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "${itemsModel.itemsId}",
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              _buildMediaCarousel(context),
              _buildFloatingActionButtons(),
              _buildMediaIndicators(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCarousel(BuildContext context) {
    List<Map<String, dynamic>> allMedia = _getAllMediaList();

    if (allMedia.isEmpty) {
      return _buildNoMediaPlaceholder();
    }

    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) {
        if (controller.pageController == null) {
          controller.pageController = PageController();
        }

        return PageView.builder(
          controller: controller.pageController,
          onPageChanged: (index) {
            controller.updateCurrentMediaIndex(index);
          },
          itemCount: allMedia.length,
          itemBuilder: (context, index) {
            final media = allMedia[index];
            return GestureDetector(
              onTap: () => _showFullScreenMedia(context, allMedia, index),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: media['type'] == 'image'
                      ? _buildImageWidget(media['url'])
                      : _buildVideoWidget(media['url']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageWidget(String imageName) {
    return CachedNetworkImage(
      imageUrl: "${AppLink.imagestItems}/$imageName",
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: const Color(0xFFF1F5F9),
        highlightColor: const Color(0xFFF8FAFC),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget(String videoName) {
    final String videoUrl = _encodeVideoUrl(videoName);
    return VideoPlayerWidget(
      videoUrl: videoUrl,
      key: ValueKey(videoUrl), // إضافة key فريد
    );
  }

  Widget _buildNoMediaPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد صور أو فيديوهات',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaIndicators(BuildContext context) {
    List<Map<String, dynamic>> allMedia = _getAllMediaList();
    int totalMedia = allMedia.length;

    if (totalMedia <= 1) return const SizedBox.shrink();

    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) => Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalMedia,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: controller.currentMediaIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: controller.currentMediaIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(),
            Row(
              children: [
                _buildMediaCountBadge(),
                const SizedBox(width: 8),
                _buildFavoriteButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCountBadge() {
    int totalMedia = _getAllMediaList().length;
    if (totalMedia <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GetBuilder<ProductDetailsControllerImp>(
        builder: (controller) => Text(
          "${controller.currentMediaIndex + 1}/$totalMedia",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GetBuilder<FavoriteController>(
      init: Get.put(FavoriteController()),
      builder: (favoriteController) {
        final String itemId = itemsModel.itemsId?.toString() ?? 'default_id';
        final bool isFavorite = favoriteController.isFavorite[itemId] ??
            (itemsModel.favorite == "1" ? true : false);

        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final bool newValue = !isFavorite;
                favoriteController.setFavorite(itemId, newValue);
                if (newValue) {
                  favoriteController.addFavorite(itemId);
                } else {
                  favoriteController.removeFavorite(itemId);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFEF4444) : AppColor.primaryColor,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenMedia(BuildContext context, List<Map<String, dynamic>> allMedia, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: FullScreenMediaViewer(
          allMedia: allMedia,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// مشغل فيديو محسن ومُصحح
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  String _errorMessage = '';
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      print("Initializing video player with URL: ${widget.videoUrl}");

      // التحقق من صحة الرابط
      if (!widget.videoUrl.startsWith('http')) {
        throw Exception('Invalid video URL format');
      }

      // إنشاء controller جديد بدون إعدادات معقدة
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // تهيئة المشغل
      await _controller!.initialize();

      // إضافة listener للتحديثات
      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'فشل في تحميل الفيديو: ${e.toString()}';
        });
      }
    }
  }

  void _videoListener() {
    if (mounted && _controller != null) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // إخفاء التحكم تلقائياً بعد 3 ثوان
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // مشغل الفيديو
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            // طبقة التحكم
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // شارة الفيديو
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'فيديو',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // شريط التقدم
            if (_showControls && _controller!.value.duration.inSeconds > 0)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: AppColor.primaryColor,
                    bufferedColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الفيديو...',
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

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'خطأ في تحميل الفيديو',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                    _errorMessage = '';
                  });
                  _initializePlayer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// عارض الوسائط بملء الشاشة
class FullScreenMediaViewer extends StatefulWidget {
  final List<Map<String, dynamic>> allMedia;
  final int initialIndex;

  const FullScreenMediaViewer({
    Key? key,
    required this.allMedia,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String _encodeVideoUrl(String videoName) {
    String encodedName = Uri.encodeComponent(videoName);
    return "${AppLink.imagestItems}/$encodedName";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: widget.allMedia.length,
              itemBuilder: (context, index) {
                final media = widget.allMedia[index];
                return media['type'] == 'image'
                    ? InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: "${AppLink.imagestItems}/${media['url']}",
                    fit: BoxFit.contain,
                  ),
                )
                    : VideoPlayerWidget(
                  videoUrl: _encodeVideoUrl(media['url']),
                  key: ValueKey(_encodeVideoUrl(media['url'])),
                );
              },
            ),
          ),
        ),
        // مؤشر العدد
        if (widget.allMedia.length > 1)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "${currentIndex + 1}/${widget.allMedia.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // زر الإغلاق
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
