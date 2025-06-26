import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/linkapi.dart';

class ImageGalleryView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String productName;

  const ImageGalleryView({
    Key? key,
    required this.images,
    this.initialIndex = 0,
    required this.productName,
  }) : super(key: key);

  @override
  State<ImageGalleryView> createState() => _ImageGalleryViewState();
}

class _ImageGalleryViewState extends State<ImageGalleryView> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.productName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_currentIndex + 1} / ${widget.images.length}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // معرض الصور الرئيسي
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isZoomed = false;
                _transformationController.value = Matrix4.identity();
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return _buildImageViewer(widget.images[index]);
            },
          ),

          // مؤشرات الصور في الأسفل
          if (widget.images.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: _buildImageIndicators(),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        onInteractionUpdate: (details) {
          setState(() {
            _isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.0;
          });
        },
        onInteractionEnd: (details) {
          setState(() {
            _isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.0;
          });
        },
        child: GestureDetector(
          onDoubleTap: () {
            if (_isZoomed) {
              // إعادة تعيين التكبير
              _transformationController.value = Matrix4.identity();
              setState(() {
                _isZoomed = false;
              });
            } else {
              // تكبير الصورة
              final double scale = 2.0;
              _transformationController.value = Matrix4.identity()..scale(scale);
              setState(() {
                _isZoomed = true;
              });
            }
          },
          child: Hero(
            tag: "image_$imageUrl",
            child: CachedNetworkImage(
              imageUrl: "${AppLink.imagestItems}/$imageUrl",
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildErrorWidget(),
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "جاري تحميل الصورة...",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[900],
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              "فشل في تحميل الصورة".tr,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageIndicators() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          bool isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: "${AppLink.imagestItems}/${widget.images[index]}",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
