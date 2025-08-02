import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'dart:convert';


// استيراد الملفات المقسمة
import '../../core/services/services.dart';
import 'chat_state.dart';
import 'voice_call_manager.dart';
import 'message_manager.dart';
import 'media_manager.dart';
import 'conversation_manager.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

// إدراج جميع المتغيرات من ChatState
  late final ChatState _state;
  late final VoiceCallManager _voiceCallManager;
  late final MessageManager _messageManager;
  late final MediaManager _mediaManager;
  late final ConversationManager _conversationManager;

// Getters للوصول للمتغيرات
  RxList<ZIMConversation> get conversations => _state.conversations;
  RxList<ZIMMessage> get messages => _state.messages;
  RxList<ZIMConversation> get archivedConversations => _state.archivedConversations;
  RxList<ZIMMessage> get starredMessages => _state.starredMessages;
  RxBool get isLoading => _state.isLoading;
  RxString get currentUserID => _state.currentUserID;
  RxString get currentUserName => _state.currentUserName;
  RxMap<String, bool> get userOnlineStatus => _state.userOnlineStatus;
  RxMap<String, bool> get messageReadStatus => _state.messageReadStatus;
  RxMap<String, bool> get typingStatus => _state.typingStatus;
  RxString get searchQuery => _state.searchQuery;
  RxList<ZIMMessage> get searchResults => _state.searchResults;
  RxBool get isRecording => _state.isRecording;
  RxString get recordingPath => _state.recordingPath;
  RxInt get recordingDuration => _state.recordingDuration;
  RxMap<String, double> get downloadProgress => _state.downloadProgress;
  RxMap<String, bool> get isDownloading => _state.isDownloading;
  RxBool get isInVoiceCall => _state.isInVoiceCall;
  RxBool get isMicrophoneOn => _state.isMicrophoneOn;
  RxBool get isSpeakerOn => _state.isSpeakerOn;
  RxString get currentCallUserID => _state.currentCallUserID;
  RxString get currentRoomID => _state.currentRoomID;
  RxInt get callDuration => _state.callDuration;
  RxBool get isCallConnected => _state.isCallConnected;
  RxBool get isCallConnecting => _state.isCallConnecting;
  RxString get callState => _state.callState;
  RxDouble get localVolume => _state.localVolume;
  RxDouble get remoteVolume => _state.remoteVolume;
  RxBool get isZegoEngineInitialized => _state.isZegoEngineInitialized;
  RxMap<String, bool> get blockedUsers => _state.blockedUsers;
  RxMap<String, bool> get blockedByMe => _state.blockedByMe;

  @override
  void onInit() {
    super.onInit();

// تهيئة جميع المكونات
    _state = ChatState();
    _voiceCallManager = VoiceCallManager(_state);
    _messageManager = MessageManager(_state);
    _mediaManager = MediaManager(_state);
    _conversationManager = ConversationManager(_state);

    _getCurrentUserID();
    _voiceCallManager.initializeZegoSDK();
    _setupZIMCallbacks();
    _conversationManager.loadConversations();
    _conversationManager.loadArchivedConversations();
    _messageManager.loadStarredMessages();
    _loadBlockedUsers();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.photos,
    ].request();
  }

  void _getCurrentUserID() {
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    _state.currentUserID.value = prefs.getString("id") ?? '';
    _state.currentUserName.value = prefs.getString("username") ?? _state.currentUserID.value;
  }

// ═══════════════ ZIM Callbacks Setup ═══════════════
  void _setupZIMCallbacks() {
    ZIMEventHandler.onConnectionStateChanged = _onConnectionStateChanged;
    ZIMEventHandler.onConversationChanged = _onConversationChanged;
    ZIMEventHandler.onPeerMessageReceived = _onReceivePeerMessage;
    ZIMEventHandler.onMessageReceiptChanged = _onMessageReceiptChanged;
    ZIMEventHandler.onConversationTotalUnreadMessageCountUpdated = _onUnreadCountUpdated;
    ZIMEventHandler.onError = _onError;
    ZIMEventHandler.onCallInvitationReceived = _onCallInvitationReceived;
    ZIMEventHandler.onCallInvitationAccepted = _onCallInvitationAccepted;
    ZIMEventHandler.onCallInvitationRejected = _onCallInvitationRejected;
    ZIMEventHandler.onCallInvitationCancelled = _onCallInvitationCancelled;
    ZIMEventHandler.onCallInvitationEnded = _onCallInvitationEnded;
  }

// ═══════════════ ZIM Event Handlers ═══════════════
  void _onConnectionStateChanged(
      ZIM zim,
      ZIMConnectionState state,
      ZIMConnectionEvent event,
      Map extendedData,
      ) {
    _conversationManager.loadConversations();
  }

  void _onConversationChanged(
      ZIM zim,
      List<ZIMConversationChangeInfo> infoList,
      ) {
    _conversationManager.loadConversations();
  }

  void _onReceivePeerMessage(
      ZIM zim,
      List<ZIMMessage> messageList,
      ZIMMessageReceivedInfo info,
      String fromUserID,
      ) {
    // تجاهل الرسائل من المستخدمين المحظورين
    if (_state.blockedUsers[fromUserID] == true) {
      return;
    }

    for (var msg in messageList) {
      if (msg is ZIMCustomMessage) {
        if (msg.message == 'typing_start') {
          _state.typingStatus[fromUserID] = true;
          Future.delayed(const Duration(seconds: 5), () {
            if (_state.typingStatus[fromUserID] == true) {
              _state.typingStatus[fromUserID] = false;
            }
          });
        } else if (msg.message == 'typing_stop') {
          _state.typingStatus[fromUserID] = false;
        }
        // لا تضف الرسائل المخصصة المتعلقة بحالة الكتابة إلى قائمة الرسائل
      } else {
        // إعادة تعيين حالة الكتابة عند استقبال رسالة جديدة
        _state.typingStatus[fromUserID] = false;
        _messageManager.addReceivedMessage(msg);
      }
    }
    _conversationManager.loadConversations();
  }

  void _onMessageReceiptChanged(
      ZIM zim,
      List<ZIMMessageReceiptInfo> infos,
      ) {
    for (var info in infos) {
      _state.messageReadStatus[info.messageID.toString()] = true;
    }
  }

  void _onUnreadCountUpdated(
      ZIM zim,
      int totalUnreadMessageCount,
      ) {
    _conversationManager.loadConversations();
  }

  void _onError(ZIM zim, ZIMError errorInfo) {
    print('ZIM SDK خطأ: ${errorInfo.message}');
  }

  void _onCallInvitationReceived(ZIM zim, ZIMCallInvitationReceivedInfo info, String callID) {
    // رفض المكالمة تلقائيًا إذا كان المتصل محظورًا
    if (_state.blockedUsers[info.inviter] == true) {
      try {
        final config = ZIMCallRejectConfig();
        ZIM.getInstance()!.callReject(callID, config);
        Get.snackbar('مكالمة مرفوضة', 'تم رفض المكالمة من مستخدم محظور');
      } catch (e) {
        print('خطأ في رفض المكالمة: $e');
        Get.snackbar('خطأ', 'فشل في رفض المكالمة تلقائيًا');
      }
      return;
    }
    _voiceCallManager.onCallInvitationReceived(zim, info, callID);
  }

  void _onCallInvitationAccepted(ZIM zim, ZIMCallInvitationAcceptedInfo info, String callID) {
    _voiceCallManager.onCallInvitationAccepted(zim, info, callID);
  }

  void _onCallInvitationRejected(ZIM zim, ZIMCallInvitationRejectedInfo info, String callID) {
    _voiceCallManager.onCallInvitationRejected(zim, info, callID);
  }

  void _onCallInvitationCancelled(ZIM zim, ZIMCallInvitationCancelledInfo info, String callID) {
    _voiceCallManager.onCallInvitationCancelled(zim, info, callID);
  }

  void _onCallInvitationEnded(ZIM zim, ZIMCallInvitationEndedInfo info, String callID) {
    _voiceCallManager.onCallInvitationEnded(zim, info, callID);
  }

// ═══════════════ Voice Call Methods ═══════════════
  // تم تعديل startVoiceCall لمنع الاتصال بالمستخدم المحظور
  Future<void> startVoiceCall(String targetUserID) async {
    if (_state.blockedUsers[targetUserID] == true) {
      Get.snackbar('خطأ', 'لا يمكنك الاتصال بهذا المستخدم لأنك قمت بحظره.');
      return;
    }
    if (_state.blockedByMe[targetUserID] == true) { // New check for blockedByMe
      Get.snackbar('خطأ', 'لا يمكنك الاتصال بهذا المستخدم لأنك قمت بحظره.');
      return;
    }
    _voiceCallManager.startVoiceCall(targetUserID);
  }
  Future<void> endVoiceCall() => _voiceCallManager.endVoiceCall();
  Future<void> toggleMicrophone() => _voiceCallManager.toggleMicrophone();
  Future<void> toggleSpeaker() => _voiceCallManager.toggleSpeaker();
  String getFormattedCallDuration() => _voiceCallManager.getFormattedCallDuration();

// ═══════════════ Message Methods ═══════════════
  Future<void> loadMessages(String conversationID, ZIMConversationType type) =>
      _messageManager.loadMessages(conversationID, type);

  Future<void> sendTextMessage(String text, String conversationID, ZIMConversationType type) async {
    // Check block status before sending
    final isBlockedByMe = _state.blockedByMe[conversationID] ?? false;
    final isBlockedByOther = _state.blockedUsers[conversationID] ?? false;
    if (isBlockedByMe) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم لأنك قمت بحظره.');
      return;
    }
    if (isBlockedByOther) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم لأنه قام بحظرك.');
      return;
    }
    await _messageManager.sendTextMessage(text, conversationID, type);
    // تأكد من إرسال حالة التوقف عن الكتابة بعد إرسال الرسالة بنجاح
    await sendTypingStatus(conversationID, false);
  }


  Future<void> startRecording() => _messageManager.startRecording();

  Future<void> stopRecording(String conversationID, ZIMConversationType type) =>
      _messageManager.stopRecording(conversationID, type);

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

  Future<void> loadStarredMessages() => _messageManager.loadStarredMessages();

  Future<void> toggleStarMessage(ZIMMessage message) => _messageManager.toggleStarMessage(message);

  bool isMessageStarred(ZIMMessage message) => _messageManager.isMessageStarred(message);

  Future<void> searchInConversation(String conversationID, ZIMConversationType type, String query) =>
      _messageManager.searchInConversation(conversationID, type, query);

  void clearSearch() => _messageManager.clearSearch();

// ═══════════════ Media Methods ═══════════════
  Future<void> sendImageMessage(String conversationID, ZIMConversationType type, {ImageSource source = ImageSource.gallery}) async {
    final isBlockedByMe = _state.blockedByMe[conversationID] ?? false;
    final isBlockedByOther = _state.blockedUsers[conversationID] ?? false;
    if (isBlockedByMe || isBlockedByOther) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم بسبب الحظر.');
      return;
    }
    await _mediaManager.sendImageMessage(conversationID, type, source: source);
    await sendTypingStatus(conversationID, false);
  }

  Future<void> sendFileMessage(String conversationID, ZIMConversationType type) async {
    final isBlockedByMe = _state.blockedByMe[conversationID] ?? false;
    final isBlockedByOther = _state.blockedUsers[conversationID] ?? false;
    if (isBlockedByMe || isBlockedByOther) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم بسبب الحظر.');
      return;
    }
    await _mediaManager.sendFileMessage(conversationID, type);
    await sendTypingStatus(conversationID, false);
  }

  Future<void> sendVideoMessage(String conversationID, ZIMConversationType type, {ImageSource source = ImageSource.gallery}) async {
    final isBlockedByMe = _state.blockedByMe[conversationID] ?? false;
    final isBlockedByOther = _state.blockedUsers[conversationID] ?? false;
    if (isBlockedByMe || isBlockedByOther) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم بسبب الحظر.');
      return;
    }
    await _mediaManager.sendVideoMessage(conversationID, type, source: source);
    await sendTypingStatus(conversationID, false);
  }

  Future<void> openMedia(ZIMMessage message) => _mediaManager.openMedia(message);

// ═══════════════ Conversation Methods ═══════════════
  Future<void> loadConversations() => _conversationManager.loadConversations();

  Future<void> loadArchivedConversations() => _conversationManager.loadArchivedConversations();

  Future<void> archiveConversation(String conversationID) => _conversationManager.archiveConversation(conversationID);

  Future<void> unarchiveConversation(String conversationID) => _conversationManager.unarchiveConversation(conversationID);

  bool isConversationArchived(String conversationID) => _conversationManager.isConversationArchived(conversationID);

  Future<void> startNewConversation(String userID) => _conversationManager.startNewConversation(userID);

// ═══════════════ Helper Methods ═══════════════
  String getMessageText(ZIMMessage message) {
    if (message is ZIMTextMessage) return message.message;
    if (message is ZIMImageMessage) return '📷 صورة';
    if (message is ZIMFileMessage) return '📎 ملف';
    if (message is ZIMAudioMessage) return '🎵 رسالة صوتية';
    if (message is ZIMVideoMessage) return '🎥 فيديو';
    if (message is ZIMCustomMessage) {
      // لا تعرض أي نص لرسائل الكتابة
      if (message.message == 'typing_start' || message.message == 'typing_stop') {
        return '';
      }
      return message.message;
    }
    return 'رسالة';
  }

  bool isUserOnline(String userID) => _state.userOnlineStatus[userID] ?? false;
  bool isMessageRead(String messageID) => _state.messageReadStatus[messageID] ?? false;
  bool isUserTyping(String userID) => _state.typingStatus[userID] ?? false;
  bool isMediaDownloading(String messageID) => _state.isDownloading[messageID] ?? false;
  double getDownloadProgress(String messageID) => _state.downloadProgress[messageID] ?? 0.0;

// ═══════════════ Message Ordering Methods ═══════════════

  /// إضافة رسالة جديدة مع ضمان الترتيب الصحيح
  void addMessageInOrder(ZIMMessage message) {
    _messageManager.addReceivedMessage(message);
  }

  /// تحديث رسالة موجودة
  void updateMessage(ZIMMessage oldMessage, ZIMMessage newMessage) {
    final messages = _state.messages.toList();
    final index = messages.indexWhere((m) =>
    m.localMessageID == oldMessage.localMessageID ||
        m.messageID == oldMessage.messageID);

    if (index != -1) {
      messages[index] = newMessage;

      // إعادة ترتيب إذا تغير timestamp
      if (oldMessage.timestamp != newMessage.timestamp) {
        messages.removeAt(index);

        // البحث عن الموضع الجديد
        int newIndex = _findInsertPosition(messages, newMessage.timestamp);
        messages.insert(newIndex, newMessage);
      }

      _state.messages.value = messages;
    }
  }

  /// البحث عن الموضع الصحيح لإدراج رسالة جديدة
  int _findInsertPosition(List<ZIMMessage> messages, int timestamp) {
    int insertIndex = messages.length;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].timestamp <= timestamp) {
        insertIndex = i + 1;
        break;
      }
    }
    return insertIndex;
  }

  /// إزالة رسالة من القائمة
  void removeMessage(ZIMMessage message) {
    final messages = _state.messages.toList();
    messages.removeWhere((m) =>
    m.localMessageID == message.localMessageID ||
        m.messageID == message.messageID);
    _state.messages.value = messages;
  }

  /// ترتيب جميع الرسائل حسب الوقت
  void sortMessages() {
    final messages = _state.messages.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _state.messages.value = messages;
  }

  /// التحقق من وجود رسالة
  bool messageExists(ZIMMessage message) {
    return _state.messages.any((m) =>
    m.messageID == message.messageID ||
        m.localMessageID == message.localMessageID);
  }

  /// الحصول على آخر رسالة في المحادثة
  ZIMMessage? getLastMessage() {
    if (_state.messages.isEmpty) return null;
    return _state.messages.last;
  }

  /// الحصول على عدد الرسائل غير المقروءة
  int getUnreadMessageCount(String conversationID) {
    return _state.messages.where((message) =>
    message.conversationID == conversationID &&
        message.senderUserID != _state.currentUserID.value &&
        !isMessageRead(message.messageID.toString())
    ).length;
  }

  /// تحديد جميع الرسائل كمقروءة
  Future<void> markAllMessagesAsRead(String conversationID) async {
    try {
      await ZIM.getInstance()!.clearConversationUnreadMessageCount(
          conversationID, ZIMConversationType.peer);

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

  /// تحديث حالة قراءة رسالة محددة
  void updateMessageReadStatus(String messageID, bool isRead) {
    _state.messageReadStatus[messageID] = isRead;
  }

  /// الحصول على الرسائل في نطاق زمني محدد
  List<ZIMMessage> getMessagesInTimeRange(DateTime start, DateTime end) {
    final startTimestamp = start.millisecondsSinceEpoch;
    final endTimestamp = end.millisecondsSinceEpoch;

    return _state.messages.where((message) =>
    message.timestamp >= startTimestamp &&
        message.timestamp <= endTimestamp
    ).toList();
  }

  /// البحث في الرسائل
  List<ZIMMessage> searchMessages(String query) {
    if (query.isEmpty) return [];

    return _state.messages.where((message) {
      if (message is ZIMTextMessage) {
        return message.message.toLowerCase().contains(query.toLowerCase());
      }
      return false;
    }).toList();
  }

  /// تصفية الرسائل حسب النوع
  List<ZIMMessage> getMessagesByType<T extends ZIMMessage>() {
    return _state.messages.whereType<T>().toList();
  }

  /// الحصول على الرسائل الوسائطية (صور، فيديو، ملفات)
  List<ZIMMessage> getMediaMessages() {
    return _state.messages.where((message) =>
    message is ZIMImageMessage ||
        message is ZIMVideoMessage ||
        message is ZIMFileMessage ||
        message is ZIMAudioMessage
    ).toList();
  }

  /// تحديث timestamp لرسالة
  void updateMessageTimestamp(ZIMMessage message, int newTimestamp) {
    final messages = _state.messages.toList();
    final index = messages.indexWhere((m) =>
    m.localMessageID == message.localMessageID ||
        m.messageID == message.messageID);

    if (index != -1) {
      final updatedMessage = messages[index];
      updatedMessage.timestamp = newTimestamp;

      // إعادة ترتيب الرسائل
      messages.removeAt(index);
      final newIndex = _findInsertPosition(messages, newTimestamp);
      messages.insert(newIndex, updatedMessage);

      _state.messages.value = messages;
    }
  }

  /// تنظيف الرسائل القديمة (أكثر من عدد معين)
  void cleanupOldMessages({int maxMessages = 1000}) {
    if (_state.messages.length > maxMessages) {
      final messages = _state.messages.toList();
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _state.messages.value = messages.take(maxMessages).toList();
      sortMessages(); // إعادة ترتيب حسب الوقت
    }
  }

  /// إعادة تحميل الرسائل مع ضمان الترتيب
  Future<void> refreshMessages(String conversationID, ZIMConversationType type) async {
    await loadMessages(conversationID, type);
    sortMessages();
  }

  /// تحديث قائمة المحادثات
  Future<void> refreshConversations() async {
    await _conversationManager.loadConversations();
  }

  /// الحصول على إحصائيات المحادثة
  Map<String, dynamic> getConversationStats(String conversationID) {
    final conversationMessages = _state.messages.where((m) =>
    m.conversationID == conversationID).toList();

    final textMessages = conversationMessages.whereType<ZIMTextMessage>().length;
    final imageMessages = conversationMessages.whereType<ZIMImageMessage>().length;
    final audioMessages = conversationMessages.whereType<ZIMAudioMessage>().length;
    final videoMessages = conversationMessages.whereType<ZIMVideoMessage>().length;
    final fileMessages = conversationMessages.whereType<ZIMFileMessage>().length;

    return {
      'total': conversationMessages.length,
      'text': textMessages,
      'images': imageMessages,
      'audio': audioMessages,
      'videos': videoMessages,
      'files': fileMessages,
      'unread': getUnreadMessageCount(conversationID),
    };
  }

  /// تصدير المحادثة كنص
  String exportConversationAsText(String conversationID) {
    final conversationMessages = _state.messages.where((m) =>
    m.conversationID == conversationID).toList();

    final buffer = StringBuffer();
    buffer.writeln('تصدير المحادثة - $conversationID');
    buffer.writeln('تاريخ التصدير: ${DateTime.now()}');
    buffer.writeln('عدد الرسائل: ${conversationMessages.length}');
    buffer.writeln('${'=' * 50}');

    for (final message in conversationMessages) {
      final time = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
      final sender = message.senderUserID == _state.currentUserID.value ? 'أنت' : message.senderUserID;

      buffer.writeln('[$time] $sender:');

      if (message is ZIMTextMessage) {
        buffer.writeln(' ${message.message}');
      } else {
        buffer.writeln(' ${getMessageText(message)}');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// حفظ المحادثة في ملف
  Future<String?> saveConversationToFile(String conversationID) async {
    try {
      final content = exportConversationAsText(conversationID);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/conversation_$conversationID.txt');

      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      print('خطأ في حفظ المحادثة: $e');
      return null;
    }
  }

  /// مشاركة المحادثة
  Future<void> shareConversation(String conversationID) async {
    try {
      final filePath = await saveConversationToFile(conversationID);
      if (filePath != null) {
        // يمكن إضافة مكتبة المشاركة هنا
        Get.snackbar('نجح', 'تم حفظ المحادثة في: $filePath');
      }
    } catch (e) {
      print('خطأ في مشاركة المحادثة: $e');
      Get.snackbar('خطأ', 'فشل في مشاركة المحادثة');
    }
  }

  // ═══════════════ Block User Methods ═══════════════
  Future<void> toggleBlockUser(String userID) async {
    final isBlocked = _state.blockedByMe[userID] ?? false; // استخدم blockedByMe
    _state.blockedByMe[userID] = !isBlocked;

    // تحديث blockedUsers بناءً على blockedByMe
    if (_state.blockedByMe[userID] == true) {
      _state.blockedUsers[userID] = true;
    } else {
      _state.blockedUsers[userID] = false;
    }

    Get.snackbar(
      isBlocked ? 'تم الإلغاء' : 'تم الحظر',
      isBlocked ? 'تم إلغاء حظر المستخدم' : 'تم حظر المستخدم بنجاح',
    );

    // حفظ قائمة blockedByMe في SharedPreferences
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    final blockedByMeList = prefs.getStringList('blocked_by_me') ?? [];
    if (isBlocked) {
      blockedByMeList.remove(userID);
    } else {
      blockedByMeList.add(userID);
    }
    await prefs.setStringList('blocked_by_me', blockedByMeList);
    // لن نرسل إشعارًا للطرف الآخر، الحظر يكون محليًا فقط
  }

  void _loadBlockedUsers() {
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    final blockedByMeList = prefs.getStringList('blocked_by_me') ?? [];
    for (var userID in blockedByMeList) {
      _state.blockedByMe[userID] = true;
      _state.blockedUsers[userID] = true; // يتم تحديث blockedUsers بناءً على blockedByMe عند التحميل
    }
  }

// ═══════════════ Delete Conversation Method ═══════════════
  Future<void> deleteConversation(String conversationID, ZIMConversationType type) async {
    try {
      // إعدادات حذف المحادثة (استخدام الافتراضيات)
      final config = ZIMConversationDeleteConfig();

      // حذف المحادثة باستخدام ZIM SDK مع جميع الوسيطات الثلاثة
      await ZIM.getInstance()!.deleteConversation(conversationID, type, config);

      // إزالة المحادثة من القائمة المحلية
      _state.conversations.removeWhere((conv) => conv.conversationID == conversationID);
      // لا نمسح كل الرسائل، فقط الرسائل المتعلقة بالمحادثة المحذوفة إذا كانت نشطة
      if (_state.messages.any((msg) => msg.conversationID == conversationID)) {
        _state.messages.removeWhere((msg) => msg.conversationID == conversationID);
      }
      Get.snackbar('تم', 'تم حذف المحادثة بنجاح');
      Get.back(); // الرجوع إلى الشاشة السابقة
      // إعادة تحميل قائمة المحادثات لضمان التحديث
      await _conversationManager.loadConversations();
    } catch (e) {
      print('خطأ في حذف المحادثة: $e');
      Get.snackbar('خطأ', 'فشل في حذف المحادثة');
    }
  }



  @override
  void onClose() {
    _voiceCallManager.dispose();
    _messageManager.dispose();
    _mediaManager.dispose();
    _conversationManager.dispose();

// تنظيف ZIM callbacks
    ZIMEventHandler.onConnectionStateChanged = null;
    ZIMEventHandler.onConversationChanged = null;
    ZIMEventHandler.onPeerMessageReceived = null;
    ZIMEventHandler.onMessageReceiptChanged = null;
    ZIMEventHandler.onConversationTotalUnreadMessageCountUpdated = null;
    ZIMEventHandler.onError = null;
    ZIMEventHandler.onCallInvitationReceived = null;
    ZIMEventHandler.onCallInvitationAccepted = null;
    ZIMEventHandler.onCallInvitationRejected = null;
    ZIMEventHandler.onCallInvitationCancelled = null;
    ZIMEventHandler.onCallInvitationEnded = null;

    super.onClose();
  }
}
