import 'dart:convert';
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/model/chat.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/message.dart';

import '../../data/api/api_client.dart';
import '../../model/http_exception.dart';
import '../../model/user.dart';
import '../../utils/app_contanants.dart';
import '../../utils/get_directory.dart';
import '../../utils/get_file_name.dart';

class ChatController extends GetxController {
  final ApiClient apiClient = Get.find();
  final SharedPreferences sharedPrefs = Get.find();

  List<Chat> _userPrivateChats = [];

  List<int> userPrivateChatsPages = [];
  int _userPrivateChatsTotal = 0;

  List<Message> _chatMessages = [];
  List<int> chatMessagesPages = [];
  int _chatMessagesTotal = 0;

  List<Message> _coureChatMessages = [];
  List<int> coureChatMessagesPages = [];
  int _coureChatMessagesTotal = 0;

  final int _limit = 12;

  List<Message> _feedMessages = [];

  List<int> feedPages = [];
  int _feedTotal = 0;

  List<Message> get feedMessages => _feedMessages;
  int get feedTotal => _feedTotal;
  List<Message> get chatMessages => _chatMessages;
  int get chatMessagesTotal => _chatMessagesTotal;

  List<Message> get coureChatMessages => _coureChatMessages;
  int get coureChatMessagesTotal => _coureChatMessagesTotal;

  List<Chat> get userPrivateChats => _userPrivateChats;
  int get userPrivateChatsTotal => _userPrivateChatsTotal;

  void addToCoureChatMessages(Message message) {
    _coureChatMessages.insert(0, message);
    _coureChatMessagesTotal++;
  }

  void updateOnCoureChatMessages(Message message, String id) {
    try {
      var pos = _coureChatMessages.indexWhere(
        (element) => element.id == id,
      );
      // ignore: unnecessary_null_comparison
      if (pos != null) {
        _coureChatMessages.removeAt(pos);
        _coureChatMessages.insert(pos, message);
      }
    } catch (_) {}
  }

  void updateChatMessages(Message message, String id) {
    try {
      var pos = _chatMessages.indexWhere(
        (element) => element.id == id,
      );
      // ignore: unnecessary_null_comparison
      if (pos != null) {
        _chatMessages.removeAt(pos);
        _chatMessages.insert(pos, message);
      }
    } catch (_) {}
  }

  Future<void> getChatMessages(int pageNum, String userId,
      {String? conversationId, bool isRefresh = false}) async {
    if (isRefresh) {
      chatMessagesPages = [];
      _chatMessages = [];
    }

    if (chatMessagesPages.contains(pageNum)) {
      return;
    }
    chatMessagesPages.add(pageNum);

    final offest = chatMessages.length;

    final conversation = conversationId != null
        ? '&${AppConstants.conversationId}=$conversationId'
        : '';
    try {
      var uri =
          '${AppConstants.messagesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$conversation';
      final response = await apiClient.getData(uri);

      final directory = await getDirectory();

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _chatMessagesTotal = extractedData['total'] ?? _chatMessagesTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Message> loadedMessages = [];

        for (var message in data) {
          if (message['_id'] != null &&
              message['sender'] != null &&
              message['type'] != null &&
              message['contents'] != null) {
            String? path;
            if (message['type'] ==
                    'file' /*&&
                    message['sender']['_id'] ==
                        userId  &&
                message['contents'].first['config']?['path'] != null */
                ) {
              //todo path = message['contents'].first['config']?['path'];

              var url = message['contents'].first['data'];
              path = directory == null
                  ? null
                  : await getFilePath(url: url, directory: directory);
            }
            loadedMessages.add(Message(
              id: message['_id'],
              consultancyId: message['conversation'],
              courseId: null,
              createdAt: message['createdAt'],
              seenAt: message['seenAt'],
              type: message['type'],
              senderId: message['sender']['_id'],
              senderName: message['sender']['name'],
              senderUserProfileImageUrl:
                  message['sender']['profileImage'] ?? '',
              senderIsOnline: false,
              content: message['contents'].first['data'],
              config: message['contents'].first['config'],
              path: path,
              replyMessage: message['replyTo'] != null
                  ? ReplyMessage(
                      messageId: message['replyTo']['_id'],
                      content: message['replyTo']['contents'].first['data'],
                      replyBy: message['sender']['_id'],
                      replyTo: message['replyTo']['sender']['_id'],
                      messageType: message['replyTo']['type'],
                    )
                  : const ReplyMessage(),
            ));
          }
        }
        if (isRefresh) {
          var string = sharedPrefs.getString("pendingMessages");
          List<dynamic> pendingMessages = [];
          if (string != null) {
            pendingMessages = jsonDecode(string) as List<dynamic>;
          }
          if (pendingMessages.isNotEmpty) {
            List<String> deletedPen = [];
            for (int i = 0; i < pendingMessages.length; i++) {
              var pendMessage = pendingMessages[i];
              if (loadedMessages.firstWhereOrNull(
                    (element) =>
                        element.config?['tempId'] ==
                        pendMessage['message']['_id'],
                  ) !=
                  null) {
                deletedPen.add(pendMessage['message']['_id']);
              } else if (pendMessage['message']['conversation']?['_id'] ==
                  conversationId) {
                final message = pendMessage['message'];
                loadedMessages.insert(
                    0,
                    Message(
                      id: message['_id'],
                      consultancyId: message['conversation']?['_id'],
                      courseId: message['course']?['_id'],
                      createdAt: message['createdAt'],
                      seenAt: message['seenAt'],
                      type: message['type'],
                      senderId: message['sender']['_id'],
                      senderName: message['sender']['name'],
                      senderUserProfileImageUrl:
                          message['sender']['profileImage'] ?? '',
                      senderIsOnline: true,
                      sended: false,
                      content: message['contents'].first['data'],
                      replyMessage: message['replyTo'] != null
                          ? ReplyMessage(
                              messageId: message['replyTo']['_id'],
                              content:
                                  message['replyTo']['contents'].first['data'],
                              replyBy: message['sender']['_id'],
                              replyTo: message['replyTo']['sender']['_id'],
                              messageType: message['replyTo']['type'],
                            )
                          : const ReplyMessage(),
                    ));
              }
            }

            for (var p in deletedPen)
              pendingMessages.removeWhere(
                (element) => element['message']['_id'] == p,
              );
            sharedPrefs.remove(
              "pendingMessages",
            );
            sharedPrefs.setString(
                "pendingMessages", jsonEncode(pendingMessages));
          }
        }

        if (loadedMessages.isNotEmpty) {
          _chatMessages.addAll(loadedMessages);
        } else {
          chatMessagesPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      debugPrint('error $error');

      chatMessagesPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> getCoureChatMessages(int pageNum,
      {CourseFullData? course, bool isRefresh = false}) async {
    if (isRefresh) {
      coureChatMessagesPages = [];
      _coureChatMessages = [];
    }

    if (coureChatMessagesPages.contains(pageNum)) {
      return;
    }
    coureChatMessagesPages.add(pageNum);

    final offest = coureChatMessages.length;
    final courseFilter =
        course != null ? '&${AppConstants.courseId}=${course.id}' : '';
    final chat = '&isChat=true';

    try {
      final response = await apiClient.getData(
          '${AppConstants.messagesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$courseFilter$chat');
      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _coureChatMessagesTotal =
            extractedData['total'] ?? _coureChatMessagesTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Message> loadedMessages = [];

        for (var message in data) {
          if (message['_id'] != null &&
              message['sender'] != null &&
              message['type'] != null &&
              message['contents'] != null) {
            loadedMessages.add(Message(
              id: message['_id'],
              consultancyId: message['conversation'],
              courseId: message['course']?['_id'],
              createdAt: message['createdAt'],
              seenAt: message['seenAt'],
              type: message['type'],
              senderId: message['sender']['_id'],
              senderName: message['sender']['name'],
              senderUserProfileImageUrl:
                  message['sender']['profileImage'] ?? '',
              senderIsOnline: course != null
                  ? course.users
                      .firstWhereOrNull(
                        (element) => element.id == message['sender']['_id'],
                      )
                      ?.isOnline
                  : false,
              content: message['contents'].first['data'],
              config: message['contents'].first['config'],
              replyMessage: message['replyTo'] != null
                  ? ReplyMessage(
                      messageId: message['replyTo']['_id'],
                      content: message['replyTo']['contents'].first['data'],
                      replyBy: message['sender']['_id'],
                      replyTo: message['replyTo']['sender']['_id'],
                      messageType: message['replyTo']['type'],
                    )
                  : const ReplyMessage(),
            ));
          }
        }

        if (isRefresh) {
          var string = sharedPrefs.getString("pendingMessages");
          List<dynamic> pendingMessages = [];

          if (string != null) {
            pendingMessages = jsonDecode(string) as List<dynamic>;
          }
          if (pendingMessages.isNotEmpty) {
            List<String> deletedPen = [];
            for (int i = 0; i < pendingMessages.length; i++) {
              var pendMessage = pendingMessages[i];
              if (loadedMessages.firstWhereOrNull(
                    (element) =>
                        element.config?['tempId'] ==
                        pendMessage['message']['_id'],
                  ) !=
                  null) {
                deletedPen.add(pendMessage['message']['_id']);
              } else if (pendMessage['message']['course']?['_id'] ==
                  course?.id) {
                final message = pendMessage['message'];
                loadedMessages.insert(
                    0,
                    Message(
                      id: message['_id'],
                      consultancyId: message['conversation']?['_id'],
                      courseId: message['course']?['_id'],
                      createdAt: message['createdAt'],
                      seenAt: message['seenAt'],
                      type: message['type'],
                      senderId: message['sender']['_id'],
                      senderName: message['sender']['name'],
                      senderUserProfileImageUrl:
                          message['sender']['profileImage'] ?? '',
                      senderIsOnline: true,
                      sended: false,
                      content: message['contents'].first['data'],
                      replyMessage: message['replyTo'] != null
                          ? ReplyMessage(
                              messageId: message['replyTo']['_id'],
                              content:
                                  message['replyTo']['contents'].first['data'],
                              replyBy: message['sender']['_id'],
                              replyTo: message['replyTo']['sender']['_id'],
                              messageType: message['replyTo']['type'],
                            )
                          : const ReplyMessage(),
                    ));
              }
            }

            for (var p in deletedPen)
              pendingMessages.removeWhere(
                (element) => element['message']['_id'] == p,
              );
            sharedPrefs.remove(
              "pendingMessages",
            );
            sharedPrefs.setString(
                "pendingMessages", jsonEncode(pendingMessages));
          }
        }

        if (loadedMessages.isNotEmpty) {
          _coureChatMessages.addAll(loadedMessages);
        } else {
          coureChatMessagesPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      debugPrint('error $error');
      coureChatMessagesPages.remove(pageNum);

      rethrow;
    }
  }

  Future<List<Message>> getFeedMessages(int pageNum,
      {String? conversationId,
      String? courseId,
      bool? isRefresh,
      required String userId}) async {
    if (isRefresh != null && isRefresh) {
      feedPages = [];
      _feedMessages = [];
    }

    if (feedPages.contains(pageNum)) {
      return [];
    }
    feedPages.add(pageNum);

    final offest = feedMessages.length;
    final course =
        courseId != null ? '&${AppConstants.courseId}=$courseId' : '';
    final conversation = conversationId != null
        ? '&${AppConstants.conversationId}=$conversationId'
        : '';
    final feed = '&isFeed=true';

    try {
      final response = await apiClient.getData(
          '${AppConstants.messagesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$course$conversation$feed');

      final directory = await getDirectory();

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _feedTotal = extractedData['total'] ?? _feedTotal;

        final data = extractedData['data'] as List<dynamic>;
        List<Message> loadedMessages = [];

        for (var message in data) {
          if (message['_id'] != null &&
              message['sender'] != null &&
              message['type'] != null &&
              message['contents'] != null) {
            if (message['type'] == MyMessageType.poll.name) {
              final contents = message['contents'] as List<dynamic>;
              String title = '';
              List<PollOptions> options = [];
              int totalVotes = 0;
              bool userHasVoted = false;

              for (var content in contents) {
                if (content['config']?['content-type'] != null &&
                    content['config']?['content-type'] == 'poll-text') {
                  title = content['data'];
                } else {
                  List<dynamic> chosenBy = content['chosenBy'];
                  totalVotes += chosenBy.length;
                  var isChosedByUser = (chosenBy.firstWhereOrNull(
                        (element) => element.toString() == userId,
                      ) !=
                      null);
                  if (isChosedByUser) userHasVoted = true;

                  options.add(PollOptions(
                      text: content['data'],
                      id: content['_id'],
                      chosenBy: chosenBy,
                      isChosedByUser: isChosedByUser));
                }
              }

              loadedMessages.add(Poll(
                id: message['_id'],
                consultancyId: message['conversation'],
                courseId: message['course']?['_id'],
                createdAt: message['createdAt'],
                seenAt: message['seenAt'],
                senderId: message['sender']['_id'],
                senderName: message['sender']['name'],
                senderUserProfileImageUrl:
                    message['sender']['profileImage'] ?? '',
                content: title,
                type: message['type'],
                poolOptions: options,
                totalVotes: totalVotes,
                userHasVoted: userHasVoted,
              ));
            } else if (message['type'] == MyMessageType.slides.name) {
              final contents = message['contents'] as List<dynamic>;
              String title = '';
              List<String> images = [];

              for (var content in contents) {
                if (content['config']?['content-type'] != null &&
                    content['config']?['content-type'] == 'title') {
                  title = content['data'];
                } else {
                  images.add(content['data']);
                }
              }

              loadedMessages.add(Slide(
                  id: message['_id'],
                  consultancyId: message['conversation'],
                  courseId: message['course']?['_id'],
                  createdAt: message['createdAt'],
                  seenAt: message['seenAt'],
                  senderId: message['sender']['_id'],
                  senderName: message['sender']['name'],
                  senderUserProfileImageUrl:
                      message['sender']['profileImage'] ?? '',
                  content: title,
                  type: message['type'],
                  images: images));
            } else if (message['type'] == MyMessageType.file.name) {
              var url = message['contents'].first['data'];
              String? path = directory == null
                  ? null
                  : await getFilePath(url: url, directory: directory);

              loadedMessages.add(MyFile(
                  id: message['_id'],
                  consultancyId: message['conversation'],
                  courseId: message['course']?['_id'],
                  createdAt: message['createdAt'],
                  seenAt: message['seenAt'],
                  senderId: message['sender']['_id'],
                  senderName: message['sender']['name'],
                  senderUserProfileImageUrl:
                      message['sender']['profileImage'] ?? '',
                  content: url,
                  type: message['type'],
                  path: path));
            } else if (message['type'] == MyMessageType.location.name) {
              final contents = message['contents'] as List<dynamic>;
              String latitude = '';
              String longitude = '';
              String title = '';

              for (var content in contents) {
                if (content['config']?['type'] != null &&
                    content['config']?['type'] == 'latitude') {
                  latitude = content['data'].toString();
                } else if (content['config']?['type'] != null &&
                    content['config']?['type'] == 'longitude') {
                  longitude = content['data'].toString();
                } else if (content['config']?['type'] != null &&
                    content['config']?['type'] == 'title') {
                  title = content['data'].toString();
                }
              }

              loadedMessages.add(Location(
                id: message['_id'],
                consultancyId: message['conversation'],
                courseId: message['course']?['_id'],
                createdAt: message['createdAt'],
                seenAt: message['seenAt'],
                senderId: message['sender']['_id'],
                senderName: message['sender']['name'],
                senderUserProfileImageUrl:
                    message['sender']['profileImage'] ?? '',
                latitude: latitude,
                longitude: longitude,
                content: title,
                type: message['type'],
              ));
            } else
              loadedMessages.add(Message(
                  id: message['_id'],
                  consultancyId: message['conversation'],
                  courseId: message['course']?['_id'],
                  createdAt: message['createdAt'],
                  seenAt: message['seenAt'],
                  senderId: message['sender']['_id'],
                  senderName: message['sender']['name'],
                  senderUserProfileImageUrl:
                      message['sender']['profileImage'] ?? '',
                  senderIsOnline: message['sender']['isOnline'],
                  type: message['type'],
                  content: message['contents'].first['data']));
          }
        }

        if (loadedMessages.isNotEmpty) {
          _feedMessages.addAll(loadedMessages);
        } else {
          feedPages.remove(pageNum);
        }
        update();
        return loadedMessages;
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      feedPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetUserPrivateChats(int pageNum,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      userPrivateChatsPages = [];
      _userPrivateChats = [];
    }

    if (userPrivateChatsPages.contains(pageNum)) {
      return;
    }

    userPrivateChatsPages.add(pageNum);

    final offest = userPrivateChats.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.userPrivateChats}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _userPrivateChatsTotal =
            extractedData['total'] ?? _userPrivateChatsTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Chat> loadedChats = [];

        for (var chat in data) {
          if (chat['_id'] != null) {
            List<CourseUser> users = [];
            final user1 = chat['firstUser'];
            final user2 = chat['secondUser'];

            users.addAll([
              CourseUser(
                email: user1['email'],
                name: user1['name'],
                id: user1['_id'],
                isOnline: user1['isOnline'],
                profileImageUrl: user1['profileImage'] ?? '',
              ),
              CourseUser(
                email: user2['email'],
                name: user2['name'],
                id: user2['_id'],
                isOnline: user2['isOnline'],
                profileImageUrl: user2['profileImage'] ?? '',
              )
            ]);

            loadedChats.add(Chat(
              id: chat['_id'],
              createdAt: chat['createdAt'],
              users: users,
            ));
          }
        }

        if (loadedChats.isNotEmpty) {
          _userPrivateChats.addAll(loadedChats);
        } else {
          userPrivateChatsPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      userPrivateChatsPages.remove(pageNum);

      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrGetOneConversation(String userId) async {
    try {
      final response = await apiClient.postData(
          AppConstants.conversation,
          json.encode(
            {
              'secondUserId': userId,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 201) {
        return responseData['conversation'];
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> getOneConversation(String userId) async {
    try {
      final response = await apiClient.getData(
        '${AppConstants.getOneConversation}?secondUserId=$userId',
      );

      final responseData = response.body;

      if (response.statusCode == 201) {
        return responseData['conversation'];
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteOneConversation(String conversationId) async {
    try {
      final response = await apiClient.deleteData(
        '${AppConstants.conversation}/$conversationId',
      );

      if (response.statusCode == 204) {
        final itemIndex =
            userPrivateChats.indexWhere((item) => item.id == conversationId);

        userPrivateChats.removeAt(itemIndex);
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> answerPoll(String optionId, String pollId) async {
    try {
      final response = await apiClient.postData(
          AppConstants.answerPoll,
          json.encode(
            {
              'messageId': pollId,
              'contentId': optionId,
            },
          ));
      //final responseData = response.body;

      if (response.statusCode != 201) {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<String> uplaodFile(File file) async {
    try {
      final response = await apiClient.multiPart(
          uri: AppConstants.creatAFile,
          file: file,
          type: 'POST',
          fileName: 'file');

      final responseData = response.body;
      if (response.statusCode == 201) {
        final data = responseData as Map<String, dynamic>;

        return data['url'];

        // _currentUser.profileImageUrl = user['profileImage'];
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }
}
