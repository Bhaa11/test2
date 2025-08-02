// 6. مدير المحادثات: conversation_manager.dart
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import '../../core/services/services.dart';
import 'chat_state.dart';

class ConversationManager {
  final ChatState _state;

  ConversationManager(this._state);

  // ═══════════════ إدارة المحادثات ═══════════════

  Future<void> loadConversations() async {
    _state.isLoading.value = true;
    try {
      final config = ZIMConversationQueryConfig()..count = 100;
      final result = await ZIM.getInstance()!.queryConversationList(config);

      _state.conversations.value = result.conversationList.where((conv) =>
      !isConversationArchived(conv.conversationID)).toList();

      for (var conv in _state.conversations) {
        _updateUserOnlineStatus(conv.conversationID);
      }
    } catch (e) {
      print('خطأ في تحميل المحادثات: $e');
    } finally {
      _state.isLoading.value = false;
    }
  }

  Future<void> loadArchivedConversations() async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final archivedIds = prefs.getStringList('archived_conversations') ?? [];

      final config = ZIMConversationQueryConfig()..count = 100;
      final result = await ZIM.getInstance()!.queryConversationList(config);

      _state.archivedConversations.value = result.conversationList.where((conv) =>
          archivedIds.contains(conv.conversationID)).toList();
    } catch (e) {
      print('خطأ في تحميل المحادثات المؤرشفة: $e');
    }
  }

  Future<void> archiveConversation(String conversationID) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final archivedIds = prefs.getStringList('archived_conversations') ?? [];

      if (!archivedIds.contains(conversationID)) {
        archivedIds.add(conversationID);
        await prefs.setStringList('archived_conversations', archivedIds);
        await loadConversations();
        await loadArchivedConversations();
      }
    } catch (e) {
      print('خطأ في أرشفة المحادثة: $e');
    }
  }

  Future<void> unarchiveConversation(String conversationID) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final archivedIds = prefs.getStringList('archived_conversations') ?? [];

      archivedIds.remove(conversationID);
      await prefs.setStringList('archived_conversations', archivedIds);
      await loadConversations();
      await loadArchivedConversations();
    } catch (e) {
      print('خطأ في إلغاء أرشفة المحادثة: $e');
    }
  }

  bool isConversationArchived(String conversationID) {
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    final archivedIds = prefs.getStringList('archived_conversations') ?? [];
    return archivedIds.contains(conversationID);
  }

  Future<void> startNewConversation(String userID) async {
    try {
      final message = ZIMTextMessage(message: "مرحباً!");
      final config = ZIMMessageSendConfig();

      await ZIM.getInstance()!.sendMessage(message, userID, ZIMConversationType.peer, config);
      await loadConversations();
    } catch (e) {
      print('خطأ في بدء المحادثة: $e');
    }
  }

  // ═══════════════ حالة الاتصال ═══════════════

  Future<void> _updateUserOnlineStatus(String userID) async {
    try {
      _state.userOnlineStatus[userID] = true;
    } catch (e) {
      print('خطأ في تحديث حالة الاتصال: $e');
    }
  }

  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
  }
}
