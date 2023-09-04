import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

import '../model/http_exception.dart';
import '../view/widgets/dialogs/error_dialog.dart';
import 'get_directory.dart';
import 'get_file_name.dart';

Future<String?> downLoadFilePerLink(String url) async {
  Get.closeAllSnackbars();
  Get.showSnackbar(GetSnackBar(
      backgroundColor: Themes.primaryColorDark,
      messageText: Text(
        'loading_started'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Themes.primaryColorLight),
      ),
      duration: const Duration(seconds: 2)));

  final directory = await getDirectory();

  if (directory == null) return null;
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  try {
    final fileName = getFileName(
      url: url,
    );

    Dio dio = Dio();
    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    var path = '${directory.path}/$fileName';
    File file = File(path); // Replace with your desired download directory path
    await file.writeAsBytes(response.data);

    Get.closeAllSnackbars();
    Get.showSnackbar(GetSnackBar(
        backgroundColor: Themes.primaryColorDark,
        onTap: (snack) => openFile(path),
        messageText: Text(
          '${'downloaded_at'.tr} Download/TheAcademy/$fileName',
          textAlign: TextAlign.center,
          style: TextStyle(color: Themes.primaryColorLight),
        ),
        duration: const Duration(seconds: 2)));
    return path;
  } on HttpException catch (_) {
    showErrorDialog(
      'error'.tr,
    );

    throw HttpException('error');
  } catch (error) {
    showErrorDialog(
      'error'.tr,
    );

    rethrow;
  }
}
