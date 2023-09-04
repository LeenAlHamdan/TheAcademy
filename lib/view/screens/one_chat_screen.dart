import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/chat_screen_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';

import '../../model/themes.dart';
import '../widgets/custom_widgets/loading_widget.dart';
import 'one_course_pages/chat_page.dart';

class OneChatScreen extends StatelessWidget {
  OneChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatScreenController>(
      builder: (screenController) {
        return Scaffold(
          appBar: screenController.isLoading
              ? null
              : MyAppBar(
                  leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_outlined,
                      )),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(screenController.title!,
                            textAlign: TextAlign.center,
                            style: Get.textTheme.titleLarge?.copyWith(
                                color: Get.isDarkMode
                                    ? Themes.textColorDark
                                    : Themes.textColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      (!screenController.isLoading) && screenController.isOnline
                          ? Row(
                              children: [
                                Icon(Icons.circle,
                                    size: Get.width * 0.017,
                                    color: Themes.greenColor),
                                SizedBox(width: Get.width * 0.0175),
                                Text(
                                  'active_now'.tr,
                                  style: TextStyle(
                                      fontSize: 12.2,
                                      color: Themes.primaryColorDarkLighted),
                                ),
                              ],
                            )
                          : SizedBox()
                    ],
                  ),
                  isUserImage: false,
                  image: screenController.image,
                ),
          body: WillPopScope(
            onWillPop: () async {
              currentConversation = null;

              return true;
            },
            child: screenController.isLoading
                ? LoadingWidget(chat: true)
                : ChatPage(
                    conversationId: screenController.conversationId,
                    chatController: ChatController(
                      initialMessageList: screenController.chatMessages,
                      //scrollController: ScrollController(),
                      chatUsers: [screenController.chatUser],
                    )),
          ),
        );
      },
    );
  }
}
