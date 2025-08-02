// lib/view/widget/productdetails/topproductpagedetails.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/productdetails_controller.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:ecommercecourse/view/widget/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/model/itemsmodel.dart';

class TopProductPageDetails extends StatefulWidget {
  final ItemsModel itemsModel;

  const TopProductPageDetails(this.itemsModel, {Key? key}) : super(key: key);

  @override
  State<TopProductPageDetails> createState() => _TopProductPageDetailsState();
}

class _TopProductPageDetailsState extends State<TopProductPageDetails>
    with AutomaticKeepAliveClientMixin {

  // إضافة Map لتتبع VideoPlayerWidgets
  final Map<String, VideoPlayerWidget> _videoWidgets = {};
  final Map<String, bool> _videoWidgetCreated = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // تنظيف VideoWidgets عند إلغاء الصفحة
    _videoWidgets.clear();
    _videoWidgetCreated.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) {
        // فحص أمان للـ controller
        if (controller == null) {
          return _buildPlaceholderImage();
        }

        return Stack(
          children: [
            _buildMediaPageView(controller),
            _buildMediaIndicators(controller),
            _buildViewAllImagesButton(controller),
            _buildMediaTypeIndicator(controller),
            _buildMediaCounter(controller),
          ],
        );
      },
    );
  }

  Widget _buildMediaPageView(ProductDetailsControllerImp controller) {
    // فحص أمان للـ controller والـ method
    List<Map<String, dynamic>>? allMediaNullable;
    try {
      allMediaNullable = controller.getAllMediaList();
    } catch (e) {
      print("خطأ في getAllMediaList: $e");
      return _buildPlaceholderImage();
    }

    // فحص إضافي للتأكد من عدم كون القائمة null
    List<Map<String, dynamic>> allMedia = allMediaNullable ?? [];

    if (allMedia.isEmpty) {
      return _buildPlaceholderImage();
    }

    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (index) {
        try {
          controller.updateCurrentMediaIndex(index);
        } catch (e) {
          print("خطأ في updateCurrentMediaIndex: $e");
        }
      },
      itemCount: allMedia.length,
      itemBuilder: (context, index) {
        // فحص أمان للفهرس
        if (index >= allMedia.length) {
          return _buildErrorWidget();
        }

        Map<String, dynamic>? media = allMedia[index];

        // فحص أمان للـ media
        if (media == null) {
          return _buildErrorWidget();
        }

        String? mediaType = media['type'];
        String? mediaUrl = media['url'];

        // فحص أمان للبيانات
        if (mediaType == null || mediaUrl == null) {
          return _buildErrorWidget();
        }

        if (mediaType == 'image') {
          return _buildImageWidget(controller, media, allMedia, index);
        } else if (mediaType == 'video') {
          return _buildVideoPlayerWidget(mediaUrl, index, controller);
        }

        return _buildErrorWidget();
      },
    );
  }

  Widget _buildImageWidget(
      ProductDetailsControllerImp controller,
      Map<String, dynamic> media,
      List<Map<String, dynamic>> allMedia,
      int index,
      ) {
    return GestureDetector(
      onTap: () {
        try {
          List<String> images = controller.getImagesList() ?? [];
          int imageIndex = 0;

          int imageCounter = 0;
          for (int i = 0; i <= index && i < allMedia.length; i++) {
            Map<String, dynamic>? currentMedia = allMedia[i];
            if (currentMedia != null && currentMedia['type'] == 'image') {
              if (i == index) {
                imageIndex = imageCounter;
                break;
              }
              imageCounter++;
            }
          }

          controller.openImageGallery(imageIndex);
        } catch (e) {
          print("خطأ في فتح معرض الصور: $e");
        }
      },
      child: Hero(
        tag: "image_${media['url']}_$index",
        child: CachedNetworkImage(
          imageUrl: "${AppLink.imagestItems}/${media['url']}",
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerWidget(String videoUrl, int index, ProductDetailsControllerImp controller) {
    // إنشاء مفتاح فريد للفيديو
    String videoKey = "${videoUrl}_$index";

    // التحقق من الفهرس الحالي لتجنب إنشاء فيديوهات غير ضرورية
    bool isCurrentIndex = controller.currentMediaIndex == index;

    // إذا لم يكن الفهرس الحالي، عرض placeholder
    if (!isCurrentIndex) {
      return Container(
        width: double.infinity,
        height: double.infinity,
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
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
               Text(
                "اسحب لمشاهدة الفيديو".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // إنشاء أو إرجاع VideoPlayerWidget للفهرس الحالي فقط
    if (!_videoWidgetCreated.containsKey(videoKey)) {
      _videoWidgetCreated[videoKey] = true;
      _videoWidgets[videoKey] = VideoPlayerWidget(
        key: ValueKey(videoKey),
        videoUrl: videoUrl,
        autoPlay: false,
        showControls: true,
        preload: false,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _videoWidgets[videoKey],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              "فشل في التحميل",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMediaIndicators(ProductDetailsControllerImp controller) {
    int totalMedia = 0;
    List<Map<String, dynamic>> allMedia = [];

    try {
      totalMedia = controller.getTotalMediaCount() ?? 0;
      allMedia = controller.getAllMediaList() ?? [];
    } catch (e) {
      print("خطأ في getTotalMediaCount: $e");
      return const SizedBox.shrink();
    }

    if (totalMedia <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalMedia,
              (index) {
            bool isVideo = false;
            bool isActive = false;

            try {
              isVideo = index < allMedia.length &&
                  allMedia[index] != null &&
                  allMedia[index]['type'] == 'video';
              isActive = controller.currentMediaIndex == index;
            } catch (e) {
              print("خطأ في بناء المؤشرات: $e");
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? (isVideo ? Colors.red : Colors.white)
                    : (isVideo ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: (isVideo ? Colors.red : Colors.white).withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewAllImagesButton(ProductDetailsControllerImp controller) {
    List<String> images = [];

    try {
      images = controller.getImagesList() ?? [];
    } catch (e) {
      print("خطأ في getImagesList: $e");
      return const SizedBox.shrink();
    }

    if (images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            try {
              controller.openImageGallery(0);
            } catch (e) {
              print("خطأ في فتح معرض الصور: $e");
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeIndicator(ProductDetailsControllerImp controller) {
    List<Map<String, dynamic>> allMedia = [];
    int currentIndex = 0;

    try {
      allMedia = controller.getAllMediaList() ?? [];
      currentIndex = controller.currentMediaIndex ?? 0;
    } catch (e) {
      print("خطأ في بناء مؤشر نوع الوسائط: $e");
      return const SizedBox.shrink();
    }

    if (allMedia.isEmpty || currentIndex >= allMedia.length) {
      return const SizedBox.shrink();
    }

    Map<String, dynamic>? currentMedia = allMedia[currentIndex];
    if (currentMedia == null) {
      return const SizedBox.shrink();
    }

    String? currentType = currentMedia['type'];

    if (currentType == 'video') {
      return Positioned(
        top: 20,
        left: 20,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 16,
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
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMediaCounter(ProductDetailsControllerImp controller) {
    int totalMedia = 0;
    int imageCount = 0;
    int videoCount = 0;
    int currentIndex = 0;

    try {
      totalMedia = controller.getTotalMediaCount() ?? 0;
      imageCount = controller.getImageCount() ?? 0;
      videoCount = controller.getVideoCount() ?? 0;
      currentIndex = controller.currentMediaIndex ?? 0;
    } catch (e) {
      print("خطأ في بناء عداد الوسائط: $e");
      return const SizedBox.shrink();
    }

    if (totalMedia <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${currentIndex + 1} / $totalMedia",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (imageCount > 0 && videoCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                "$imageCount " + "صور".tr + " • $videoCount " + "فيديو".tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
