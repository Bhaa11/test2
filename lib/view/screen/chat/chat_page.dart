import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../core/constant/color.dart';
import 'archive_page.dart';
import 'message_page.dart';
import 'starred_messages_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColor.primaryColor,
            title: Text(
              'المحادثات',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: AppColor.white,
                  size: 24.sp,
                ),
                onPressed: () => _showGlobalSearch(context, controller),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppColor.white,
                  size: 24.sp,
                ),
                color: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.settings_rounded,
                            color: AppColor.grey2, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('الإعدادات', style: TextStyle(fontSize: 15.sp)),
                      ],
                    ),
                    onTap: () {},
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.archive_rounded,
                            color: AppColor.grey2, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('المحادثات المؤرشفة',
                            style: TextStyle(fontSize: 15.sp)),
                      ],
                    ),
                    onTap: () => Get.to(() => ArchivedChatsPage()),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColor.grey2, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('الرسائل المميزة',
                            style: TextStyle(fontSize: 15.sp)),
                      ],
                    ),
                    onTap: () => Get.to(() => StarredMessagesPage()),
                  ),
                ],
              ),
            ],
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return SliverFillRemaining(
                child: _buildLoadingState(),
              );
            }

            if (controller.conversations.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(context, controller),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final conversation = controller.conversations[index];
                  return _buildConversationCard(
                      context, conversation, controller);
                },
                childCount: controller.conversations.length,
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context, controller),
        backgroundColor: AppColor.primaryColor,
        elevation: 2,
        child: Icon(
          Icons.chat_rounded,
          color: AppColor.white,
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildConversationCard(
      BuildContext context,
      ZIMConversation conversation,
      ChatController controller,
      ) {
    final hasUnread = conversation.unreadMessageCount > 0;
    final isOnline = controller.isUserOnline(conversation.conversationID);
    final isTyping = controller.isUserTyping(conversation.conversationID);
    final bool isMuted = false; // Placeholder for mute status

    // تحديد نص آخر رسالة مع استبعاد الرسائل المخصصة المتعلقة بحالة الكتابة
    String lastMessageText = 'ابدأ محادثة جديدة';
    if (conversation.lastMessage != null) {
      final messageContent = controller.getMessageText(conversation.lastMessage!);
      if (messageContent.isEmpty) {
        // إذا كانت الرسالة فارغة (مثل رسائل الكتابة)، نعرض نص افتراضي "رسالة"
        // لنتجنب إظهار "ابدأ محادثة جديدة" عندما تكون هناك رسالة حالة.
        lastMessageText = 'رسالة';
      } else {
        lastMessageText = messageContent;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.lightGrey,
            width: 0.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
                  () => MessagePage(
                conversationID: conversation.conversationID,
                conversationType: conversation.type,
                conversationName: conversation.conversationName.isNotEmpty
                    ? conversation.conversationName
                    : conversation.conversationID,
              ),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 300),
            );
          },
          onLongPress: () =>
              _showConversationOptions(context, conversation, controller),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppColor.thirdColor,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          conversation.conversationName.isNotEmpty
                              ? conversation.conversationName[0].toUpperCase()
                              : conversation.conversationID[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.white, width: 2.w),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.conversationName.isNotEmpty
                                  ? conversation.conversationName
                                  : conversation.conversationID,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessage?.timestamp ?? 0),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.grey2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          if (isMuted)
                            Icon(Icons.notifications_off_rounded,
                                size: 16.sp, color: AppColor.grey2),
                          if (isMuted) SizedBox(width: 4.w),
                          Expanded(
                            child: isTyping &&
                                (conversation.lastMessage == null ||
                                    controller.getMessageText(
                                        conversation.lastMessage!)
                                        .isEmpty)
                                ? Text(
                              'يكتب...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                                : Text(
                              lastMessageText,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColor.grey2,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  conversation.unreadMessageCount > 99
                                      ? '99+'
                                      : '${conversation.unreadMessageCount}',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConversationOptions(
      BuildContext context, ZIMConversation conversation, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColor.grey3,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _buildConversationOption(Icons.archive_rounded, 'أرشفة المحادثة',
                    () {
                  Navigator.pop(context);
                  controller.archiveConversation(conversation.conversationID);
                }),
            _buildConversationOption(
                Icons.notifications_off_outlined, 'كتم الإشعارات', () => Navigator.pop(context)),
            _buildConversationOption(Icons.delete_outline_rounded,
                'حذف المحادثة', () {
                  Navigator.pop(context);
                  controller.deleteConversation(
                      conversation.conversationID, conversation.type);
                }),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationOption(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColor.grey2, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: AppColor.black,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showGlobalSearch(BuildContext context, ChatController controller) {
    showSearch(
      context: context,
      delegate: ConversationSearchDelegate(controller),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل المحادثات...',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColor.grey2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ChatController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80.sp,
            color: AppColor.primaryColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد محادثات',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ محادثة جديدة للتواصل مع أصدقائك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.grey2,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => _showNewChatDialog(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: AppColor.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'بدء محادثة جديدة',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, ChatController controller) {
    final TextEditingController userIDController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محادثة جديدة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'معرف المستخدم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.grey2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.lightGrey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: userIDController,
                    decoration: InputDecoration(
                      hintText: 'أدخل معرف المستخدم',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      hintStyle: TextStyle(color: AppColor.grey),
                    ),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColor.black,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: AppColor.grey3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final userID = userIDController.text.trim();
                          if (userID.isNotEmpty) {
                            Navigator.of(context).pop();
                            controller.startNewConversation(userID);
                            Get.to(
                                  () => MessagePage(
                                conversationID: userID,
                                conversationType: ZIMConversationType.peer,
                                conversationName: userID,
                              ),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 300),
                            );
                          } else {
                            Get.snackbar('خطأ', 'يرجى إدخال معرف المستخدم');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: AppColor.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'بدء المحادثة',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'أمس';
      if (difference.inDays < 7) return '${difference.inDays} أيام';
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}س';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}د';
    } else {
      return 'الآن';
    }
  }
}

class ConversationSearchDelegate extends SearchDelegate<String> {
  final ChatController controller;

  ConversationSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'البحث في المحادثات...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          controller.clearSearch();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Obx(() {
      // تصفية نتائج البحث لاستبعاد الرسائل المخصصة المتعلقة بحالة الكتابة
      final filteredResults = controller.searchResults
          .where((msg) => !(msg is ZIMCustomMessage &&
          (msg.message == 'typing_start' || msg.message == 'typing_stop')))
          .toList();

      if (filteredResults.isEmpty) {
        return Center(
          child: Text(
            'لا توجد نتائج لبحثك',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.grey2,
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final message = filteredResults[index];
          return ListTile(
            leading: Icon(
              Icons.message_rounded,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
            title: Text(
              controller.getMessageText(message),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'في محادثة: ${message.conversationID}',
              style: TextStyle(fontSize: 12.sp, color: AppColor.grey2),
            ),
            onTap: () {
              close(context, '');
              Get.to(
                    () => MessagePage(
                  conversationID: message.conversationID,
                  conversationType: ZIMConversationType.peer,
                  conversationName: message.conversationID,
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      for (var conv in controller.conversations) {
        controller.searchInConversation(conv.conversationID, conv.type, query);
      }
    }
    return buildResults(context);
  }
}
