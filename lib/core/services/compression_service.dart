import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CompressionService {
  static CompressionService? _instance;
  static CompressionService get instance => _instance ??= CompressionService._();
  CompressionService._();

  /// ضغط صورة واحدة
  Future<File?> compressImage(File file, {int quality = 85, int? targetSize}) async {
    try {
      // الحصول على مجلد مؤقت
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(file.path);
      final fileExtension = path.extension(file.path).toLowerCase();

      // تحديد صيغة الضغط
      CompressFormat format;
      String outputExtension;

      if (fileExtension == '.png' || fileExtension == '.gif') {
        format = CompressFormat.png;
        outputExtension = '.png';
      } else {
        format = CompressFormat.jpeg;
        outputExtension = '.jpg';
      }

      final outputPath = path.join(
        tempDir.path,
        'compressed_${fileName}_${DateTime.now().millisecondsSinceEpoch}$outputExtension',
      );

      // ضغط الصورة
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outputPath,
        quality: quality,
        format: format,
        minWidth: 800, // العرض الأدنى
        minHeight: 600, // الارتفاع الأدنى
        keepExif: false, // إزالة بيانات EXIF لتوفير المساحة
      );

      if (compressedFile != null) {
        final compressedSize = await compressedFile.length();
        final originalSize = await file.length();

        print('ضغط الصورة: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

        // إذا كان الحجم المستهدف محدد وما زال الملف كبيراً
        if (targetSize != null && compressedSize > targetSize && quality > 30) {
          // إعادة الضغط بجودة أقل
          int newQuality = (quality * 0.7).round();
          return await compressImage(File(compressedFile.path), quality: newQuality, targetSize: targetSize);
        }

        return File(compressedFile.path);
      }

      return null;
    } catch (e) {
      print('خطأ في ضغط الصورة: $e');
      return null;
    }
  }

  /// ضغط فيديو واحد
  Future<File?> compressVideo(File file, {VideoQuality quality = VideoQuality.MediumQuality}) async {
    try {
      print('بدء ضغط الفيديو: ${file.path}');

      final originalSize = await file.length();
      print('الحجم الأصلي: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB');

      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info?.file != null) {
        final compressedSize = await info!.file!.length();

        print('ضغط الفيديو: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

        return info.file!;
      }

      return null;
    } catch (e) {
      print('خطأ في ضغط الفيديو: $e');
      return null;
    }
  }

  /// ضغط قائمة من الملفات مع callback للتقدم
  Future<List<File>> compressMultipleFiles(
      List<File> files, {
        Function(int current, int total, String fileName)? onProgress,
        int imageQuality = 85,
        VideoQuality videoQuality = VideoQuality.MediumQuality,
        int? targetImageSize, // بالبايت
      }) async {
    List<File> compressedFiles = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = path.basename(file.path);

      onProgress?.call(i + 1, files.length, fileName);

      if (isImageFile(file)) {
        final compressed = await compressImage(
          file,
          quality: imageQuality,
          targetSize: targetImageSize ?? 2 * 1024 * 1024, // 2MB افتراضي
        );
        if (compressed != null) {
          compressedFiles.add(compressed);
        } else {
          compressedFiles.add(file); // في حالة فشل الضغط، استخدم الملف الأصلي
        }
      } else if (isVideoFile(file)) {
        final compressed = await compressVideo(file, quality: videoQuality);
        if (compressed != null) {
          compressedFiles.add(compressed);
        } else {
          compressedFiles.add(file); // في حالة فشل الضغط، استخدم الملف الأصلي
        }
      } else {
        compressedFiles.add(file); // نوع ملف غير مدعوم
      }
    }

    return compressedFiles;
  }

  /// التحقق من نوع الملف
  bool isImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif'].contains(extension);
  }

  bool isVideoFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv'].contains(extension);
  }

  /// حساب الحجم المقترح للصورة بناءً على الأبعاد
  Future<int> getImageSizeInfo(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes.length;
    } catch (e) {
      return 0;
    }
  }

  /// تنظيف الملفات المؤقتة
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('compressed_')) {
          final lastModified = await file.lastModified();
          final now = DateTime.now();

          // حذف الملفات المؤقتة الأقدم من ساعة واحدة
          if (now.difference(lastModified).inHours > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('خطأ في تنظيف الملفات المؤقتة: $e');
    }
  }

  /// الحصول على معلومات الملف
  Future<Map<String, dynamic>> getFileInfo(File file) async {
    final size = await file.length();
    final extension = path.extension(file.path).toLowerCase();
    final isImage = isImageFile(file);
    final isVideo = isVideoFile(file);

    return {
      'size': size,
      'sizeFormatted': formatFileSize(size),
      'extension': extension,
      'isImage': isImage,
      'isVideo': isVideo,
      'path': file.path,
      'name': path.basename(file.path),
    };
  }

  /// تنسيق حجم الملف
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// إنهاء خدمة ضغط الفيديو
  void dispose() {
    VideoCompress.deleteAllCache();
  }
}
