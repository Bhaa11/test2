import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../core/constant/color.dart';

class StarredMessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatController controller = ChatController.instance;

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('الرسائل المميزة'),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Obx(() => ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.starredMessages.length,
        itemBuilder: (context, index) {
          final message = controller.starredMessages[index];
          return Card(
            child: ListTile(
              title: Text(controller.getMessageText(message)),
              subtitle: Text('من: ${message.conversationID}'),
              trailing: IconButton(
                icon: Icon(Icons.star, color: Colors.amber),
                onPressed: () => controller.toggleStarMessage(message),
              ),
            ),
          );
        },
      )),
    );
  }
}
