import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/themes.dart';

Future<Directory?> getDirectory() async {
  String? path;
  Directory? directory;
  //final path = (await getExternalStorageDirectory())!.path;

  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    var sdkInt = androidInfo.version.sdkInt;
    if (await Permission.storage.request().isGranted) {
      if (sdkInt >= 29) {
        path = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
      } else {
        final d = await getExternalStorageDirectory();
        if (d == null) {
          Get.closeAllSnackbars();
          Get.showSnackbar(GetSnackBar(
              backgroundColor: Themes.primaryColorDark,
              messageText: Text(
                'confirm_permission'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Themes.primaryColorLight),
              ),
              duration: const Duration(seconds: 2)));

          return null;
        }
        path = d.path;
      }
      // ignore: unnecessary_null_comparison
      if (path != null) {
        /*  String newPath = "";
      List<String> paths = path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      } */
        final newPath = path + "/TheAcademy";

        directory = Directory(newPath);
        if (!await directory.exists()) {
          directory.create(recursive: true);
        }
      } else {
        Get.closeAllSnackbars();
        Get.showSnackbar(GetSnackBar(
            backgroundColor: Themes.primaryColorDark,
            messageText: Text(
              'confirm_permission'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Themes.primaryColorLight),
            ),
            duration: const Duration(seconds: 2)));

        return null;
      }
    }
  } else {
    directory = await getTemporaryDirectory();

    /*  if (await _requestPermission(Permission.photos)) {
        directory = await getTemporaryDirectory();
      } else {
        showErrorDialog('permission_denied'.tr, context);
        return;
      } */
  }
  return directory;
}
