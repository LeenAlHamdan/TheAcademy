// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/themes.dart';
import '../../utils/download_file_per_link.dart';
import '../../utils/get_directory.dart';
import '../../utils/get_file_name.dart';
import '../widgets/custom_widgets/loading_widget.dart';

class ShowFullImageScreen extends StatefulWidget {
  final String imageUrl;
  final bool haveAppBar;
  final String? title;

  const ShowFullImageScreen(this.imageUrl,
      {Key? key, this.title, this.haveAppBar = true})
      : super(key: key);

  @override
  State<ShowFullImageScreen> createState() => _ShowFullImageScreenState();
}

class _ShowFullImageScreenState extends State<ShowFullImageScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? entry;

  late TransformationController _controller;
  late AnimationController _animationController;
  Animation<Matrix4>? animation;
  late TapDownDetails _doubleTapDetails;

  final _transformationController = TransformationController();
  late final Function tansformListener;

  bool isLoading = false;
  String? path;

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _transformationController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then(
      (value) async {
        final directory = await getDirectory();
        path = directory == null
            ? null
            : await getFilePath(url: widget.imageUrl, directory: directory);
        if (mounted) setState(() {});
      },
    );

    _controller = TransformationController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )
      ..addListener(() => _controller.value = animation!.value)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          removerOverlay();
        }
      });
    /*  Future.delayed(Duration.zero).then((value) async {
      _watermarkImage =
          File('${(await getExternalStorageDirectory())!.path}/logo.jpg');
    }); */
  }

  void restAnimation() {
    animation = Matrix4Tween(begin: _controller.value, end: Matrix4.identity())
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeIn));

    _animationController.forward(from: 0);
  }

  void _handleDoubleTap(String imageUrl) {
    if (_controller.value != Matrix4.identity()) {
      restAnimation();
      removerOverlay();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      showOverlay(context, imageUrl);

      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  Widget buildImage(String imageUrl) {
    return Builder(builder: (context) {
      return GestureDetector(
        onDoubleTapDown: (TapDownDetails details) =>
            _doubleTapDetails = details,
        onDoubleTap: () => _handleDoubleTap(imageUrl),
        child: InteractiveViewer(
          transformationController: _controller,
          clipBehavior: Clip.none,
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(0.0),
          minScale: 1,
          panAxis: PanAxis.aligned,
          maxScale: 10,
          scaleEnabled: true,
          onInteractionEnd: (detailes) {
            if (_controller.value.getNormalMatrix().isIdentity()) {
              removerOverlay();
            }
          },
          onInteractionStart: (detailes) {
            if (detailes.pointerCount < 2) return;
            if (entry == null) {
              showOverlay(
                context,
                imageUrl,
              );
            }
          },
          child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fitWidth,
              height: Get.size.height,
              width: double.infinity,
              placeholder: (context, url) => const LoadingWidget(
                    isDefault: true,
                  )),
        ),
      );
    });
  }

  void showOverlay(
    BuildContext context,
    String imageUrl,
  ) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = Get.size;
    entry = OverlayEntry(builder: (context) {
      return GestureDetector(
        onDoubleTap: () {
          if (entry != null) {
            removerOverlay();
            restAnimation();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: SizedBox(
                width: double.infinity,
                height: size.height - 100,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ),
            ),
            Positioned(
                left: offset.dx,
                top: offset.dy,
                width: size.width,
                child: buildImage(imageUrl)),
          ],
        ),
      );
    });
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void removerOverlay() {
    entry?.remove();
    entry = null;
  }

  loadFile(
    String url,
  ) async {
    if (mounted)
      setState(() {
        isLoading = true;
      });
    try {
      path = await downLoadFilePerLink(url);

      if (mounted)
        setState(() {
          isLoading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = ShowImageAppBar(
      title: widget.title,
      isLoading: isLoading,
      path: path,
      onTap: isLoading
          ? () {}
          : path == null
              ? () => loadFile(
                    widget.imageUrl,
                  )
              : () => openFile(path!),
    );
    return Scaffold(
      appBar: widget.haveAppBar ? appBar : null,
      body: WillPopScope(
        onWillPop: () async {
          if (entry != null) {
            removerOverlay();
            restAnimation();
            //Navigator.of(context).pop(false);
            return false;
          } else {
            Get.back();
            return true;
          }
        },
        child: Center(child: buildImage(widget.imageUrl)),
      ),
    );
  }
}

class ShowImageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShowImageAppBar({
    Key? key,
    this.title,
    required this.path,
    required this.isLoading,
    required this.onTap,
  }) : super(key: key);
  final String? title;
  final String? path;
  final bool isLoading;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title ?? 'show_image'.tr,
          style: TextStyle(
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
        ),
      ),
      iconTheme: Get.theme.iconTheme.copyWith(
        size: 32,
      ),
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
        ),
      ),
      backgroundColor:
          Get.isDarkMode ? Get.theme.backgroundColor : Themes.primaryColorLight,
      elevation: 2,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onTap,
          icon: isLoading
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
        )
      ],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
