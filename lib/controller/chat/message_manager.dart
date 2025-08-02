import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../../core/services/services.dart';
import 'chat_state.dart';

class MessageManager {
  final ChatState _state;

  MessageManager(this._state);

// ═══════════════ إدارة الرسائل ═══════════════

  Future<void> loadMessages(String conversationID, ZIMConversationType type) async {
    try {
      final List<ZIMMessage> allMessages = [];
      ZIMMessageQueryConfig config = ZIMMessageQueryConfig()
        ..count = 50
        ..reverse = false; // التأكد من أن الرسائل تُرجع من الأقدم إلى الأحدث

      ZIMMessage? nextMessage;
      do {
        final result = await ZIM.getInstance()!.queryHistoryMessage(conversationID, type, config);
        // تصفية الرسائل المخصصة المتعلقة بحالة الكتابة من النتائج
        final filteredResults = result.messageList.where((msg) =>
        !(msg is ZIMCustomMessage &&
            (msg.message == 'typing_start' || msg.message == 'typing_stop'))).toList();
        allMessages.addAll(filteredResults);
        if (result.messageList.isNotEmpty) {
          nextMessage = result.messageList.last;
          config.nextMessage = nextMessage;
        } else {
          nextMessage = null;
        }
      } while (allMessages.length < 1000 && nextMessage != null); // مثال: تحميل ما يصل إلى 1000 رسالة

      // ترتيب الرسائل حسب الوقت (الأقدم أولاً)
      final sortedMessages = allMessages.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _state.messages.value = sortedMessages;

      await _markMessagesAsRead(conversationID, type);
    } catch (e) {
      print('خطأ في تحميل الرسائل: $e');
    }
  }

  Future<void> sendTextMessage(
      String text, String conversationID, ZIMConversationType type) async {
    late ZIMTextMessage message;
    try {
      message = ZIMTextMessage(message: text);
      final config = ZIMMessageSendConfig();

// إضافة الرسالة مؤقتاً مع timestamp حالي (يمكن أن يكون تقريبياً)
      message.timestamp = DateTime.now().millisecondsSinceEpoch;
// قم بتعيين senderUserID لتمثيل المرسل المؤقت قبل التحديث من الخادم
      message.senderUserID = _state.currentUserID.value;
      _addMessageInOrder(message);

      final result = await ZIM.getInstance()!
          .sendMessage(message, conversationID, type, config);

// تحديث الرسالة بالنتيجة الفعلية
      _updateMessageInList(message, result.message);

      print('تم إرسال الرسالة بنجاح');
    } catch (e) {
      print('خطأ في إرسال الرسالة: $e');
// إزالة الرسالة في حالة الفشل
      _removeMessageFromList(message);
    }
  }

// ═══════════════ تسجيل وإرسال الصوت ═══════════════

  Future<void> startRecording() async {
    try {
      if (await _state.audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _state.audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        _state.isRecording.value = true;
        _state.recordingPath.value = path;
        _state.recordingDuration.value = 0;

        _startRecordingTimer();
      }
    } catch (e) {
      print('خطأ في بدء التسجيل: $e');
    }
  }

  Future<void> stopRecording(String conversationID, ZIMConversationType type) async {
    try {
      final path = await _state.audioRecorder.stop();
      _state.isRecording.value = false;

      if (path != null && _state.recordingDuration.value > 1) {
        await sendAudioMessage(conversationID, type, path);
      }

      _state.recordingPath.value = '';
      _state.recordingDuration.value = 0;
    } catch (e) {
      print('خطأ في إيقاف التسجيل: $e');
    }
  }

  void _startRecordingTimer() {
    Stream.periodic(const Duration(seconds: 1)).listen((event) {
      if (_state.isRecording.value) {
        _state.recordingDuration.value++;
      }
    });
  }

  Future<void> sendAudioMessage(String conversationID, ZIMConversationType type, String audioPath) async {
    late ZIMAudioMessage audioMessage;
    try {
      final file = File(audioPath);
      audioMessage = ZIMAudioMessage(file.path);

// حفظ مدة التسجيل
      audioMessage.audioDuration = _state.recordingDuration.value;
      audioMessage.timestamp = DateTime.now().millisecondsSinceEpoch;
// قم بتعيين senderUserID لتمثيل المرسل المؤقت قبل التحديث من الخادم
      audioMessage.senderUserID = _state.currentUserID.value;

      final config = ZIMMessageSendConfig();

// إضافة الرسالة مؤقتاً
      _addMessageInOrder(audioMessage);

      final result = await ZIM.getInstance()!
          .sendMessage(audioMessage, conversationID, type, config);

// تحديث الرسالة بالنتيجة الفعلية
      _updateMessageInList(audioMessage, result.message);

      Get.snackbar('نجح', 'تم إرسال الرسالة الصوتية بنجاح');
    } catch (e) {
      print('خطأ في إرسال الرسالة الصوتية: $e');
// إزالة الرسالة في حالة الفشل
      _removeMessageFromList(audioMessage);
      Get.snackbar('خطأ', 'فشل في إرسال الرسالة الصوتية');
    }
  }

// ═══════════════ إرسال الوسائط ═══════════════

  Future<void> sendImageMessage(String conversationID, ZIMConversationType type, ZIMImageMessage imageMessage) async {
    try {
      final config = ZIMMessageSendConfig();

// إضافة timestamp وإضافة للقائمة
      imageMessage.timestamp = DateTime.now().millisecondsSinceEpoch;
// قم بتعيين senderUserID لتمثيل المرسل المؤقت قبل التحديث من الخادم
      imageMessage.senderUserID = _state.currentUserID.value;
      _addMessageInOrder(imageMessage);

      final result = await ZIM.getInstance()!
          .sendMessage(imageMessage, conversationID, type, config);

      _updateMessageInList(imageMessage, result.message);
    } catch (e) {
      print('خطأ في إرسال الصورة: $e');
      _removeMessageFromList(imageMessage);
    }
  }

  Future<void> sendVideoMessage(String conversationID, ZIMConversationType type, ZIMVideoMessage videoMessage) async {
    try {
      final config = ZIMMessageSendConfig();

// إضافة timestamp وإضافة للقائمة
      videoMessage.timestamp = DateTime.now().millisecondsSinceEpoch;
// قم بتعيين senderUserID لتمثيل المرسل المؤقت قبل التحديث من الخادم
      videoMessage.senderUserID = _state.currentUserID.value;
      _addMessageInOrder(videoMessage);

      final result = await ZIM.getInstance()!
          .sendMessage(videoMessage, conversationID, type, config);

      _updateMessageInList(videoMessage, result.message);
    } catch (e) {
      print('خطأ في إرسال الفيديو: $e');
      _removeMessageFromList(videoMessage);
    }
  }

  Future<void> sendFileMessage(String conversationID, ZIMConversationType type, ZIMFileMessage fileMessage) async {
    try {
      final config = ZIMMessageSendConfig();

// إضافة timestamp وإضافة للقائمة
      fileMessage.timestamp = DateTime.now().millisecondsSinceEpoch;
// قم بتعيين senderUserID لتمثيل المرسل المؤقت قبل التحديث من الخادم
      fileMessage.senderUserID = _state.currentUserID.value;
      _addMessageInOrder(fileMessage);

      final result = await ZIM.getInstance()!
          .sendMessage(fileMessage, conversationID, type, config);

      _updateMessageInList(fileMessage, result.message);
    } catch (e) {
      print('خطأ في إرسال الملف: $e');
      _removeMessageFromList(fileMessage);
    }
  }

// ═══════════════ دوال مساعدة لترتيب الرسائل ═══════════════

  void _addMessageInOrder(ZIMMessage message) {
    final messages = _state.messages.toList();

// إذا كانت الرسالة مرسلة من المستخدم الحالي، أضفها في نهاية القائمة مؤقتًا
    if (message.senderUserID == _state.currentUserID.value) {
      messages.add(message);
    } else {
// للرسائل الواردة، أضفها حسب الترتيب الزمني
      int insertIndex = messages.length;
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].timestamp <= message.timestamp) {
          insertIndex = i + 1;
          break;
        }
      }
      messages.insert(insertIndex, message);
    }

    _state.messages.value = messages;
  }

  void _updateMessageInList(ZIMMessage oldMessage, ZIMMessage newMessage) {
    final messages = _state.messages.toList();
    final index = messages.indexWhere((m) =>
    m.localMessageID == oldMessage.localMessageID || m.messageID == oldMessage.messageID);

    if (index != -1) {
      messages.removeAt(index); // إزالة الرسالة القديمة
      int newIndex = messages.length;
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].timestamp <= newMessage.timestamp) {
          newIndex = i + 1;
          break;
        }
      }
      messages.insert(newIndex, newMessage); // إدراج الرسالة المحدثة
      _state.messages.value = messages;
    } else {
      // إذا لم يتم العثور على الرسالة القديمة، أضف الجديدة
      _addMessageInOrder(newMessage);
    }
  }

  void _removeMessageFromList(ZIMMessage message) {
    final messages = _state.messages.toList();
    messages.removeWhere((m) =>
    m.localMessageID == message.localMessageID);
    _state.messages.value = messages;
  }

  void addReceivedMessage(ZIMMessage message) {
    // تجاهل الرسائل المخصصة المتعلقة بحالة الكتابة
    if (message is ZIMCustomMessage &&
        (message.message == 'typing_start' || message.message == 'typing_stop')) {
      print("تم تجاهل رسالة الكتابة: ${message.message}");
      return;
    }
    // التأكد من عدم وجود الرسالة مسبقاً
    final exists = _state.messages.any((m) => m.messageID == message.messageID);
    if (!exists) {
      _addMessageInOrder(message);
    }
  }

// ═══════════════ الرسائل المميزة ═══════════════

  Future<void> loadStarredMessages() async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final starredIds = prefs.getStringList('starred_messages') ?? [];

      _state.starredMessages.clear();
      for (var conv in _state.conversations) {
        final config = ZIMMessageQueryConfig()..count = 100;
        final result = await ZIM.getInstance()!
            .queryHistoryMessage(conv.conversationID, conv.type, config);

        final starred = result.messageList.where((msg) =>
            starredIds.contains('${msg.conversationID}_${msg.messageID}')).toList();
        _state.starredMessages.addAll(starred);
      }
    } catch (e) {
      print('خطأ في تحميل الرسائل المميزة: $e');
    }
  }

  Future<void> toggleStarMessage(ZIMMessage message) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final starredIds = prefs.getStringList('starred_messages') ?? [];
      final messageKey = '${message.conversationID}_${message.messageID}';

      if (starredIds.contains(messageKey)) {
        starredIds.remove(messageKey);
        _state.starredMessages.removeWhere((m) =>
        '${m.conversationID}_${m.messageID}' == messageKey);
      } else {
        starredIds.add(messageKey);
        _state.starredMessages.add(message);
      }

      await prefs.setStringList('starred_messages', starredIds);
    } catch (e) {
      print('خطأ في تمييز الرسالة: $e');
    }
  }

  bool isMessageStarred(ZIMMessage message) {
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    final starredIds = prefs.getStringList('starred_messages') ?? [];
    return starredIds.contains('${message.conversationID}_${message.messageID}');
  }

// ═══════════════ البحث ═══════════════

  Future<void> searchInConversation(String conversationID, ZIMConversationType type, String query) async {
    if (query.isEmpty) {
      _state.searchResults.clear();
      return;
    }

    try {
      _state.searchQuery.value = query;
      final config = ZIMMessageQueryConfig()..count = 100;
      final result = await ZIM.getInstance()!
          .queryHistoryMessage(conversationID, type, config);

      _state.searchResults.value = result.messageList.where((message) {
        if (message is ZIMTextMessage) {
          return message.message.toLowerCase().contains(query.toLowerCase());
        }
        return false;
      }).toList();
    } catch (e) {
      print('خطأ في البحث: $e');
    }
  }

  void clearSearch() {
    _state.searchQuery.value = '';
    _state.searchResults.clear();
  }

// ═══════════════ حالة الكتابة ═══════════════

  Future<void> sendTypingStatus(String conversationID, bool isTyping) async {
    try {
      final message = ZIMCustomMessage(
        message: isTyping ? 'typing_start' : 'typing_stop',
        subType: 1, // يمكن أن يكون أي قيمة لتحديد نوع الرسالة المخصصة
      );
      final config = ZIMMessageSendConfig();
      await ZIM.getInstance()!.sendMessage(
        message,
        conversationID,
        ZIMConversationType.peer,
        config,
      );
    } catch (e) {
      print('خطأ في إرسال حالة الكتابة: $e');
    }
  }

// ═══════════════ قراءة الرسائل ═══════════════

  Future<void> _markMessagesAsRead(String conversationID, ZIMConversationType type) async {
    try {
      await ZIM.getInstance()!.clearConversationUnreadMessageCount(conversationID, type);

      for (var message in _state.messages) {
        if (message.conversationID == conversationID &&
            message.senderUserID != _state.currentUserID.value) {
          _state.messageReadStatus[message.messageID.toString()] = true;
        }
      }
    } catch (e) {
      print('خطأ في تحديد الرسائل كمقروءة: $e');
    }
  }

  void dispose() {
    _state.audioRecorder.dispose();
  }
}
