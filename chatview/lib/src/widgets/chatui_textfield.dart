/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:io' show Platform;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../chatview.dart';
import '../utils/constants.dart';

class ChatUITextField extends StatefulWidget {
  const ChatUITextField(
      {Key? key,
      this.sendMessageConfig,
      required this.focusNode,
      required this.textEditingController,
      required this.onPressed,
      required this.onRecordingComplete,
      required this.onImageSelected,
      required this.onFileSelected,
      this.onTextFieldTap,
      required this.hasAttach,
      required this.onAttach,
      required this.noRecentText,
      required this.hasEmoji})
      : super(key: key);
  final String noRecentText;
  final bool hasEmoji;
  final bool hasAttach;
  final Function? onAttach;

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration? sendMessageConfig;

  /// Provides focusNode for focusing text field.
  final FocusNode focusNode;

  /// Provides functions which handles text field.
  final TextEditingController textEditingController;

  final Function()? onTextFieldTap;

  /// Provides callback when user tap on text field.
  final VoidCallBack onPressed;

  /// Provides callback once voice is recorded.
  final Function(String?) onRecordingComplete;

  /// Provides callback when user select images from camera/gallery.
  final StringsCallBack onImageSelected;

  final StringsCallBack onFileSelected;

  @override
  State<ChatUITextField> createState() => _ChatUITextFieldState();
}

class _ChatUITextFieldState extends State<ChatUITextField> {
  bool showEmoji = false;
  bool showSend = false;
  //String _inputText = '';

  final ImagePicker _imagePicker = ImagePicker();

  RecorderController? controller;

  bool isRecording = false;

  SendMessageConfiguration? get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration? get voiceRecordingConfig =>
      widget.sendMessageConfig?.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig?.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig?.textFieldConfig;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
      );

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      controller = RecorderController();
    }
  }

  void toggleShowEmoji({bool? value}) {
    showEmoji = value ?? !showEmoji;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showEmoji) {
          toggleShowEmoji();
          return false;
        }
        return true;
      },
      child: Container(
        padding: textFieldConfig?.padding ??
            const EdgeInsets.symmetric(horizontal: 6),
        margin: textFieldConfig?.margin,
        decoration: BoxDecoration(
          borderRadius: textFieldConfig?.borderRadius ??
              BorderRadius.circular(textFieldBorderRadius),
          color: sendMessageConfig?.textFieldBackgroundColor ?? Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRecording && widget.hasEmoji)
                  IconButton(
                    icon: Icon(
                        showEmoji
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: imagePickerIconsConfig?.galleryIconColor),
                    onPressed: () {
                      if (!showEmoji) {
                        FocusManager.instance.primaryFocus?.unfocus();

                        widget.focusNode.unfocus();
                      } else {
                        FocusScope.of(context).requestFocus(widget.focusNode);
                      }
                      toggleShowEmoji();
                    },
                  ),
                if (isRecording && controller != null)
                  AudioWaveforms(
                    size: Size(MediaQuery.of(context).size.width * 0.6, 50),
                    recorderController: controller!,
                    margin: voiceRecordingConfig?.margin,
                    padding: voiceRecordingConfig?.padding ??
                        const EdgeInsets.symmetric(horizontal: 8),
                    decoration: voiceRecordingConfig?.decoration ??
                        BoxDecoration(
                          color: voiceRecordingConfig?.backgroundColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                    waveStyle: voiceRecordingConfig?.waveStyle ??
                        WaveStyle(
                          extendWaveform: true,
                          showMiddleLine: false,
                          waveColor:
                              voiceRecordingConfig?.waveStyle?.waveColor ??
                                  Colors.black,
                        ),
                  )
                else
                  Expanded(
                    child: TextField(
                      focusNode: widget.focusNode,
                      controller: widget.textEditingController,
                      onTap: () {
                        toggleShowEmoji(value: false);
                      },
                      style: textFieldConfig?.textStyle ??
                          const TextStyle(color: Colors.white),
                      maxLines: textFieldConfig?.maxLines ?? 5,
                      minLines: textFieldConfig?.minLines ?? 1,
                      keyboardType: textFieldConfig?.textInputType,
                      inputFormatters: textFieldConfig?.inputFormatters,
                      onChanged: (val) {
                        showSend = val.isNotEmpty;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      textCapitalization: textFieldConfig?.textCapitalization ??
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText:
                            textFieldConfig?.hintText ?? PackageStrings.message,
                        fillColor:
                            sendMessageConfig?.textFieldBackgroundColor ??
                                Colors.white,
                        filled: true,
                        hintStyle: textFieldConfig?.hintStyle ??
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.25,
                            ),
                        contentPadding: textFieldConfig?.contentPadding ??
                            const EdgeInsets.symmetric(horizontal: 6),
                        border: _outLineBorder,
                        focusedBorder: _outLineBorder,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: textFieldConfig?.borderRadius ??
                              BorderRadius.circular(textFieldBorderRadius),
                        ),
                      ),
                    ),
                  ),
                showSend
                    ? IconButton(
                        color: sendMessageConfig?.defaultSendButtonColor ??
                            Colors.green,
                        onPressed: () {
                          widget.onPressed();
                          setState(() => widget.textEditingController.clear());
                          if (showEmoji) toggleShowEmoji();
                          showSend = false;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        icon: sendMessageConfig?.sendButtonIcon ??
                            const Icon(Icons.send),
                      )
                    : Row(
                        children: [
                          if (!isRecording) ...[
                            IconButton(
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _onImagePressed(ImageSource.camera),
                              icon: imagePickerIconsConfig
                                      ?.cameraImagePickerIcon ??
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color:
                                        imagePickerIconsConfig?.cameraIconColor,
                                  ),
                            ),
                            if (widget.hasAttach)
                              IconButton(
                                constraints: const BoxConstraints(),
                                onPressed: widget.onAttach != null
                                    ? () async {
                                        final data = await widget.onAttach!();
                                        _onIconPressed(data?['path'],
                                            type: data['type'] == 'file'
                                                ? MessageTypes.file
                                                : MessageTypes.image);
                                      }
                                    : () =>
                                        _onImagePressed(ImageSource.gallery),
                                icon: Icon(
                                  Icons.attach_file,
                                  color:
                                      imagePickerIconsConfig?.galleryIconColor,
                                ),
                              )
                            else
                              IconButton(
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    _onImagePressed(ImageSource.gallery),
                                icon: imagePickerIconsConfig
                                        ?.galleryImagePickerIcon ??
                                    Icon(
                                      Icons.image,
                                      color: imagePickerIconsConfig
                                          ?.galleryIconColor,
                                    ),
                              ),
                          ],
                          if (widget.sendMessageConfig?.allowRecordingVoice ??
                              true && Platform.isIOS && Platform.isAndroid)
                            IconButton(
                              onPressed: _recordOrStop,
                              icon: (isRecording
                                      ? voiceRecordingConfig?.micIcon
                                      : voiceRecordingConfig?.stopIcon) ??
                                  Icon(isRecording ? Icons.stop : Icons.mic),
                              color: voiceRecordingConfig?.recorderIconColor,
                            )
                        ],
                      ),
              ],
            ),
            if (widget.hasEmoji)
              Offstage(
                offstage: !showEmoji,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: EmojiPicker(
                      config: Config(
                          columns: 7,
                          emojiSizeMax: 24 * (Platform.isIOS ? 1.30 : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          // gridPadding: EdgeInsets.zero,
                          bgColor: const Color(0xFFF2F2F2),
                          indicatorColor: const Color(0xFF6E6E6E),
                          iconColor: Colors.grey,
                          iconColorSelected: const Color(0xFF6E6E6E),
                          //progressIndicatorColor: primaryColorDark,
                          backspaceColor: const Color(0xFF6E6E6E),
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,

                          //showRecentsTab: true,
                          recentsLimit: 28,
                          // replaceEmojiOnLimitExceed: false,
                          noRecents: Text(
                            widget.noRecentText,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black26),
                            textAlign: TextAlign.center,
                          ),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL),
                      onEmojiSelected: (
                        _,
                        emoji,
                      ) {
                        widget.textEditingController.text += emoji.emoji;
                        showSend = true;
                        if (mounted) {
                          setState(() {});
                        }
                      }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (!isRecording) {
      await controller?.record();
      isRecording = true;
    } else {
      final path = await controller?.stop();
      isRecording = false;
      widget.onRecordingComplete(path);
    }
    setState(() {});
  }

  _onImagePressed(ImageSource imageSource) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: imageSource);

      _onIconPressed(image?.path ?? '');
    } catch (e) {
      widget.onImageSelected('', e.toString());
    }
  }

  void _onIconPressed(String path,
      {MessageTypes type = MessageTypes.image}) async {
    try {
      type == MessageTypes.image
          ? widget.onImageSelected(path, '')
          : widget.onFileSelected(path, '');
    } catch (e) {
      // widget.onImageSelected('', e.toString());
    }
  }

/*   void _onChanged(String inputText) => setState(() => _inputText = inputText);
 */
}
