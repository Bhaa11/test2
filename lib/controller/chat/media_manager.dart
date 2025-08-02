// media_manager.dart
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../view/screen/chat/audio_player_page.dart';
import '../../view/screen/chat/image_viewer_page.dart';
import '../../view/screen/chat/video_player_page.dart';
import 'chat_state.dart';
import 'message_manager.dart';

class MediaManager {
  final ChatState _state;
  late final MessageManager _messageManager;

  MediaManager(this._state) {
    _messageManager = MessageManager(_state);
  }

  // ═══════════════ إرسال الوسائط ═══════════════

  Future<void> sendImageMessage(String conversationID, ZIMConversationType type, {ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final file = File(image.path);
        final message = ZIMImageMessage(file.path);

        // استخدام MessageManager لإرسال الرسالة مع الترتيب الصحيح
        await _messageManager.sendImageMessage(conversationID, type, message);

        Get.snackbar('نجح', 'تم إرسال الصورة بنجاح');
      }
    } catch (e) {
      print('خطأ في إرسال الصورة: $e');
      Get.snackbar('خطأ', 'فشل في إرسال الصورة');
    }
  }

  Future<void> sendFileMessage(String conversationID, ZIMConversationType type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final message = ZIMFileMessage(file.path);

        // استخدام MessageManager لإرسال الرسالة مع الترتيب الصحيح
        await _messageManager.sendFileMessage(conversationID, type, message);

        Get.snackbar('نجح', 'تم إرسال الملف بنجاح');
      }
    } catch (e) {
      print('خطأ في إرسال الملف: $e');
      Get.snackbar('خطأ', 'فشل في إرسال الملف');
    }
  }

  Future<void> sendVideoMessage(String conversationID, ZIMConversationType type, {ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: source);

      if (video != null) {
        final file = File(video.path);
        final message = ZIMVideoMessage(file.path);

        // استخدام MessageManager لإرسال الرسالة مع الترتيب الصحيح
        await _messageManager.sendVideoMessage(conversationID, type, message);

        Get.snackbar('نجح', 'تم إرسال الفيديو بنجاح');
      }
    } catch (e) {
      print('خطأ في إرسال الفيديو: $e');
      Get.snackbar('خطأ', 'فشل في إرسال الفيديو');
    }
  }

  // ═══════════════ تحميل الوسائط ═══════════════

  Future<String?> downloadMedia(ZIMMessage message) async {
    try {
      String? fileUrl;
      String fileName = '';

      if (message is ZIMImageMessage) {
        fileUrl = message.fileDownloadUrl;
        fileName = 'image_${message.messageID}.jpg';
      } else if (message is ZIMVideoMessage) {
        fileUrl = message.fileDownloadUrl;
        fileName = 'video_${message.messageID}.mp4';
      } else if (message is ZIMAudioMessage) {
        fileUrl = message.fileDownloadUrl;
        fileName = 'audio_${message.messageID}.m4a';
      } else if (message is ZIMFileMessage) {
        fileUrl = message.fileDownloadUrl;
        fileName = message.fileName ?? 'file_${message.messageID}';
      }

      if (fileUrl == null || fileUrl.isEmpty) {
        Get.snackbar('خطأ', 'رابط التحميل غير متوفر');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      _state.isDownloading[message.messageID.toString()] = true;
      _state.downloadProgress[message.messageID.toString()] = 0.0;

      final dio = Dio();
      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _state.downloadProgress[message.messageID.toString()] = received / total;
          }
        },
      );

      _state.isDownloading[message.messageID.toString()] = false;
      _state.downloadProgress.remove(message.messageID.toString());

      Get.snackbar('نجح', 'تم تحميل الملف بنجاح');
      return filePath;

    } catch (e) {
      print('خطأ في تحميل الملف: $e');
      _state.isDownloading[message.messageID.toString()] = false;
      _state.downloadProgress.remove(message.messageID.toString());
      Get.snackbar('خطأ', 'فشل في تحميل الملف');
      return null;
    }
  }

  // ═══════════════ فتح الوسائط ═══════════════

  Future<void> openMedia(ZIMMessage message) async {
    try {
      String? filePath;

      if (message is ZIMImageMessage && message.fileLocalPath.isNotEmpty) {
        filePath = message.fileLocalPath;
      } else if (message is ZIMVideoMessage && message.fileLocalPath.isNotEmpty) {
        filePath = message.fileLocalPath;
      } else if (message is ZIMAudioMessage && message.fileLocalPath.isNotEmpty) {
        filePath = message.fileLocalPath;
      } else if (message is ZIMFileMessage && message.fileLocalPath.isNotEmpty) {
        filePath = message.fileLocalPath;
      }

      if (filePath == null || filePath.isEmpty || !await File(filePath).exists()) {
        filePath = await downloadMedia(message);
      }

      if (filePath != null) {
        if (message is ZIMImageMessage) {
          Get.to(() => ImageViewerPage(imagePath: filePath!));
        } else if (message is ZIMVideoMessage) {
          Get.to(() => VideoPlayerPage(videoPath: filePath!));
        } else if (message is ZIMAudioMessage) {
          Get.to(() => AudioPlayerPage(audioPath: filePath!));
        } else if (message is ZIMFileMessage) {
          await OpenFile.open(filePath);
        }
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      Get.snackbar('خطأ', 'فشل في فتح الملف');
    }
  }

  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
  }
}
