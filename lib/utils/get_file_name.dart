import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

String getFileName({
  required String url,
}) {
  var fileName = url.substring(
    url.lastIndexOf('.com') + 5,
  );
  //fileName = fileName.substring(0, fileName.lastIndexOf('.'));
  return fileName;
}

Future<String?> getFilePath({
  required String url,
  required Directory directory,
}) async {
  var fileName = getFileName(url: url);
  if (await File('${directory.path}/$fileName').exists()) {
    return '${directory.path}/$fileName';
  }

  return null;
}

openFile(String path) {
  try {
    OpenFilex.open(path);
  } catch (error) {
    debugPrint(error.toString());
  }
}
