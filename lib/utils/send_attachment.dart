import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_academy/controller/models_controller/chat_controller.dart';
import 'package:the_academy/utils/init_location_service.dart';

import '../controller/screens_controllers/feed_page_controller.dart';
import 'package:latlong2/latlong.dart';

import '../model/themes.dart';
import '../view/widgets/dialogs/error_dialog.dart';
import '../view/widgets/dialogs/location_picker_dialog.dart';

Future<String?> sendFile(Function _submitMessage,
    ChatController _chatController, Function() changeLoadState,
    {bool withSend = true}) async {
  final _pickedFile = await _pickFile();
  if (_pickedFile == null) return null;
  String? reult = await Get.defaultDialog(
    title: 'you_will_send_the_following_file'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      _pickedFile.path.substring(_pickedFile.path.lastIndexOf('/') + 1),
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    textConfirm: 'send'.tr,
    textCancel: 'cancel'.tr,
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: () async {
      Get.back(result: _pickedFile.path);
    },
  );
  if (withSend) {
    changeLoadState();

    await _sendFile(_pickedFile, _submitMessage, _chatController);
  }
  return reult;
}

Future<void> _sendFile(
    File file, Function _submitMessage, ChatController _chatController) async {
  try {
    final fileUrl = await _postFile(file, _chatController);
    if (fileUrl != null) {
      _submitMessage(fileUrl);
    }
  } on HttpException catch (_) {
    var errorMessage = 'error'.tr;

    showErrorDialog(errorMessage);
    rethrow;
  } catch (error) {
    var errorMessage = 'error'.tr;

    showErrorDialog(
      errorMessage,
    );
    rethrow;
  }
}

Future<String?> _postFile(
    File pickedImage, ChatController _chatController) async {
  try {
    return await _chatController.uplaodFile(pickedImage);
  } on HttpException catch (_) {
    rethrow;
  } catch (error) {
    rethrow;
  }
}

Future<File?> _pickFile() async {
  FilePicker.platform.clearTemporaryFiles();

  final result = await FilePicker.platform.pickFiles(
      allowMultiple: false, type: FileType.any, allowedExtensions: null);

  // if no file is picked
  if (result == null) return null;

  var file = File(result.files.first.path!);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String destFilePath = '${appDocDir.path}/${result.files.first.name}';
  await file.copy(destFilePath);
  return File(destFilePath);
}

Future<void> sendSlides(String title, List<Asset> _images,
    Function _submitMessage, ChatController _chatController) async {
  try {
    List<Map<String, dynamic>> files = [
      {
        "data": title,
        "config": {"content-type": 'title'},
      }
    ];

    for (var image in _images) {
      final byteData = await image.getByteData();

      final tempFile =
          File("${(await getTemporaryDirectory()).path}/${image.name}");
      final file = await tempFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // var base64Image = base64Encode(file.readAsBytesSync());
      final fileUrl = await _postFile(file, _chatController);

      if (fileUrl != null) files.add({"data": fileUrl});
    }
    _submitMessage(
      files,
    );
  } on HttpException catch (_) {
    var errorMessage = 'error'.tr;

    showErrorDialog(errorMessage);
    rethrow;
  } catch (error) {
    var errorMessage = 'error'.tr;

    showErrorDialog(
      errorMessage,
    );
    rethrow;
  }
}

Future<void> sendLocation(
  FeedPageController controller,
  Function _submitMessage,
  Function() changeLoadState,
) async {
  try {
    await initLocationService().then((value) async {
      value ??= LatLng(36.21508, 37.128727);
      controller.selectedLocation.value = value;
      final _locationTitleController = TextEditingController();

      LatLng? selected =
          await locationPickerDialog(controller, _locationTitleController);

      if (selected != null) {
        changeLoadState();
        // Do something with the selected location
        await _sendLocation(
            selected, _locationTitleController.text, _submitMessage);
      }
    });
  } on HttpException catch (_) {
    rethrow;
  } catch (error) {
    debugPrint('$error');
    rethrow;
  }
}

Future<void> _sendLocation(
  LatLng location,
  String title,
  Function _submitMessage,
) async {
  try {
    List<Map<String, dynamic>> content = [
      {
        "data": title,
        "config": {"type": "title"}
      },
      {
        "data": location.latitude.toString(),
        "config": {"type": "latitude"}
      },
      {
        "data": location.longitude.toString(),
        "config": {"type": "longitude"}
      }
    ];

    _submitMessage(
      content,
    );
  } on HttpException catch (_) {
    var errorMessage = 'error'.tr;

    showErrorDialog(errorMessage);
  } catch (error) {
    var errorMessage = 'error'.tr;

    showErrorDialog(
      errorMessage,
    );
  }
}
