import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/screens/show_full_image_screen.dart';
//import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controller/screens_controllers/chat_page_controller.dart';
import '../../../model/course.dart';
import '../../../model/message.dart';
import '../../../utils/get_file_name.dart';
import '../../widgets/custom_widgets/empty_widget.dart';
import '../../widgets/custom_widgets/load_more_widget.dart';
import '../../widgets/custom_widgets/loading_widget.dart';
import '../../widgets/custom_widgets/user_image.dart';
//import '../../widgets/chat_widgets/record_button .dart';

class ChatPage extends StatelessWidget {
  final CourseFullData? course;
  final String? conversationId;
  final ChatController chatController;

  ChatPage({
    this.conversationId,
    this.course,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatPageController>(
      init: ChatPageController(chatController),
      builder: (screenController) => StreamBuilder(
        stream: screenController.socketService.getResponse.asBroadcastStream(),
        builder: (ctx, chatSnapshot) {
          var mes = screenController.handleReciveMessages(chatSnapshot,
              conversationId: conversationId, courseId: course?.id);
          if (mes != null &&
              chatController.initialMessageList.firstWhereOrNull(
                    (element) => element.id == mes.id,
                  ) ==
                  null) chatController.addMessage(mes);
          return ChatView(
            currentUser: screenController.currentChatUser,
            hasCorners: course == null,
            incomingbackgroundColor: Get.isDarkMode
                ? Get.theme.colorScheme.background
                : Themes.primaryColorLight,
            incomingTextColor:
                Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            imageWidget: (imageUrl) => Padding(
              padding: EdgeInsets.only(left: 6.0, right: 4, bottom: 2),
              child: UserImage(imageUrl ?? '' // profileImage,
                  ),
            ),
            onLongPress: (message) {
              if (screenController.canDeleteMessage(course, message.senderId)) {
                screenController.deleteMessage(message);
              }
            },
            hasAttach: conversationId != null,
            onAttach: conversationId != null
                ? () async {
                    final result =
                        await screenController.attchFilePicker(conversationId);
                    //print('result $result');
                    return result;
                  }
                : null,
            chatController: chatController,
            packageStrings: PackageStrings(
              replyToText: 'reply_to'.tr,
              todayText: 'today'.tr,
              yesterdayText: 'yesterday'.tr,
              repliedByText: 'replied_by'.tr,
              moreText: 'more'.tr,
              unsendText: 'unsend'.tr,
              replyText: 'reply'.tr,
              messageText: 'message'.tr,
              photoText: 'photo'.tr,
              sendText: 'send'.tr,
              youText: 'you'.tr,
              repliedToYouText: 'replied_to_you'.tr,
              reactionPopupTitleText: 'reaction_popup_title'.tr,
            ),
            ltr: Get.locale != const Locale('ar'),
            isLastPage: screenController.isLastPage(isCourse: course != null),
            loadMoreData: () async {
              if (screenController.isLastPage(isCourse: course != null)) {
                return null;
              }

              return screenController.chatMessagesPagination(
                  conversationId: conversationId, course: course);
            },
            sendMessageConfig: SendMessageConfiguration(
                allowRecordingVoice: true,
                imagePickerIconsConfig: ImagePickerIconsConfiguration(
                    cameraIconColor: Get.isDarkMode ? Themes.textColor : null,
                    galleryIconColor: Get.isDarkMode ? Themes.textColor : null),
                voiceRecordingConfiguration: VoiceRecordingConfiguration(
                    recorderIconColor:
                        Get.isDarkMode ? Themes.textColor : null),
                defaultSendButtonColor: Themes.primaryColor,
                textFieldConfig: TextFieldConfiguration(
                    textStyle: Get.textTheme.titleMedium)),
            onSendTap: (message, reply, type) {
              screenController.handleSendMessage(
                message: message,
                conversationId: conversationId,
                courseId: course?.id,
                type: messageType(type.name),
                replyTo: reply.messageId.isNotEmpty ? reply : null,
              );
            },
            chatViewState: ChatViewState.hasMessages,
            emptyWidget: EmptyWidget(
              title: 'no_messages_yet_start_chatting'.tr,
            ),
            chatBackgroundConfig: ChatBackgroundConfiguration(
                backgroundColor:
                    Get.isDarkMode ? Themes.primaryColorLightDark : null,
                loadingWidget: LoadingWidget(chat: true),
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
                messageTimeTextStyle: TextStyle(color: Themes.offerColor)),
            featureActiveConfig: FeatureActiveConfig(
              enableSwipeToReply: true,
              enablePagination: true,
              enableOtherUserProfileAvatar: true,
              enableCurrentUserProfileAvatar: course != null,
            ),
            noRecentText: 'no_recents'.tr,
            loadingWidget: LoadMoreWidget(isDefault: true),
            messageConfig: MessageConfiguration(
              customMessageBuilder: (message) {
                return ListTile(
                  leading: screenController.isLoadingFile
                              .contains(message.id) ||
                          !message.sended
                      ? CircularProgressIndicator(
                          color: message.senderId ==
                                      screenController.currentChatUser.id ||
                                  Get.isDarkMode
                              ? Themes.primaryColorLight
                              : Themes.textColor)
                      : message.path == null
                          ? Icon(
                              Icons.download,
                              color: message.senderId ==
                                          screenController.currentChatUser.id ||
                                      Get.isDarkMode
                                  ? Themes.primaryColorLight
                                  : Themes.textColor,
                            )
                          : Icon(
                              Icons.file_open_outlined,
                              color: message.senderId ==
                                          screenController.currentChatUser.id ||
                                      Get.isDarkMode
                                  ? Themes.primaryColorLight
                                  : Themes.textColor,
                            ),
                  title: Text(
                    message.content
                        .substring(message.content.lastIndexOf('/') + 1),
                    style: TextStyle(
                        color: message.senderId ==
                                    screenController.currentChatUser.id ||
                                Get.isDarkMode
                            ? Themes.primaryColorLight
                            : Themes.textColor),
                  ),
                  onTap: screenController.isLoadingFile.contains(message.id)
                      ? null
                      : message.path == null
                          ? () => screenController.loadFile(
                              message.content, message.id)
                          : () => openFile(message.path!),
                );
              },
              imageMessageConfig: ImageMessageConfiguration(
                onTap: (imageUrl, senderName) => Get.to(ShowFullImageScreen(
                  imageUrl,
                  title: '${'image_form'.tr} $senderName',
                  haveAppBar: true,
                )),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              outgoingChatBubbleConfig: ChatBubble(
                color: Themes.primaryColor,
              ),
            ),
          );
        },
      )
      /* Column(
        children: [
          Expanded(
            child: Messages(
              socketService: screenController.socketService,
              //stream: widget.streamController.stream,
              conversationId: conversationId,
              courseId: courseId,
            ),
          ),
          /* StreamMessageInput(
            actions: [
              RecordButton(
                recordingFinishedCallback:
                    screenController.recordingFinishedCallback,
              ),
            ],
          ), */
          NewMessage(
            //  widget.channel,
            //streamController: widget.streamController,
            screenController: screenController,
            conversationId: conversationId,
            courseId: courseId,
          ),
        ],
      ) */
      ,
    );
  }
}
