import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../core/constant/color.dart';

class ArchivedChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatController controller = ChatController.instance;

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('المحادثات المؤرشفة'),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Obx(() => ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.archivedConversations.length,
        itemBuilder: (context, index) {
          final conversation = controller.archivedConversations[index];
          return Card(
            child: ListTile(
              title: Text(conversation.conversationName.isNotEmpty
                  ? conversation.conversationName
                  : conversation.conversationID),
              trailing: IconButton(
                icon: Icon(Icons.unarchive),
                onPressed: () => controller.unarchiveConversation(conversation.conversationID),
              ),
            ),
          );
        },
      )),
    );
  }
}