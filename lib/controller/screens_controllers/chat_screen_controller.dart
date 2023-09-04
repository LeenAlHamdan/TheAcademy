import 'package:chatview/chatview.dart' as chatview;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../../model/http_exception.dart';
import '../../services/user_controller.dart';
import '../../utils/app_contanants.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/chat_controller.dart';

class ChatScreenController extends GetxController {
  late String? title;
  bool isOnline = false;
  late String? image;
  RxString userId = ''.obs;
  String? conversationId;

  var isLoading = false;

  ChatController _chatController = Get.find();
  final UserController _userController = Get.find();

  @override
  void onInit() {
    /* if (Get.arguments != null) {
      conversationId = Get.arguments['conversationId'];
      userId.value = Get.arguments['userId'];
      title = Get.arguments['title'];
      image = Get.arguments['image'];
    } */

    super.onInit();
    ever(userId, (_) {
      if (userId.isNotEmpty) {
        getData();
      }
    });
  }

  Future<void> getData() async {
    isLoading = true;
    update();
    try {
      if (conversationId == null) {
        final conversation = await _chatController.createOrGetOneConversation(
          userId.value,
        );

        conversationId = conversation['_id'];
        isOnline = conversation['firstUser']['_id'] == userId.value
            ? conversation['firstUser']['isOnline']
            : conversation['secondUser']['isOnline'];
        update();
      } else {
        final conversation = await _chatController.getOneConversation(
          userId.value,
        );

        userId.value = userId.isNotEmpty
            ? userId.value
            : (conversation['firstUser']['_id'] == _userController.userId
                ? conversation['firstUser']['_id']
                : conversation['secondUser']['_id']);
        title = title ??
            (conversation['firstUser']['_id'] == _userController.userId
                ? conversation['firstUser']['name']
                : conversation['secondUser']['name']);
        image = image ??
            (conversation['firstUser']['_id'] == _userController.userId
                ? conversation['firstUser']['profileImage']
                : conversation['secondUser']['profileImage']);
        conversationId = conversation['_id'];
        isOnline = conversation['firstUser']['_id'] == userId.value
            ? conversation['firstUser']['isOnline']
            : conversation['secondUser']['isOnline'];
        update();
      }
      currentConversation = conversationId;

      await _chatController.getChatMessages(0, _userController.userId,
          conversationId: conversationId, isRefresh: true);

      isLoading = false;
      update();
    } on HttpException catch (error) {
      debugPrint('error is $error ');

      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      debugPrint('$error');
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  List<chatview.Message> get chatMessages => _chatController.chatMessages;
  get chatUser => chatview.ChatUser(
      id: userId.value,
      name: title!,
      profilePhoto: image != '' ? '${AppConstants.imagesHost}/$image' : null);

  // Method to update productId when a new product is selected
  updateUserId(String newUserId, String title, String image,
      {String? conversationId}) {
    if (userId.value == newUserId) {
      getData();
    }
    userId.value = newUserId;
    this.title = title;
    this.image = image;
    this.conversationId = conversationId;
    update();
  }

  @override
  void onClose() {
    // Reset or cleanup logic
    userId = ''.obs;
    currentConversation = null;

    super.onClose();
  }
}
