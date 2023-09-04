import 'dart:convert';
import 'dart:io';

import 'package:chatview/chatview.dart' as chatview;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:the_academy/controller/models_controller/chat_controller.dart';
import 'package:the_academy/model/message.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import '../utils/app_contanants.dart';
import '../utils/handle_pending_messages.dart';
import 'user_controller.dart';

class SocketService {
  final _socketResponse = StreamController.broadcast();
  final _typingController = StreamController<dynamic>();
  final _userController = StreamController<dynamic>();

  final _scrollController = ScrollController();
  List<dynamic> _allMessage = [];
  late IO.Socket socket;
  final UserController userController = Get.find();
  static var isInited = false;
  SharedPreferences sharedPrefs = Get.find();
  //StreamController streamController = StreamController.broadcast();

  createSocketConnection() {
    String token = userController.token;
    socket = IO.io(
        '${AppConstants.host}/with-token',
        IO.OptionBuilder().setTransports([
          'websocket',
        ]) // for Flutter or Dart VM
            .setAuth({'token': 'Bearer $token'})

            //  .setAuth({'auth': registrationToken})
            .build());
    this.socket.connect();

    this.socket.onConnect((_) {
      subscribe();
      sendPendingMessages();
      isInited = true;
    });

    this.socket.on('connect_error', (message) {
      debugPrint('connect_error ${message.runtimeType}');
      //MessagesModel.messages.add(message);
    });

    socket.onError(
      (data) => debugPrint('data $data'),
    );
    socket.onConnectError(
      (data) {
        socket.auth = {'token': 'Bearer $token'};

        socket.connect();
      },
    );
    socket.onerror(
      (data) => debugPrint('onerror $data'),
    );

    this.socket.onDisconnect((_) => debugPrint('disconnect'));
  }

  subscribe() {
    /*  streamController.addStream(
      getResponse.asBroadcastStream(),
    ); */

    this.socket.on('message', (msg) {
      debugPrint('subscribe message $msg');
    });

    socket.on('courseMessage', (msg) {
      debugPrint('subscribe courseMessage $msg');
      var message = (msg is String) ? jsonDecode(msg) : msg;

      //final message = m['message'];

      if (message['message']?['contents']?.first['config']?['tempId'] != null) {
        handelPendnigMessages(
            message['message']['contents']?.first['config']?['tempId'],
            sharedPrefs);
      }
      _socketResponse.sink.add(message);
    });

    socket.on('userMessage', (msg) {
      var message = (msg is String) ? jsonDecode(msg) : msg;

      _socketResponse.sink.add(message);

      if (message['message']['contents']?.first['config']?['tempId'] != null) {
        handelPendnigMessages(
            message['message']['contents']?.first['config']?['tempId'],
            sharedPrefs);
      }
    });
  }

  sendPendingMessages() async {
    //sharedPrefs.remove("pendingMessages");
    var string = sharedPrefs.getString("pendingMessages");
    List<dynamic> pendingMessages = [];
    if (string != null) {
      debugPrint("pendingMessages $string");
      pendingMessages = jsonDecode(string) as List<dynamic>;
    }
    if (pendingMessages.isEmpty) return;

    for (var pMessage in pendingMessages) {
      //_socketResponse.sink.add(pMessage);
      var message = pMessage['message']['contents'].first['data'];
      if (pMessage['message']['type'] == MyMessageType.image.name ||
          pMessage['message']['type'] == MyMessageType.voice.name) {
        try {
          final ChatController _chatController = Get.find();
          message = await _chatController
              .uplaodFile(File(pMessage['message']['contents'].first['data']));
        } catch (error) {
          debugPrint(error.toString());
        }
      }

      final courseId = pMessage['message']['course']?['_id'];
      final conversationId = pMessage['message']['conversation']?['_id'];
      final replyTo = pMessage['message']['replyToId'];
      var messagePost = {
        if (replyTo != null) 'replyToId': replyTo,
        if (courseId != null) 'courseId': courseId,
        if (conversationId != null) 'conversationId': conversationId,
        "type": pMessage['message']['type'],
        "contents": [
          {
            "data": message,
            "config": {"tempId": pMessage['message']['_id']},
          }
        ]
      };
      debugPrint(messagePost.toString());
      this.socket.emit(
          courseId != null ? 'courseMessage' : 'userMessage', messagePost);
    }
  }

  deleteMessages(String messageId) async {
    var messagePost = {
      'messageId': messageId,
    };
    this.socket.emit('deleteMessage', messagePost);
  }

  sendMessage(
    msg, {
    String? courseId,
    String? conversationId,
    required String type,
    List<Map<String, dynamic>>? content,
    String? tempId,
    String? path,
    chatview.ReplyMessage? replyTo,
  }) {
    if (msg == '' && content == null) return;

    var uuid = tempId ??
        sendTempMessage(
          msg,
          content: content,
          courseId: courseId,
          conversationId: conversationId,
          type: type,
          replyTo: replyTo,
        );

    var messagePost = {
      if (replyTo != null) 'replyToId': replyTo.messageId,
      if (courseId != null) 'courseId': courseId,
      if (conversationId != null) 'conversationId': conversationId,
      "type": type,
      "contents": content ??
          [
            {
              "data": msg,
              "config": {
                "tempId": uuid,
                if (path != null) 'path': path,
              },
            }
          ]
    };
    // print(messagePost);
    this
        .socket
        .emit(courseId != null ? 'courseMessage' : 'userMessage', messagePost);
    //json.encode(messagePost));
  }

  String sendTempMessage(
    msg, {
    String? courseId,
    String? conversationId,
    required String type,
    List<Map<String, dynamic>>? content,
    chatview.ReplyMessage? replyTo,
  }) {
    var uuid = Uuid().v1();

    var message = {
      "message": {
        "_id": uuid,
        "sended": false,
        "sender": {
          "_id": userController.userId,
          "name": userController.currentUser.name,
          "isOnline": true,
          "profileImage": userController.currentUser.profileImageUrl
        },
        "type": type,
        if (replyTo != null)
          "replyTo": {
            "_id": replyTo.messageId,
            "sender": {
              '_id': replyTo.replyTo,
            },
            "type": replyTo.messageType,
            "contents": [
              {
                "data": replyTo.content,
              }
            ],
          },
        if (courseId != null) "course": {"_id": courseId},
        if (conversationId != null) "conversation": {"_id": conversationId},
        "contents": content ??
            [
              {
                "data": msg,
              }
            ],
        "createdAt": DateTime.now().toIso8601String(),
      }
    };
    var string = sharedPrefs.getString("pendingMessages");
    List<dynamic> pendingMessages = [];
    if (string != null) {
      pendingMessages = jsonDecode(string) as List<dynamic>;
    }
    pendingMessages.add(message);

    sharedPrefs.setString("pendingMessages", jsonEncode(pendingMessages));

    _socketResponse.sink.add(message);
    return uuid;
  }

  /* isTyping(isTyping) {
    this.socket.emit('$_room-typing', {
      'id': myId,
      'isTyping': isTyping,
      'name': 'lambiengcode',
    });
  } */

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream get getResponse {
    return _socketResponse.stream;

    /* .where(
      (event) =>
          courseId != null ? event == "courseMessage" : event == "userMessage",
    ); */
  }

  Stream<dynamic> get getTyping => _typingController.stream;

  ScrollController get getScrollController => _scrollController;

  void setUserInfo(dynamic info) {
    _userController.add(info);
    _allMessage.clear();
    /* _socketResponse
      ..addStream(
        socket.,
      ); */
    // _socketResponse.add(_allMessage);
    subscribe();
  }

  Stream<dynamic> get getUserInfo => _userController.stream;

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 100),
      );
    }
  }

  void dispose() {
    _socketResponse.close();
    _typingController.close();
    _userController.close();
    socket.close();
  }

  void closeSocket() {
    socket.close();
  }
}
