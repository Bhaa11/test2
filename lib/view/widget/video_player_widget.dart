// lib/view/widget/video_player_widget.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:ecommercecourse/linkapi.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final bool preload;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.preload = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isInitialized = false;
  Timer? _initTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.preload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _initializePlayer();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_isDisposed) return;

    if (state == AppLifecycleState.paused) {
      _pauseVideo();
    }
  }

  void _pauseVideo() {
    try {
      if (!_isDisposed && _videoPlayerController != null &&
          _videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      }
    } catch (e) {
      print("خطأ في إيقاف الفيديو: $e");
    }
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed || !mounted || _isInitialized) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
          _errorMessage = null;
        });
      }

      // إلغاء أي عمليات سابقة
      await _cleanupResources();

      String fullVideoUrl = "${AppLink.imagestItems}/${widget.videoUrl}";
      print("🎥 بدء تحميل الفيديو: $fullVideoUrl");

      // فحص اتصال الإنترنت
      if (!await _checkInternetConnection()) {
        throw 'لا يوجد اتصال بالإنترنت'.tr;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(fullVideoUrl),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'Cache-Control': 'no-cache',
        },
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      // إضافة مستمع للحالة
      _videoPlayerController!.addListener(_videoPlayerListener);

      // تهيئة مع timeout محسن
      await Future.any([
        _videoPlayerController!.initialize(),
        Future.delayed(const Duration(seconds: 25)).then((_) {
          throw TimeoutException('انتهت مهلة تحميل الفيديو'.tr, const Duration(seconds: 25));
        }),
      ]);

      if (_isDisposed || !mounted) {
        await _cleanupResources();
        return;
      }

      // التحقق من نجاح التهيئة
      if (!_videoPlayerController!.value.isInitialized) {
        throw 'فشل في تهيئة مشغل الفيديو'.tr;
      }

      print("✅ تم تهيئة مشغل الفيديو");

      // إنشاء Chewie Controller مع إعدادات محسنة
      if (!_isDisposed && mounted && _videoPlayerController != null) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: widget.autoPlay,
          looping: false,
          showControls: widget.showControls,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          showControlsOnInitialize: false,
          startAt: Duration.zero,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
            backgroundColor: Colors.grey[600]!,
            bufferedColor: Colors.grey[400]!,
          ),
          placeholder: _buildVideoPlaceholder(),
          errorBuilder: (context, errorMessage) {
            return _buildErrorWidget( "خطأ في التشغيل:".tr + " $errorMessage");
          },
        );

        _isInitialized = true;

        if (mounted && !_isDisposed) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
        }

        print("✅ تم تحميل الفيديو بنجاح");
      }

    } catch (e) {
      print("❌ خطأ في تحميل الفيديو: $e");
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }
      await _cleanupResources();
    }
  }

  void _videoPlayerListener() {
    if (_isDisposed) return;

    try {
      if (_videoPlayerController != null && mounted) {
        // يمكن إضافة منطق إضافي هنا للاستماع لتغيرات الفيديو
        if (_videoPlayerController!.value.hasError) {
          print("خطأ في الفيديو: ${_videoPlayerController!.value.errorDescription}");
          if (mounted && !_isDisposed) {
            setState(() {
              _hasError = true;
              _errorMessage = _videoPlayerController!.value.errorDescription ?? "خطأ غير معروف".tr;
            });
          }
        }
      }
    } catch (e) {
      print("خطأ في مستمع الفيديو: $e");
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorStr = error.toString().toLowerCase();

    if (errorStr.contains('timeout') || errorStr.contains('انتهت مهلة'.tr)) {
      return '⏱️ الفيديو يحتاج وقت أطول للتحميل\nتحقق من سرعة الإنترنت'.tr;
    } else if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('لا يوجد اتصال')) {
      return '🌐 مشكلة في الاتصال بالإنترنت\nتحقق من الاتصال وأعد المحاولة'.tr;
    } else if (errorStr.contains('format') || errorStr.contains('codec')) {
      return '📹 تنسيق الفيديو غير مدعوم'.tr;
    } else if (errorStr.contains('404') || errorStr.contains('not found')) {
      return '❌ الفيديو غير موجود على الخادم'.tr;
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return '🔒 غير مسموح بالوصول للفيديو'.tr;
    } else if (errorStr.contains('500')) {
      return '⚠️ خطأ في خادم الفيديو';
    }

    return '❌ خطأ في تحميل الفيديو\nجرب مرة أخرى'.tr;
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Future<void> _cleanupResources() async {
    try {
      _initTimer?.cancel();
      _initTimer = null;

      // إيقاف وإلغاء ChewieController بأمان
      if (_chewieController != null) {
        try {
          // إيقاف الفيديو أولاً
          if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
            await _videoPlayerController!.pause();
          }

          // إضافة تأخير للسماح للsession بالانتهاء
          await Future.delayed(const Duration(milliseconds: 200));

          if (!_isDisposed) {
            _chewieController!.dispose();
          }
        } catch (e) {
          print("خطأ في إلغاء ChewieController: $e");
        } finally {
          _chewieController = null;
        }
      }

      // إيقاف وإلغاء VideoPlayerController بأمان
      if (_videoPlayerController != null) {
        try {
          if (_videoPlayerController!.value.isPlaying) {
            await _videoPlayerController!.pause();
          }

          // إزالة المستمع قبل الإلغاء
          _videoPlayerController!.removeListener(_videoPlayerListener);

          await Future.delayed(const Duration(milliseconds: 200));

          if (!_isDisposed) {
            _videoPlayerController!.dispose();
          }
        } catch (e) {
          print("خطأ في إلغاء VideoPlayerController: $e");
        } finally {
          _videoPlayerController = null;
        }
      }

      _isInitialized = false;
    } catch (e) {
      print("خطأ عام في تنظيف الموارد: $e");
    }
  }

  @override
  void dispose() {
    print("🗑️ بدء إلغاء VideoPlayerWidget");
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // تنظيف الموارد
    _cleanupResources().then((_) {
      print("🗑️ تم إلغاء VideoPlayerWidget");
    }).catchError((e) {
      print("خطأ في إلغاء VideoPlayerWidget: $e");
    });

    super.dispose();
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? "فشل في تحميل الفيديو".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!_isDisposed && mounted) {
                        _isInitialized = false;
                        _initializePlayer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label:  Text("إعادة المحاولة".tr, style: TextStyle(fontSize: 12)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showVideoUrl();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.link, size: 16),
                    label: Text("عرض الرابط".tr, style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoUrl() {
    if (_isDisposed || !mounted) return;

    String fullVideoUrl = "${AppLink.imagestItems}/${widget.videoUrl}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text("رابط الفيديو".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("يمكنك نسخ الرابط وفتحه في مشغل خارجي:".tr),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                fullVideoUrl,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text("إغلاق".tr),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
             Text(
              "اضغط لتشغيل الفيديو".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "قد يحتاج وقت للتحميل".tr,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
             Text(
              "جاري تحميل الفيديو...".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "قد يستغرق حتى 30 ثانية".tr,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                if (!_isDisposed && mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = "تم إلغاء التحميل بواسطة المستخدم".tr;
                  });
                  _cleanupResources();
                }
              },
              child: Text(
                "إلغاء".tr,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isDisposed) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            "تم إلغاء المشغل".tr,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    if (!widget.preload && !_isInitialized && !_isLoading) {
      return GestureDetector(
        onTap: () {
          if (!_isDisposed && mounted) {
            _initializePlayer();
          }
        },
        child: _buildPlayButton(),
      );
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _chewieController == null) {
      return _buildErrorWidget(_errorMessage);
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController?.value.aspectRatio ?? 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}
