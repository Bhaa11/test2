import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../controller/chat/chat_controller.dart';
import '../../../controller/chat/voice_message_player.dart';
import '../../../controller/chat/voice_recording_widget.dart';
import '../../../core/constant/color.dart';
import 'image_viewer_page.dart';
import 'audio_player_page.dart';
import 'voice_call_page.dart';

class MessagePage extends StatefulWidget {
  final String conversationID;
  final ZIMConversationType conversationType;
  final String conversationName;

  const MessagePage({
    super.key,
    required this.conversationID,
    required this.conversationType,
    required this.conversationName,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatController controller;
  late AnimationController _animationController;
  late AnimationController _recordingAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _searchAnimationController;

  bool _isTyping = false;
  bool _showAttachmentMenu = false;
  bool _showVoiceRecording = false;
  bool _autoScroll = true; // Flag to control auto-scrolling
  bool _isUserScrolling = false; // Flag to detect if user is manually scrolling
  bool _isInitialLoad = true; // Flag to manage initial message loading
  bool _isSearchMode = false;
  Timer? _scrollTimer;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    controller = ChatController.instance;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _messageController.addListener(() {
      final isNowTyping = _messageController.text.isNotEmpty;
      if (isNowTyping != _isTyping) {
        setState(() => _isTyping = isNowTyping);
        isNowTyping ? _animationController.forward() : _animationController.reverse();
        controller.sendTypingStatus(widget.conversationID, isNowTyping);
      }
    });

    // مراقبة البحث
    _searchController.addListener(() {
      _searchTimer?.cancel();
      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (_searchController.text.isNotEmpty) {
          controller.searchInConversation(
            widget.conversationID,
            widget.conversationType,
            _searchController.text,
          );
        } else {
          controller.clearSearch();
        }
      });
    });

    // مراقبة تغييرات الرسائل للتمرير التلقائي
    ever(controller.messages, (List<ZIMMessage> messages) {
      if (messages.isNotEmpty && !_isSearchMode) {
        // If it's the initial load and the list is not empty, scroll to the bottom immediately.
        if (_isInitialLoad) {
          _isInitialLoad = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottomImmediate();
          });
        } else if (_autoScroll && !_isUserScrolling) {
          // If auto-scroll is enabled and the user is not scrolling, scroll to the bottom.
          _scrollToBottom();
        }
      }
    });

    _scrollController.addListener(_onScroll);
    _loadMessages();
    _listAnimationController.forward();
  }

  Future<void> _loadMessages() async {
    await controller.loadMessages(widget.conversationID, widget.conversationType);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final minScroll = _scrollController.position.minScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // إذا كان المستخدم يتمرر لأعلى بعيدًا عن الرسالة الأحدث، قم بتعطيل التمرير التلقائي
      if (currentScroll > 100) {
        setState(() {
          _autoScroll = false;
          _isUserScrolling = true;
        });
      } else {
        // إذا كان المستخدم قريبًا من الأسفل، قم بتفعيل التمرير التلقائي
        setState(() {
          _autoScroll = true;
          _isUserScrolling = false;
        });
      }
    }
  }

  void _scrollToBottom({bool force = false}) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && (_autoScroll || force)) {
        _scrollController.animateTo(
          0.0, // التمرير إلى الأعلى (الرسالة الأحدث بسبب reverse: true)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // This method scrolls to the bottom immediately without animation.
  // It's called only on the initial load to ensure the user sees the latest messages.
  void _scrollToBottomImmediate() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0); // التمرير الفوري إلى الأعلى (الرسالة الأحدث)
    }
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        controller.clearSearch();
        _searchAnimationController.reverse();
      } else {
        _searchAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isSearchMode) _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [
                Obx(() => _buildMessagesList()),
                if (!_autoScroll && !_isSearchMode) _buildScrollToBottomButton(),
              ],
            ),
          ),
          if (_showAttachmentMenu && !_showVoiceRecording) _buildAttachmentMenu(),
          if (!_isSearchMode) _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.lightGrey,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.arrow_back_ios_rounded, color: AppColor.black, size: 18.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.secondColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    widget.conversationName.isNotEmpty
                        ? widget.conversationName[0].toUpperCase()
                        : '?',
                    style: TextStyle(color: AppColor.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Obx(() {
                  final online = controller.isUserOnline(widget.conversationID);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: online ? 14.w : 0,
                    height: online ? 14.w : 0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.white, width: 2),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversationName.isNotEmpty ? widget.conversationName : 'مستخدم',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColor.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Obx(() {
                  final typing = controller.isUserTyping(widget.conversationID);
                  final online = controller.isUserOnline(widget.conversationID);
                  final inCall = controller.isInVoiceCall.value &&
                      controller.currentCallUserID.value == widget.conversationID;

                  if (inCall) {
                    return Text(
                      'في مكالمة صوتية',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }

                  if (typing) {
                    return Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 14.sp,
                          color: AppColor.primaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'يكتب...',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primaryColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      online ? 'متصل الآن' : 'غير متصل',
                      key: ValueKey(online ? 'online' : 'offline'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: online ? Colors.green : AppColor.grey2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!_isSearchMode) ...[
          Obx(() {
            final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
            final isBlockedByOther = controller.blockedUsers[widget.conversationID] ?? false; // Assuming blockedUsers means blocked by other
            final isBlocked = isBlockedByMe || isBlockedByOther;
            return _buildAppBarButton(Icons.call_rounded, isBlocked ? () => Get.snackbar('ممنوع', 'لا يمكنك الاتصال بسبب الحظر.') : () {
              if (!controller.isInVoiceCall.value) {
                controller.startVoiceCall(widget.conversationID);
              } else {
                Get.snackbar('معلومة', 'لديك مكالمة نشطة بالفعل');
              }
            });
          }),
          Obx(() {
            final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
            final isBlockedByOther = controller.blockedUsers[widget.conversationID] ?? false;
            final isBlocked = isBlockedByMe || isBlockedByOther;
            return _buildAppBarButton(Icons.videocam_rounded, isBlocked ? () => Get.snackbar('ممنوع', 'لا يمكنك الاتصال بسبب الحظر.') : () {});
          }),
          _buildAppBarButton(Icons.more_vert_rounded, _showChatOptions, margin: EdgeInsets.only(right: 16.w)),
        ] else ...[
          _buildAppBarButton(Icons.close, _toggleSearchMode, margin: EdgeInsets.only(right: 16.w)),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _searchAnimationController.value)),
          child: Opacity(
            opacity: _searchAnimationController.value,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.lightGrey,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'البحث في المحادثة...',
                          hintStyle: TextStyle(
                            color: AppColor.grey2,
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColor.grey2,
                            size: 22.sp,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColor.grey2,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              controller.clearSearch();
                            },
                          )
                              : null,
                        ),
                        style: TextStyle(fontSize: 15.sp, color: AppColor.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(() {
                    final results = controller.searchResults;
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${results.length} نتيجة',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onTap, {EdgeInsets? margin}) {
    return Container(
      margin: margin ?? EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: IconButton(icon: Icon(icon, color: AppColor.black, size: 20.sp), onPressed: onTap),
    );
  }

  Widget _buildMessagesList() {
    final msgs = _isSearchMode ? controller.searchResults : controller.messages;
    // تصفية الرسائل لتجاهل الرسائل المخصصة المتعلقة بحالة الكتابة
    final filteredMsgs = msgs.where((msg) =>
    !(msg is ZIMCustomMessage &&
        (msg.message == 'typing_start' || msg.message == 'typing_stop'))).toList();

    if (filteredMsgs.isEmpty) {
      if (_isSearchMode && _searchController.text.isNotEmpty) {
        return _buildNoSearchResults();
      }
      return _buildEmptyMessages();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // قلب الترتيب لعرض الرسائل من الأسفل إلى الأعلى
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: filteredMsgs.length,
      itemBuilder: (context, index) {
        // قلب الفهرس بسبب reverse: true
        final msg = filteredMsgs[filteredMsgs.length - 1 - index];
        // الأول في الترتيب المقلوب هو الأقدم
        final isFirst = index == filteredMsgs.length - 1;
        // الأخير في الترتيب المقلوب هو الأحدث
        final isLast = index == 0;
        final showAvatar = isLast ||
            (index > 0 && filteredMsgs[filteredMsgs.length - index].senderUserID != msg.senderUserID);

        return _buildMessageBubble(msg, showAvatar, isFirst);
      },
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 40.sp, color: AppColor.grey2),
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم العثور على رسائل تحتوي على "${_searchController.text}"',
            style: TextStyle(fontSize: 14.sp, color: AppColor.grey2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.thirdColor, AppColor.primaryColor.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.waving_hand_rounded, size: 50.sp, color: AppColor.primaryColor),
          ),
          SizedBox(height: 24.h),
          Text('قل مرحباً! 👋',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColor.black)),
          SizedBox(height: 8.h),
          Text('ابدأ محادثتك مع ${widget.conversationName.isNotEmpty ? widget.conversationName : 'المستخدم'}',
              style: TextStyle(fontSize: 16.sp, color: AppColor.grey2)),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 20.h,
      right: 20.w,
      child: AnimatedOpacity(
        opacity: _autoScroll ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.small(
          onPressed: () {
            setState(() {
              _autoScroll = true; // Re-enable auto-scroll when button is pressed
            });
            _scrollToBottom(force: true);
          },
          backgroundColor: AppColor.primaryColor,
          child: Icon(Icons.keyboard_arrow_down, color: AppColor.white),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ZIMMessage message, bool showAvatar, bool isFirst) {
    final isMe = message.senderUserID == controller.currentUserID.value;
    final isHighlighted = _isSearchMode && _searchController.text.isNotEmpty;

    String getFirstLetter() {
      if (message.senderUserID.isNotEmpty) {
        return message.senderUserID[0];
      }
      return '?';
    }

    return Container(
      margin: EdgeInsets.only(bottom: showAvatar ? 16.h : 4.h, top: isFirst ? 8.h : 0),
      decoration: isHighlighted ? BoxDecoration(
        color: Colors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ) : null,
      padding: isHighlighted ? EdgeInsets.all(4.w) : null,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar ? _avatarCircle(getFirstLetter()) : SizedBox(width: 32.w),
            SizedBox(width: 8.w),
          ],
          Flexible(child: _messageContainer(message, isMe)),
          if (isMe) ...[
            SizedBox(width: 8.w),
            showAvatar ? _avatarCircle(getFirstLetter()) : SizedBox(width: 32.w),
          ],
        ],
      ),
    );
  }

  Widget _avatarCircle(String letter) => Container(
    width: 32.w,
    height: 32.w,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColor.primaryColor, AppColor.secondColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Center(
      child: Text(
          letter.toUpperCase(),
          style: TextStyle(color: AppColor.white, fontSize: 12.sp, fontWeight: FontWeight.bold)
      ),
    ),
  );

  Widget _messageContainer(ZIMMessage message, bool isMe) {
    return GestureDetector(
        onLongPress: () => _showMessageOptions(message),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
              colors: [AppColor.primaryColor, AppColor.secondColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isMe ? null : AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(isMe ? 20.r : 6.r),
              bottomRight: Radius.circular(isMe ? 6.r : 20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: isMe
                    ? AppColor.primaryColor.withOpacity(0.2)
                    : AppColor.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessageContent(message, isMe),
              if (message is! ZIMAudioMessage) ...[
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min, // تصحيح الخطأ هنا
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isMe ? AppColor.white.withOpacity(0.8) : AppColor.grey2,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Obx(() {
                        final read = controller.isMessageRead(message.messageID.toString());
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            read ? Icons.done_all_rounded : Icons.done_rounded,
                            key: ValueKey(read),
                            size: 14.sp,
                            color: read ? Colors.blue : AppColor.white.withOpacity(0.8),
                          ),
                        );
                      }),
                    ],
                  ],
                )
              ],
            ],
          ),
        ));
  }

  Widget _buildMessageContent(ZIMMessage message, bool isMe) {
    if (message is ZIMTextMessage) {
      // تمييز النص المطابق للبحث
      if (_isSearchMode && _searchController.text.isNotEmpty) {
        return _buildHighlightedText(message.message, _searchController.text, isMe);
      }
      return SelectableText(
        message.message,
        style: TextStyle(color: isMe ? AppColor.white : AppColor.black, fontSize: 15.sp, height: 1.4),
      );
    } else if (message is ZIMImageMessage) {
      return _buildImageMessage(message);
    } else if (message is ZIMVideoMessage) {
      return _buildVideoMessage(message);
    } else if (message is ZIMAudioMessage) {
      return _buildAudioMessage(message, isMe);
    } else if (message is ZIMFileMessage) {
      return _buildFileMessage(message);
    }
    return Text(controller.getMessageText(message),
        style: TextStyle(color: isMe ? AppColor.white : AppColor.black, fontSize: 15.sp, height: 1.4));
  }

  Widget _buildHighlightedText(String text, String query, bool isMe) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: isMe ? AppColor.white : AppColor.black, fontSize: 15.sp, height: 1.4),
      );
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(color: isMe ? AppColor.white : AppColor.black),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(color: isMe ? AppColor.white : AppColor.black),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: isMe ? AppColor.white : AppColor.black,
          backgroundColor: Colors.yellow.withOpacity(0.6),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(fontSize: 15.sp, height: 1.4),
      ),
    );
  }

  Widget _buildImageMessage(ZIMImageMessage message) {
    return GestureDetector(
      onTap: () => controller.openMedia(message),
      child: Container(
        width: 200.w,
        height: 200.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColor.lightGrey,
        ),
        child: message.fileLocalPath.isNotEmpty && File(message.fileLocalPath).existsSync()
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(File(message.fileLocalPath), fit: BoxFit.cover),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 40.sp, color: AppColor.grey2),
              SizedBox(height: 8.h),
              Obx(() => controller.isMediaDownloading(message.messageID.toString())
                  ? Column(
                children: [
                  CircularProgressIndicator(
                    value: controller.getDownloadProgress(message.messageID.toString()),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${(controller.getDownloadProgress(message.messageID.toString()) * 100).toInt()}%',
                    style: TextStyle(color: AppColor.grey2, fontSize: 12.sp),
                  ),
                ],
              )
                  : Text('اضغط للعرض', style: TextStyle(color: AppColor.grey2))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(ZIMVideoMessage message) {
    return GestureDetector(
      onTap: () => controller.openMedia(message),
      child: Container(
        width: 200.w,
        height: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColor.lightGrey,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.videocam, size: 50.sp, color: AppColor.grey2),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4.r)),
                child: Text('🎥 فيديو', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
              ),
            ),
            Obx(() => controller.isMediaDownloading(message.messageID.toString())
                ? CircularProgressIndicator(
              value: controller.getDownloadProgress(message.messageID.toString()),
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
            )
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(ZIMAudioMessage message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoiceMessagePlayer(
          audioPath: message.fileLocalPath.isNotEmpty
              ? message.fileLocalPath
              : '',
          duration: message.audioDuration,
          isMe: isMe,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                fontSize: 11.sp,
                color: isMe ? AppColor.white.withOpacity(0.8) : AppColor.grey2,
              ),
            ),
            if (isMe) ...[
              SizedBox(width: 4.w),
              Obx(() {
                final read = controller.isMessageRead(message.messageID.toString());
                return Icon(
                  read ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 14.sp,
                  color: read ? Colors.blue : AppColor.white.withOpacity(0.8),
                );
              }),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFileMessage(ZIMFileMessage message) {
    return GestureDetector(
      onTap: () => controller.openMedia(message),
      child: Container(
        width: 250.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: AppColor.lightGrey),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: AppColor.fourthColor, borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.insert_drive_file, color: AppColor.white, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.fileName ?? 'ملف',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${(message.fileSize / 1024).toStringAsFixed(1)} KB',
                      style: TextStyle(color: AppColor.grey2, fontSize: 12.sp)),
                ],
              ),
            ),
            Obx(() => controller.isMediaDownloading(message.messageID.toString())
                ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                value: controller.getDownloadProgress(message.messageID.toString()),
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                strokeWidth: 2,
              ),
            )
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return Container(
      height: 120.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [BoxShadow(color: AppColor.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentOption(Icons.camera_alt_rounded, 'كاميرا', AppColor.errorRed, () {
            setState(() => _showAttachmentMenu = false);
            controller.sendImageMessage(widget.conversationID, widget.conversationType,
                source: ImageSource.camera);
          }),
          _buildAttachmentOption(Icons.photo_library_rounded, 'معرض', AppColor.fourthColor, () {
            setState(() => _showAttachmentMenu = false);
            controller.sendImageMessage(widget.conversationID, widget.conversationType);
          }),
          _buildAttachmentOption(Icons.videocam_rounded, 'فيديو', Colors.purple, () {
            setState(() => _showAttachmentMenu = false);
            controller.sendVideoMessage(widget.conversationID, widget.conversationType);
          }),
          _buildAttachmentOption(Icons.insert_drive_file_rounded, 'ملف', AppColor.primaryColor, () {
            setState(() => _showAttachmentMenu = false);
            controller.sendFileMessage(widget.conversationID, widget.conversationType);
          }),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(label, style: TextStyle(fontSize: 12.sp, color: AppColor.grey2, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _buildMessageInput() {
    final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
    final isBlockedByOther = controller.blockedUsers[widget.conversationID] ?? false;
    final bool isBlocked = isBlockedByMe || isBlockedByOther;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showVoiceRecording ? 200.h : 80.h,
      child: Column(
        children: [
          if (_showVoiceRecording && !isBlocked)
            VoiceRecordingWidget(
              conversationID: widget.conversationID,
              conversationType: widget.conversationType,
              onCancel: () {
                setState(() {
                  _showVoiceRecording = false;
                });
              },
            ),

          if (!_showVoiceRecording)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: isBlocked
                    ? Center(
                  child: Text(
                    isBlockedByMe
                        ? 'لا يمكنك إرسال رسائل إلى هذا المستخدم لأنك قمت بحظره.'
                        : 'لا يمكنك إرسال رسائل إلى هذا المستخدم لأنه قام بحظرك.',
                    style: TextStyle(color: AppColor.grey2, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                )
                    : Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.lightGrey,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: IconButton(
                        icon: AnimatedRotation(
                          turns: _showAttachmentMenu ? 0.125 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _showAttachmentMenu ? Icons.close : Icons.add_rounded,
                            color: AppColor.grey2,
                            size: 24.sp,
                          ),
                        ),
                        onPressed: () => setState(() =>
                        _showAttachmentMenu = !_showAttachmentMenu),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: TextStyle(
                              color: AppColor.grey2,
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: AppColor.grey2,
                                size: 22.sp,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          maxLines: null,
                          style: TextStyle(fontSize: 15.sp, color: AppColor.black),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColor.primaryColor, AppColor.secondColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _isTyping
                                ? _sendMessage
                                : () {
                              setState(() {
                                _showVoiceRecording = true;
                                _showAttachmentMenu = false;
                              });
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                                key: ValueKey(_isTyping),
                                color: AppColor.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    // التحقق من حالة الحظر قبل الإرسال
    final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
    final isBlockedByOther = controller.blockedUsers[widget.conversationID] ?? false;
    if (isBlockedByMe) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم لأنك قمت بحظره.');
      return;
    }
    if (isBlockedByOther) {
      Get.snackbar('ممنوع', 'لا يمكنك إرسال رسائل لهذا المستخدم لأنه قام بحظرك.');
      return;
    }

    if (text.isNotEmpty) {
      controller.sendTextMessage(text, widget.conversationID, widget.conversationType);
      _messageController.clear();
      // تأكد من إرسال حالة التوقف عن الكتابة بعد إرسال الرسالة
      controller.sendTypingStatus(widget.conversationID, false);
      setState(() {
        _autoScroll = true; // التأكد من تفعيل التمرير التلقائي بعد الإرسال
        _isTyping = false; // إعادة تعيين حالة الكتابة محلياً
        _animationController.reverse(); // عكس حركة زر الإرسال
      });
      _scrollToBottom(force: true);
    }
  }

  void _showMessageOptions(ZIMMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.r), topRight: Radius.circular(25.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                    color: AppColor.grey3,
                    borderRadius: BorderRadius.circular(2.r)
                )
            ),
            SizedBox(height: 20.h),
            _buildMessageOption(Icons.star_outline,
                controller.isMessageStarred(message) ? 'إزالة من المفضلة' : 'إضافة للمفضلة', () {
                  Navigator.pop(ctx);
                  controller.toggleStarMessage(message);
                }),
            if (message is ZIMTextMessage)
              _buildMessageOption(Icons.copy, 'نسخ', () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: message.message));
                Get.snackbar('تم النسخ', 'تم نسخ النص بنجاح');
              }),
            _buildMessageOption(Icons.reply, 'رد', () {
              Navigator.pop(ctx);
              // إضافة وظيفة الرد هنا
            }),
            if (message.senderUserID == controller.currentUserID.value)
              _buildMessageOption(Icons.delete_outline, 'حذف', () {
                Navigator.pop(ctx);
                // إضافة وظيفة الحذف هنا
              }),
            _buildMessageOption(Icons.info_outline, 'تفاصيل الرسالة', () {
              Navigator.pop(ctx);
              _showMessageDetails(message);
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageOption(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: AppColor.lightGrey,
            borderRadius: BorderRadius.circular(12.r)
        ),
        child: Icon(icon, color: AppColor.grey2, size: 20.sp)
    ),
    title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColor.black)),
    onTap: onTap,
  );

  void _showMessageDetails(ZIMMessage message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تفاصيل الرسالة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الوقت: ${_formatFullMessageTime(message.timestamp)}'),
            SizedBox(height: 8.h),
            Text('المرسل: ${message.senderUserID}'),
            SizedBox(height: 8.h),
            Text('معرف الرسالة: ${message.messageID}'),
            if (message is ZIMTextMessage) ...[
              SizedBox(height: 8.h),
              Text('النص: ${message.message}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.r), topRight: Radius.circular(25.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                    color: AppColor.grey3,
                    borderRadius: BorderRadius.circular(2.r)
                )
            ),
            SizedBox(height: 20.h),
            _buildChatOption(Icons.info_outline_rounded, 'معلومات المحادثة', _showConversationInfo),
            _buildChatOption(Icons.search_rounded, 'البحث في المحادثة', () {
              Navigator.pop(ctx);
              _toggleSearchMode();
            }),
            _buildChatOption(Icons.notifications_off_outlined, 'كتم الإشعارات', () {
              Navigator.pop(ctx);
              // إضافة وظيفة كتم الإشعارات
            }),
            _buildChatOption(Icons.archive_outlined, 'أرشفة المحادثة', () {
              Navigator.pop(ctx);
              controller.archiveConversation(widget.conversationID);
              Get.back();
            }),
            Obx(() {
              final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
              return _buildChatOption(
                Icons.block_rounded,
                isBlockedByMe ? 'إلغاء حظر المستخدم' : 'حظر المستخدم',
                    () {
                  Navigator.pop(ctx);
                  _showBlockConfirmation();
                },
              );
            }),
            _buildChatOption(Icons.delete_outline, 'حذف المحادثة', () {
              Navigator.pop(ctx);
              _showDeleteConfirmation();
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption(IconData icon, String title, [VoidCallback? onTap]) => ListTile(
    leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: AppColor.lightGrey,
            borderRadius: BorderRadius.circular(12.r)
        ),
        child: Icon(icon, color: AppColor.grey2, size: 20.sp)
    ),
    title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColor.black)),
    onTap: onTap ?? () => Navigator.pop(context),
  );

  void _showConversationInfo() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              topRight: Radius.circular(25.r),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.grey3,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      // صورة المستخدم
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColor.primaryColor, AppColor.secondColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.conversationName.isNotEmpty
                                ? widget.conversationName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // اسم المستخدم
                      Text(
                        widget.conversationName.isNotEmpty ? widget.conversationName : 'مستخدم',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // حالة الاتصال
                      Obx(() {
                        final online = controller.isUserOnline(widget.conversationID);
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: online ? Colors.green.withOpacity(0.1) : AppColor.lightGrey,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: online ? Colors.green : AppColor.grey2,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                online ? 'متصل الآن' : 'غير متصل',
                                style: TextStyle(
                                  color: online ? Colors.green : AppColor.grey2,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 30.h),

                      // إحصائيات المحادثة
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إحصائيات المحادثة',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.black,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Obx(() {
                              final stats = controller.getConversationStats(widget.conversationID);
                              return Column(
                                children: [
                                  _buildStatRow('إجمالي الرسائل', '${stats['total']}', Icons.message),
                                  _buildStatRow('الرسائل النصية', '${stats['text']}', Icons.text_fields),
                                  _buildStatRow('الصور', '${stats['images']}', Icons.image),
                                  _buildStatRow('الملفات الصوتية', '${stats['audio']}', Icons.audiotrack),
                                  _buildStatRow('مقاطع الفيديو', '${stats['videos']}', Icons.videocam),
                                  _buildStatRow('الملفات', '${stats['files']}', Icons.attach_file),
                                  _buildStatRow('غير مقروءة', '${stats['unread']}', Icons.mark_email_unread),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // خيارات إضافية
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'خيارات المحادثة',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.black,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildInfoOption(
                              Icons.download,
                              'تصدير المحادثة',
                              'حفظ المحادثة كملف نصي',
                                  () async {
                                Navigator.pop(ctx);
                                await controller.shareConversation(widget.conversationID);
                              },
                            ),
                            _buildInfoOption(
                              Icons.clear_all,
                              'مسح سجل المحادثة',
                              'حذف جميع الرسائل',
                                  () {
                                Navigator.pop(ctx);
                                _showClearHistoryConfirmation();
                              },
                            ),
                            Obx(() {
                              final isBlockedByMe = controller.blockedByMe[widget.conversationID] ?? false;
                              return _buildInfoOption(
                                Icons.block,
                                isBlockedByMe ? 'إلغاء حظر المستخدم' : 'حظر المستخدم',
                                isBlockedByMe ? 'السماح باستقبال الرسائل' : 'منع استقبال الرسائل',
                                    () {
                                  Navigator.pop(ctx);
                                  _showBlockConfirmation();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColor.primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColor.primaryColor, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColor.grey2,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteConversation(widget.conversationID, widget.conversationType);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('مسح سجل المحادثة'),
        content: Text('هل أنت متأكد من مسح جميع الرسائل؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.messages.clear(); // Clear local messages
              Get.snackbar('تم', 'تم مسح سجل المحادثة');
            },
            child: Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => Obx(() {
        final isBlocked = controller.blockedByMe[widget.conversationID] ?? false; // استخدم blockedByMe
        return AlertDialog(
          title: Text(isBlocked ? 'إلغاء حظر المستخدم' : 'حظر المستخدم'),
          content: Text(isBlocked
              ? 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟ ستتمكن من استقبال رسائله.'
              : 'هل أنت متأكد من حظر هذا المستخدم؟ لن تتمكن من استقبال رسائله.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                controller.toggleBlockUser(widget.conversationID);
              },
              child: Text(isBlocked ? 'إلغاء الحظر' : 'حظر', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      }),
    );
  }

  String _formatMessageTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatFullMessageTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // إرسال حالة التوقف عن الكتابة عند الخروج من الشاشة
    if (_isTyping) {
      controller.sendTypingStatus(widget.conversationID, false);
    }
    _scrollTimer?.cancel();
    _searchTimer?.cancel();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _recordingAnimationController.dispose();
    _listAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }
}
