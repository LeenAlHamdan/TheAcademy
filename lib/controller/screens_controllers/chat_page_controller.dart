import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/model/message.dart';

import '../../main.dart';
import '../../model/course.dart';
import '../../model/themes.dart';
import '../../services/socket_service.dart';
import '../../services/user_controller.dart';
import '../../utils/app_contanants.dart';
import '../../utils/compress_file.dart';
import '../../utils/crop_image.dart';
import '../../utils/download_file_per_link.dart';
import '../../utils/handle_pending_messages.dart';
import '../../utils/send_attachment.dart';
import '../../view/widgets/dialogs/confirm_delete_message_dialog.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/chat_controller.dart';
import 'package:chatview/chatview.dart' as chatview;

class ChatPageController extends GetxController {
  final UserController _userController = Get.find();
  final SocketService _socketService = injector.get<SocketService>();
  final ChatController _chatController = Get.find();
  final SharedPreferences _sharedPrefs = Get.find();

  final chatview.ChatController _chatViewController;
  List<chatview.Message> _messages = [];
  List<String> isLoadingFile = [];

  TextEditingController get messageController =>
      _chatViewController.textEditingController;
  ChatPageController(this._chatViewController);

  //bool _canLoadChat = true;
  //bool loadMoreChat = false;
  int _pageNumChat = 0;

  //final messageController = TextEditingController();
  get currentChatUser => chatview.ChatUser(
      id: _userController.userId,
      name: _userController.currentUser.name,
      profilePhoto: _userController.currentUser.profileImageUrl != ''
          ? '${AppConstants.imagesHost}/${_userController.currentUser.profileImageUrl}'
          : null);
  SocketService get socketService => _socketService;
  SharedPreferences get sharedPrefs => _sharedPrefs;

  bool canDeleteMessage(CourseFullData? course, String senderId) {
    if (senderId == _userController.userId) return true;

    if (course != null &&
        ((course.coachId == _userController.userId) ||
            _userController.isAdmin)) {
      return true;
    }

    return false;
  }

  deleteMessage(chatview.Message message) async {
    final result = await confirmDeleteMessageDialog();
    if (result == null || !result) return;

    if (!message.sended) {
      handelPendnigMessages(message.id, _sharedPrefs);
    } else {
      _socketService.deleteMessages(message.id);
    }

    var pos = _chatViewController.initialMessageList.indexWhere(
      (element) => element.id == message.id,
    );
    // ignore: unnecessary_null_comparison
    if (pos != null) {
      _chatViewController.initialMessageList.removeAt(pos);
      update();
    }
  }

  loadFile(String url, String id) async {
    isLoadingFile.add(id);
    update();
    try {
      String? path = await downLoadFilePerLink(url);
      final item = _chatViewController.initialMessageList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (item != null) {
        item.path = path;
      }
      isLoadingFile.remove(id);
      update();
    } catch (_) {
      isLoadingFile.remove(id);
      update();
    }
  }

  Future<String?> _pickImages(String? conversationId) async {
    try {
      final images = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: 'choose_image'.tr,
          actionBarColor: '#2184C7',
          statusBarColor: '#2184C7',
          useDetailsView: false,
        ),
      );
      if (images.isEmpty) {
        return null;
      }
      final byteData = await images.first.getByteData();

      final tempFile =
          File("${(await getTemporaryDirectory()).path}/${images.first.name}");
      final pickedImage = await tempFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      return pickedImage.path;

      /*  handleSendMessage(
        conversationId: conversationId,
        courseId: null,
        type: MyMessageType.image,
        message: pickedImage.path,
//todo replyTo:
      ); */
    } on HttpException catch (_) {
      // isLoading--;
      update();
    } catch (error) {
      //   isLoading--;
      update();
    }
    //   isLoading--;
    update();
    return null;

    //todo send  widget.onSelectMultiImage(images);
  }

  Future<String?> addFile(
    String? conversationId,
  ) async {
    //isLoading++;
    update();
    try {
      return await sendFile((fileUrl) {}, _chatController, () {},
          withSend: false);
      //refreshData();
    } on HttpException catch (_) {
      //isLoading--;
      update();
    } catch (error) {
      //   isLoading--;
      update();
    }
    //isLoading--;
    update();
    return null;
  }

  Future<Map<String, dynamic>?> attchFilePicker(String? conversationId) async {
    return await Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Themes.textColor,
              ),
              title: Text('image'.tr),
              onTap: () async {
                final path = await _pickImages(conversationId);
                Get.back(result: {
                  'path': path,
                  'type': 'image',
                });
              }),
          ListTile(
            leading: Icon(
              Icons.file_present_rounded,
              color: Themes.textColor,
            ),
            title: Text('file'.tr),
            onTap: () async {
              final path = await addFile(conversationId);
              Get.back(result: {
                'path': path,
                'type': 'file',
              });
            },
          ),
        ],
      ),
      backgroundColor: Themes.primaryColorLight,
    );
    /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      
    }); */
  }

  Future<void> handleSendMessage({
    required String? conversationId,
    required String? courseId,
    required MyMessageType type,
    required String message,
    chatview.ReplyMessage? replyTo,
  }) async {
    if (type == MyMessageType.text) {
      _submitMessage(
          conversationId: conversationId,
          courseId: courseId,
          type: type,
          replyTo: replyTo,
          message: message);
    } else if (type == MyMessageType.file) {
      final tempId = _socketService.sendTempMessage(message,
          replyTo: replyTo,
          courseId: courseId,
          conversationId: conversationId,
          type: type.name);
      final fileUrl = await _postFile(File(message));
      if (fileUrl != null)
        _submitMessage(
          conversationId: conversationId,
          courseId: courseId,
          type: type,
          message: fileUrl,
          tempId: tempId,
          replyTo: replyTo,
          path: message,
        );
    } else if (type == MyMessageType.image) {
      final image = await _cropImage(File(message));
      if (image == null) return;
      File? img = await compressFile(image);

      final tempId = _socketService.sendTempMessage(img.path,
          replyTo: replyTo,
          courseId: courseId,
          conversationId: conversationId,
          type: type.name);
      final imageUrl = await _postFile(img);
      if (imageUrl != null)
        _submitMessage(
          conversationId: conversationId,
          courseId: courseId,
          type: type,
          message: imageUrl,
          tempId: tempId,
          replyTo: replyTo,
        );
    } else if (type == MyMessageType.voice) {
      final tempId = _socketService.sendTempMessage(message,
          replyTo: replyTo,
          courseId: courseId,
          conversationId: conversationId,
          type: type.name);
      final imageUrl = await _postFile(File(message));
      if (imageUrl != null)
        _submitMessage(
          conversationId: conversationId,
          courseId: courseId,
          type: type,
          message: imageUrl,
          tempId: tempId,
          replyTo: replyTo,
        );
    }
  }

  void _submitMessage({
    required String? conversationId,
    required String? courseId,
    required MyMessageType type,
    required String message,
    String? tempId,
    String? path,
    chatview.ReplyMessage? replyTo,
    List<Map<String, dynamic>>? content,
  }) {
    if (message != '' || content != null) {
      _socketService.sendMessage(
        message,
        content: content,
        courseId: courseId,
        conversationId: conversationId,
        type: type.name,
        tempId: tempId,
        path: path,
        replyTo: replyTo,
      );
      //  socketService.isTyping(false);
    }
    //messageController.clear();
    update();
    //   FocusManager.instance.primaryFocus?.unfocus();
  }

  List<chatview.Message> _chatMessages({
    required String? conversationId,
    required String? courseId,
  }) {
    try {
      Iterable<chatview.Message>? list;
      if (conversationId != null) {
        return _chatController.chatMessages;
        /*  list = chatController.chatMessages
            .where((element) => element.consultancyId == conversationId);
        */
      } else if (courseId != null) {
        list = _chatController.coureChatMessages.where(
          (element) => element.courseId == courseId,
        );
      }

      return list != null ? list.toList() : [];
    } catch (_) {
      return [];
    }
  }

  chatview.Message? handleReciveMessages(
    AsyncSnapshot<Object?> chatSnapshot, {
    required String? conversationId,
    required String? courseId,
  }) {
    if (chatSnapshot.hasData) {
      final chatDocs = chatSnapshot.data;

      _messages =
          _chatMessages(conversationId: conversationId, courseId: courseId);
      if (chatDocs != null) {
        if (chatDocs is Map) {
          final data = chatDocs as Map<String, dynamic>;
          final message = data['message'] ?? data;
          if (message['type'] == MyMessageType.file.name && courseId != null)
            return null;
          if ((message['type'] != MyMessageType.text.name &&
                  message['type'] != MyMessageType.image.name &&
                  message['type'] != MyMessageType.voice.name) &&
              (message['type'] == MyMessageType.file.name &&
                  conversationId == null)) {
            //print('none of them $courseId ${message['type']}');
            return null;
          }

          if ((conversationId != null &&
                  message['conversation']?['_id'] != conversationId) ||
              (courseId != null && message['course']?['_id'] != courseId)) {
            //print('not matching');
          } else {
            //print(' matching');

            if (message['contents']?.first['config']?['tempId'] != null) {
              //print(' config != null ');

              final m = _messages.firstWhereOrNull(
                (element) =>
                    element.id ==
                    message['contents']?.first['config']?['tempId'],
              );
              final mes =
                  _chatViewController.initialMessageList.firstWhereOrNull(
                (element) =>
                    element.id ==
                    message['contents']?.first['config']?['tempId'],
              );
              if (mes != null) {
                mes.id = message['_id'];
                mes.sended = true;
                if (MessageTypes(mes).isImage ||
                    MessageTypes(mes).isVoice ||
                    MessageTypes(mes).isFile)
                  mes.content = message['contents'].first['data'];
                _updateMessages(
                    mes, message['contents']?.first['config']?['tempId']);
              }
              if (m != null) {
                //print(' m != null ');

                m.id = message['_id'];
                m.sended = true;
                if (MessageTypes(m).isImage ||
                    MessageTypes(m).isVoice ||
                    MessageTypes(m).isFile)
                  m.content = message['contents'].first['data'];
                if (message['course']?['_id'] != null &&
                    message['course']?['_id'] == courseId)
                  _chatController.updateOnCoureChatMessages(
                      m, message['contents']?.first['config']?['tempId']);
                else {
                  _chatController.updateChatMessages(
                      m, message['contents']?.first['config']?['tempId']);
                }
              } else {
                chatview.Message? loadedItem;
                loadedItem = _addNewMessage(message, courseId);
                if (loadedItem != null) {
                  _messages.insert(0, loadedItem);
                  return loadedItem;
                }
              }
            } else {
              chatview.Message? loadedItem;
              loadedItem = _addNewMessage(message, courseId);
              if (loadedItem != null) {
                _messages.insert(0, loadedItem);
                return loadedItem;
              }
            }
          }
        } else if (chatDocs is List<chatview.Message>) {
          _messages = chatDocs;
          _chatViewController.initialMessageList = _messages;
        }
      }
    }
    return null;
  }

  chatview.Message? _addNewMessage(
      Map<String, dynamic> message, String? courseId) {
    if (_messages.firstWhereOrNull((element) => element.id == message['_id']) ==
        null) {
      var message2 = chatview.Message(
        id: message['_id'],
        sended: message['sended'] ?? true,
        type: message['type'],
        consultancyId: message['consultancyId'],
        courseId: message['course']?['_id'],
        seenAt: message['seenAt'],
        senderId: message['sender']['_id'],
        senderName: message['sender']['name'],
        senderUserProfileImageUrl: message['sender']['profileImage'],
        senderIsOnline: message['sender']['isOnline'],
        content: message['contents'].first['data'],
        createdAt: message['createdAt'],
        replyMessage: message['replyTo'] != null
            ? chatview.ReplyMessage(
                messageId: message['replyTo']['_id'],
                content: message['replyTo']['contents'].first['data'],
                replyBy: message['sender']['_id'],
                replyTo: message['replyTo']?['sender']?['_id'],
                messageType: message['replyTo']?['type'],
              )
            : const chatview.ReplyMessage(),
      );
      if (message['course']?['_id'] != null &&
          message['course']?['_id'] == courseId)
        _chatController.addToCoureChatMessages(message2);
      return message2;
    }
    return null;
  }

  Future<File?> _cropImage(File storedImage) async {
    var croppedFile = await cropingImage(storedImage,
        primaryColor: Themes.primaryColor,
        backgroundColor: Themes.primaryColorLight);
    return croppedFile != null && croppedFile.path.isNotEmpty
        ? croppedFile
        : null;
  }

  Future<String?> _postFile(File pickedImage) async {
    try {
      return await _chatController.uplaodFile(pickedImage);
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      showErrorDialog(
        errorMessage,
      );
    }
    return null;
  }

  Future<void> chatMessagesPagination({
    required String? conversationId,
    required CourseFullData? course,
  }) async {
    await _getChatMessages(conversationId: conversationId, course: course);

    /* if (_canLoadChat) {
      loadMoreChat = true;
      update();

      _canLoadChat = false;
      await getChatMessages(conversationId: conversationId, course: course);
    } */
  }

  bool isLastPage({
    required bool isCourse,
  }) {
    return (isCourse &&
            _chatController.coureChatMessages.length >=
                _chatController.coureChatMessagesTotal) ||
        (!isCourse &&
            _chatController.chatMessages.length >=
                _chatController.chatMessagesTotal);
  }

  Future<void> _getChatMessages({
    required String? conversationId,
    required CourseFullData? course,
  }) async {
    /* if ((course != null &&
            _chatController.coureChatMessages.length ==
                _chatController.coureChatMessagesTotal) ||
        (conversationId != null &&
            _chatController.chatMessages.length ==
                _chatController.chatMessagesTotal)) {
      _canLoadChat = true;
      loadMoreChat = false;
      update();

      return;
    } */
    try {
      course != null
          ? await _chatController.getCoureChatMessages(
              ++_pageNumChat,
              course: course,
            )
          : await _chatController.getChatMessages(
              ++_pageNumChat, _userController.userId,
              conversationId: conversationId);
      //_canLoadChat = true;
    } on HttpException catch (error) {
      _pageNumChat--;
//      _canLoadChat = true;

      showErrorDialog('error'.tr);
      //    loadMoreChat = false;
      //  update();
      throw error;
    } catch (error) {
      _pageNumChat--;
      //   _canLoadChat = true;

      showErrorDialog('error'.tr);
      // loadMoreChat = false;
      //update();
      throw error;
    }
    //loadMoreChat = false;
    //update();
  }

  void _updateMessages(chatview.Message message, String id) {
    try {
      var pos = _chatViewController.initialMessageList.indexWhere(
        (element) => element.id == id,
      );
      // ignore: unnecessary_null_comparison
      if (pos != null) {
        _chatViewController.initialMessageList.removeAt(pos);
        _chatViewController.initialMessageList.insert(pos, message);
      }
      update();
    } catch (_) {}
  }
}
