import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/screens_controllers/feed_page_controller.dart';
import '../../../model/themes.dart';
import '../../../utils/get_file_name.dart';

class FileItem extends StatelessWidget {
  final String url;
  final String id;
  final String? path;

  const FileItem({
    Key? key,
    required this.id,
    required this.url,
    required this.path,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedPageController>(
      builder: (screenController) => ListTile(
        title: Text(
          'file_attached'.tr,
          style: TextStyle(color: Themes.textColor),
        ),
        subtitle: Text(
          getFileName(
            url: url,
          ),
          style: TextStyle(color: Themes.textColor),
        ),
        onTap: screenController.isLoadingFile.contains(id)
            ? null
            : path == null
                ? () => screenController.loadFile(url, id)
                : () => openFile(path!),
        leading: Icon(
          Icons.attach_file_rounded,
          color: Themes.primaryColor,
        ),
        trailing: screenController.isLoadingFile.contains(id)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            : path == null
                ? Icon(
                    Icons.download,
                    color: Themes.primaryColor,
                  )
                : Icon(
                    Icons.file_open_outlined,
                    color: Themes.primaryColor,
                  ),
      ),
    );
  }
}
