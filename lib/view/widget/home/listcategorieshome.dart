import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/functions/translatefatabase.dart';
import 'package:ecommercecourse/data/model/categoriesmodel.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ListCategoriesHome extends GetView<HomeControllerImp> {
  const ListCategoriesHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: controller.categories.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return CategoryItem(
            index: index,
            categoriesModel: CategoriesModel.fromJson(category),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoriesModel categoriesModel;
  final int index;

  const CategoryItem({
    super.key,
    required this.categoriesModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCategoryTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: AppColor.primaryColor.withOpacity(0.1),
          splashColor: AppColor.secondColor.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryIcon(context),
              const SizedBox(height: 8),
              _buildCategoryName(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap() {
    final controller = Get.find<HomeControllerImp>();
    if (categoriesModel.categoriesId != null) {
      controller.goToItems(
        controller.categories,
        index,
        categoriesModel.categoriesId!,
      );
    }
  }

  Widget _buildCategoryIcon(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColor.thirdColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.secondColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: _buildCategoryImage(),
      ),
    );
  }

  Widget _buildCategoryImage() {
    final imageUrl = categoriesModel.categoriesImage != null
        ? "${AppLink.imagestCategories}/${categoriesModel.categoriesImage}"
        : '';

    if (imageUrl.isEmpty) {
      return const Icon(Icons.category_outlined,
          color: AppColor.secondColor);
    }

    return imageUrl.endsWith('.svg')
        ? SvgPicture.network(
      imageUrl,
      color: AppColor.secondColor,
      placeholderBuilder: (_) => _buildShimmerEffect(),
    )
        : CachedNetworkImage(
      imageUrl: imageUrl,
      color: AppColor.secondColor,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => _buildShimmerEffect(),
      errorWidget: (_, __, ___) => const Icon(Icons.error_outline),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildCategoryName() {
    final nameAr = categoriesModel.categoriesNamaAr ?? '';
    final nameEn = categoriesModel.categoriesName ?? '';

    final displayName = translateDatabase(nameAr, nameEn) ?? 'Unnamed Category';

    return SizedBox(
      width: 80,
      child: Text(
        displayName,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: AppColor.black,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}