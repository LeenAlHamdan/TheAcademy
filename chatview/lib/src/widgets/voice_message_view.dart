//import 'dart:async';
//import 'dart:io';
//import 'dart:math';
//
//import 'package:audio_waveforms/audio_waveforms.dart';
//import 'package:chatview/src/utils/get_directory.dart';
//import 'package:just_audio/just_audio.dart' as audio;
//import 'package:just_waveform/just_waveform.dart';
//import 'package:path/path.dart' as p;
//import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:rxdart/rxdart.dart';
//import 'package:just_audio_cache/just_audio_cache.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../chatview.dart';
import 'package:flutter/material.dart';

import '../utils/chat_bubble_clipper.dart';

class VoiceMessageView extends StatelessWidget {
  const VoiceMessageView(
      {Key? key,
      required this.screenWidth,
      required this.message,
      required this.isMessageBySender,
      required this.incomingbackgroundColor,
      this.outgoingChatBubbleConfig,
      this.onMaxDuration,
      this.ltr = true})
      : super(key: key);

  final Color? incomingbackgroundColor;

  final bool ltr;

  /// Allow user to set width of chat bubble.
  final double screenWidth;

  /// Provides message instance of chat.
  final Message message;
  final Function(int)? onMaxDuration;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  Widget build(BuildContext context) {
    return /*  Stack(
      clipBehavior: Clip.none,
      children: [ */
        Align(
      alignment: ltr
          ? isMessageBySender
              ? Alignment.topRight
              : Alignment.topLeft
          : isMessageBySender
              ? Alignment.topLeft
              : Alignment.topRight,
      // margin: _margin,
      child: PhysicalShape(
        clipper: ChatBubbleClipper3(
          type: ltr
              ? isMessageBySender
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble
              : isMessageBySender
                  ? BubbleType.receiverBubble
                  : BubbleType.sendBubble,
        ),
        elevation: 2,
        color: _color,
        shadowColor: /*  _color ?? */ Colors.grey.shade200,
        child: Padding(
            padding: /* _padding ?? */ setPadding(),
            child: VoiceMessage(
              audioSrc: message.content,
              me: isMessageBySender,
              formatDuration: (duration) =>
                  duration.toString().split('.').first.padLeft(8, "0"),
              meBgColor: outgoingChatBubbleConfig?.color ?? Colors.purple,
              contactBgColor: _color,
              contactCircleColor:
                  outgoingChatBubbleConfig?.color ?? Colors.purple,
              contactPlayIconBgColor:
                  outgoingChatBubbleConfig?.color ?? Colors.purple,
              contactFgColor: outgoingChatBubbleConfig?.color ?? Colors.purple,
              contactPlayIconColor: Colors.white,
            )),
      ),
    )
        /* Container(
          padding: config?.padding ??
              const EdgeInsets.symmetric(horizontal: 8),
          margin: config?.margin ??
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: /* message.reaction.reactions.isNotEmpty ? 15 : */ 0,
              ),
          child: VoiceMessage(
            audioSrc: message.content,
            me: isMessageBySender,
          ) /* Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: /* audioPlayer.processingState !=
                            audio.ProcessingState.ready || */
                    controller == null ? () {} : _playOrPause,
                icon: controller == null
                    /*||
                         audioPlayer.processingState !=
                            audio.ProcessingState.ready */
                    ? const CircularProgressIndicator()
                    : !audioPlayer.playing
                        /*  playerState.isStopped ||
                            playerState.isPaused ||
                            playerState.isInitialised
                     */
                        ? config?.playIcon ??
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            )
                        : config?.pauseIcon ??
                            const Icon(
                              Icons.stop,
                              color: Colors.white,
                            ),
              ),
              /* SizedBox(
                width: screenWidth * 0.5,
                height: 60,
              ) */
              /* controller == null
                  ? SizedBox(
                      width: screenWidth * 0.5,
                      height: 60,
                    )
                  : AudioFileWaveforms(
                      size: Size(widget.screenWidth * 0.50, 60),
                      playerController: controller!,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle:
                          widget.config?.playerWaveStyle ?? playerWaveStyle,
                      padding: widget.config?.waveformPadding ??
                          const EdgeInsets.only(right: 10),
                      margin: widget.config?.waveformMargin,
                      animationCurve:
                          widget.config?.animationCurve ?? Curves.easeIn,
                      animationDuration: widget.config?.animationDuration ??
                          const Duration(milliseconds: 500),
                      enableSeekGesture:
                          widget.config?.enableSeekGesture ?? true,
                    ), */
        /*       StreamBuilder<WaveformProgress>(
                stream: progressStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Get.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final progress = snapshot.data?.progress ?? 0.0;
                  final waveform = snapshot.data?.waveform;
                  if (waveform == null) {
                    return Center(
                      child: Text(
                        '${(100 * progress).toInt()}%',
                        style: Get.textTheme.titleLarge,
                      ),
                    );
                  }
                  return AudioWaveformWidget(
                    waveform: waveform,
                    start: Duration.zero,
                    duration: waveform.duration,
                  );
                },
              ),
         */    ],
          ) */
          ,
        ) */

        /* if (widget.message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            isMessageBySender: widget.isMessageBySender,
            reaction: widget.message.reaction,
            messageReactionConfig: widget.messageReactionConfig,
          ), */
        /* ],
    ) */
        ;
  }

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : incomingbackgroundColor ?? Colors.white;

  EdgeInsets setPadding() {
    if (isMessageBySender) {
      return EdgeInsets.only(right: ltr ? 20 : 0, left: ltr ? 0 : 20);
    } else {
      return EdgeInsets.only(left: ltr ? 20 : 0, right: ltr ? 0 : 20);
    }
  }

  /* void _playOrPause() {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    // if (audioPlayer.processingState != audio.ProcessingState.ready) return;
    if (!audioPlayer.playing)

    /*   if (playerState.isInitialised ||
        playerState.isPaused ||
        playerState.isStopped)  */
    {
      //audioPlayer.play();
      controller!.startPlayer();
      //controller!.startPlayer(finishMode: FinishMode.pause);
    } else {
      audioPlayer.pause();

      // controller!.pausePlayer();
    }
  } */
}
