import 'dart:io';
import 'package:chatview/chatview.dart' as chatview;

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart';
import '../../model/message.dart';
import '../../model/themes.dart';
import '../../services/socket_service.dart';
import '../../services/user_controller.dart';
import '../../utils/download_file_per_link.dart';
import '../../utils/send_attachment.dart';
import '../../view/widgets/custom_widgets/multi_image_input.dart';
import '../../view/widgets/custom_widgets/my_edit_text.dart';
import '../../view/widgets/dialogs/add_poll_dialog.dart';
import '../../view/widgets/dialogs/confirm_change_vote_dialog.dart';
import '../../view/widgets/dialogs/confirm_delete_message_dialog.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/chat_controller.dart';
import 'one_course_of_mine_screen_controller.dart';

class FeedPageController extends GetxController {
  final String courseId;
  final bool isTheCoach;
  FeedPageController(this.courseId, this.isTheCoach);
  int isLoading = 0;
  List<String> isLoadingFile = [];

  final UserController _userController = Get.find();
  final ChatController _chatController = Get.find();
  final SocketService _socketService = injector.get<SocketService>();
  final OneCourseOfMineScreenController _oneCourseOfMineScreenController =
      Get.find();
  List<Asset> _images = [];

  bool _canLoadFeeds = true;
  bool _loadMore = false;
  int _pageNum = 0;

  bool get loadMore => _loadMore && !_lastPage;
  bool get _lastPage =>
      _chatController.feedMessages.length == _chatController.feedTotal;

  List<RxString?> answers = [];

  final scrollController = ScrollController();

  final Rx<LatLng> selectedLocation = Rx<LatLng>(LatLng(37.7749, -122.4194));

  List<chatview.Message> get feedMessages => _chatController.feedMessages;

  OneCourseOfMineScreenController get oneCourseOfMineScreenController =>
      _oneCourseOfMineScreenController;

  void handleTap(LatLng tappedPoint, Function setState) {
    selectedLocation.value = tappedPoint;
    setState(() {});
  }

  deleteItem(chatview.Message item) async {
    if (item.senderId == _userController.userId /* || isTheCoach */) {
      final result = await confirmDeleteMessageDialog(
          title: (item.isLocation
                  ? 'do_you_want_to_delete_this_location'
                  : item.isPoll
                      ? 'do_you_want_to_delete_this_poll'
                      : item.isSlides
                          ? 'do_you_want_to_delete_this_slides'
                          : 'do_you_want_to_delete_this_file')
              .tr);
      if (result == null || !result) return;

      _socketService.deleteMessages(item.id);

      var pos = feedMessages.indexWhere(
        (element) => element.id == item.id,
      );
      // ignore: unnecessary_null_comparison
      if (pos != null) {
        feedMessages.removeAt(pos);
        update();
      }
    }
  }

  @override
  void onInit() {
    answers.addAll(feedMessages.map((e) {
      if (e.isPoll) {
        e as Poll;
        for (var item in e.poolOptions) {
          if (item.isChosedByUser) return item.id.obs;
        }
      }
      return null;
    }));
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _feedPagination();
      }
    });
    super.onInit();
  }

  Future<void> refreshData() async {
    _canLoadFeeds = false;
    try {
      await _chatController.getFeedMessages(
        ++_pageNum,
        courseId: courseId,
        userId: _userController.userId,
        isRefresh: true,
      );
      answers.addAll(feedMessages.map((e) {
        if (e.isPoll) {
          e as Poll;
          for (var item in e.poolOptions) {
            if (item.isChosedByUser) return item.id.obs;
          }
        }
        return null;
      }));
      _pageNum = 0;
      _canLoadFeeds = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoadFeeds = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoadFeeds = true;
    }
  }

  void changeAnswer(
    Poll poll,
    int index,
    String value,
  ) async {
    final previousVote = poll.poolOptions.firstWhereOrNull(
      (element) => element.id == answers[index]?.value,
    );
    if (previousVote != null) {
      final result = await confirmChangeVoteDialog(previousVote.text);
      if (result == null || !result) return;
    }
    previousVote?.chosenBy.remove(_userController.userId);

    answers[index] = value.obs;
    if (previousVote == null) {
      poll.totalVotes++;
      poll.userHasVoted = true;
    }
    update();
    _answerPoll(index, value, poll.id);
  }

  loadFile(String url, String id) async {
    isLoadingFile.add(id);
    update();
    try {
      String? path = await downLoadFilePerLink(url);
      final item = feedMessages.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (item != null) {
        item as MyFile;

        item.path = path;
      }
      isLoadingFile.remove(id);
      update();
    } catch (_) {
      isLoadingFile.remove(id);
      update();
    }
  }

  void addSlidesDialog() {
    final _titleController = TextEditingController();
    _images = [];
    Get.defaultDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyEditText(
            title: 'title'.tr,
            prefixIcon: Icons.title_rounded,
            textController: _titleController,
          ),
          MultiImageInput(
            _selectMultiImage,
            images: _images,
          )
        ],
      ),
      barrierDismissible: false,
      title: 'add_slides'.tr,
      textConfirm: 'send'.tr,
      confirmTextColor: Themes.primaryColorLight,
      onConfirm: () {
        if (_titleController.text.isEmpty || _images.isEmpty) {
          var errorMessage = 'fill_all_info'.tr;
          showErrorDialog(
            errorMessage,
          );
          return;
        }
        _sendSlides(_titleController.text);
        Get.back();

        //changePass(userController);
      },
      textCancel: 'cancel'.tr,
    );
  }

  void showPollDialog() {
    addPollDialog(_sendPoll);
  }

  void _feedPagination() async {
    if (_canLoadFeeds) {
      _loadMore = true;
      update();

      _canLoadFeeds = false;
      _getFeeds();
    }
  }

  Future<void> _getFeeds() async {
    if (_lastPage) {
      _canLoadFeeds = true;
      _loadMore = false;
      update();

      return;
    }
    try {
      final newData = await _chatController.getFeedMessages(
        ++_pageNum,
        courseId: courseId,
        userId: _userController.userId,
      );
      answers.addAll(newData.map((e) {
        if (e.isPoll) {
          e as Poll;
          for (var item in e.poolOptions) {
            if (item.isChosedByUser) return item.id.obs;
          }
        }
        return null;
      }));
      _canLoadFeeds = true;
    } on HttpException catch (error) {
      _pageNum--;
      _canLoadFeeds = true;

      showErrorDialog('error'.tr);
      _loadMore = false;
      update();
      throw error;
    } catch (error) {
      _pageNum--;
      _canLoadFeeds = true;

      showErrorDialog('error'.tr);
      _loadMore = false;
      update();
      throw error;
    }
    _loadMore = false;
    update();
  }

  void _submitMessage({
    required String? courseId,
    required MyMessageType type,
    required String message,
    List<Map<String, dynamic>>? content,
  }) {
    if (message != '' || content != null) {
      _socketService.sendMessage(message,
          tempId: '', courseId: courseId, type: type.name, content: content);
      //  socketService.isTyping(false);
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _answerPoll(int index, String value, String pollId) async {
    //  isLoadingAnswer = true;
    update();
    try {
      await _chatController.answerPoll(value, pollId);
      answers[index] = value.obs;
      var pooItem = (feedMessages[index] as Poll).poolOptions.firstWhereOrNull(
            (element) => element.id == value,
          );
      pooItem?.isChosedByUser = true;
      pooItem?.chosenBy.add(_userController.userId);
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      showErrorDialog(errorMessage);
      //  isLoadingAnswer = false;
      answers[index] = null;
      update();
    } catch (error) {
      var errorMessage = 'error'.tr;

      showErrorDialog(
        errorMessage,
      );
//      isLoadingAnswer = false;
      answers[index] = null;

      update();
    }
    // isLoadingAnswer = false;
    update();
  }

  void addLocation() async {
    {
      var hasData = false;
      try {
        await sendLocation(this, (content) {
          _submitMessage(
              courseId: courseId,
              type: MyMessageType.location,
              content: content,
              message: '');
        }, () {
          isLoading++;
          update();
          hasData = true;
        });
        if (hasData) {
          refreshData();
          isLoading--;
          update();
        }
      } on HttpException catch (_) {
        isLoading--;
        update();
      } catch (error) {
        isLoading--;
        update();
      }
    }
  }

  Future<void> addFile() async {
    try {
      var hasData = false;

      await sendFile(
          (fileUrl) {
            _submitMessage(
                courseId: courseId, type: MyMessageType.file, message: fileUrl);
          },
          _chatController,
          () {
            isLoading++;
            update();
            hasData = true;
          });
      if (hasData) {
        isLoading--;
        update();
        refreshData();
      }
    } on HttpException catch (_) {
      isLoading--;
      update();
    } catch (error) {
      isLoading--;
      update();
    }
  }

  Future<void> _sendPoll(String pollText,
      List<TextEditingController> _optionsTextControllers) async {
    isLoading++;
    update();
    try {
      List<Map<String, dynamic>> content = [
        {
          "data": pollText,
          "config": {"content-type": 'poll-text'},
        }
      ];

      for (var option in _optionsTextControllers) {
        if (option.text.isNotEmpty) content.add({"data": option.text});
      }
      _submitMessage(
          courseId: courseId,
          type: MyMessageType.poll,
          content: content,
          message: '');
      refreshData();
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      showErrorDialog(errorMessage);
      isLoading--;
      update();
    } catch (error) {
      var errorMessage = 'error'.tr;

      showErrorDialog(
        errorMessage,
      );
      isLoading--;
      update();
    }
    isLoading--;
    update();
  }

  void _selectMultiImage(List<Asset> images) {
    _images = images;
    update();
  }

  Future<void> _sendSlides(String title) async {
    {
      isLoading++;
      update();
      try {
        await sendSlides(title, _images, (files) {
          _submitMessage(
              courseId: courseId,
              type: MyMessageType.slides,
              content: files,
              message: '');
        }, _chatController);
        refreshData();
      } on HttpException catch (_) {
        isLoading--;
        update();
      } catch (error) {
        isLoading--;
        update();
      }
      isLoading--;
      update();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
