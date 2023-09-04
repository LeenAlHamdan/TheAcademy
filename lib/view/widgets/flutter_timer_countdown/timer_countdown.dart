library flutter_timer_countdown;

import 'dart:async';
import 'package:flutter/widgets.dart';

import 'functions.dart';

enum CountDownTimerFormat {
  daysHoursMinutesSeconds,
  daysHoursMinutes,
  daysHours,
  daysOnly,
  hoursMinutesSeconds,
  hoursMinutes,
  hoursOnly,
  minutesSeconds,
  minutesOnly,
  secondsOnly,
}

class TimerCountdown extends StatefulWidget {
  /// Choose between different `CountDownTimerFormat`s
  final CountDownTimerFormat format;

  /// Defines the time when the timer is over.
  final DateTime endTime;

  /// Function to call when the timer is over.
  final VoidCallback? onEnd;

  /// Toggle time units descriptions.
  final bool enableDescriptions;

  /// `TextStyle` for the time numbers.
  final TextStyle? timeTextStyle;

  /// `TextStyle` for the colons betwenn the time numbers.
  final TextStyle? colonsTextStyle;

  /// `TextStyle`
  final TextStyle? descriptionTextStyle;

  /// Days unit description.
  final String daysDescription;

  /// Hours unit description.
  final String hoursDescription;

  /// Minutes unit description.
  final String minutesDescription;

  /// Seconds unit description.
  final String secondsDescription;

  /// Defines the width between the colons and the units.
  final double spacerWidth;

  TimerCountdown({
    required this.endTime,
    this.format = CountDownTimerFormat.daysHoursMinutesSeconds,
    this.enableDescriptions = true,
    this.onEnd,
    this.timeTextStyle,
    this.colonsTextStyle,
    this.descriptionTextStyle,
    this.daysDescription = "Days",
    this.hoursDescription = "Hours",
    this.minutesDescription = "Minutes",
    this.secondsDescription = "Seconds",
    this.spacerWidth = 10,
  });

  @override
  _TimerCountdownState createState() => _TimerCountdownState();
}

class _TimerCountdownState extends State<TimerCountdown> {
  Timer? timer;
  late String countdownDays;
  late String countdownHours;
  late String countdownMinutes;
  late String countdownSeconds;
  late Duration difference;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  /// Calculate the time difference between now end the given [endTime] and initialize all UI timer values.
  ///
  /// Then create a periodic `Timer` which updates all fields every second depending on the time difference which is getting smaller.
  /// When this difference reached `Duration.zero` the `Timer` is stopped and the [onEnd] callback is invoked.
  void _startTimer() {
    if (widget.endTime.isBefore(DateTime.now())) {
      difference = Duration.zero;
    } else {
      difference = widget.endTime.difference(DateTime.now());
    }

    countdownDays = durationToStringDays(
      difference,
      difference,
      format: widget.format,
    );
    countdownHours = durationToStringHours(
      difference,
      difference,
      format: widget.format,
    );
    countdownMinutes = durationToStringMinutes(
      difference,
      difference,
      format: widget.format,
    );
    countdownSeconds = durationToStringSeconds(
      difference,
      difference,
      format: widget.format,
    );

    if (difference == Duration.zero) {
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        difference = widget.endTime.difference(DateTime.now());
        setState(() {
          countdownDays = durationToStringDays(
            difference,
            difference,
            format: widget.format,
          );
          countdownHours = durationToStringHours(
            difference,
            difference,
            format: widget.format,
          );
          countdownMinutes = durationToStringMinutes(
            difference,
            difference,
            format: widget.format,
          );
          countdownSeconds = durationToStringSeconds(
            difference,
            difference,
            format: widget.format,
          );
        });
        if (difference <= Duration.zero) {
          timer.cancel();
          if (widget.onEnd != null) {
            widget.onEnd!();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _countDownTimerFormat();
  }

  /// Builds the UI colons between the time units.
  Widget _colon() {
    return Row(
      children: [
        SizedBox(
          width: widget.spacerWidth,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ":",
              style: widget.colonsTextStyle,
            ),
            if (widget.enableDescriptions)
              SizedBox(
                height: 5,
              ),
            if (widget.enableDescriptions)
              Text(
                "",
                style: widget.descriptionTextStyle,
              ),
          ],
        ),
        SizedBox(
          width: widget.spacerWidth,
        ),
      ],
    );
  }

  /// Builds the timer days with its description.
  Widget _days(BuildContext context) {
    return countdownDays == '00'
        ? SizedBox()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                countdownDays,
                style: widget.timeTextStyle,
              ),
              if (widget.enableDescriptions)
                SizedBox(
                  height: 5,
                ),
              if (widget.enableDescriptions)
                Text(
                  widget.daysDescription,
                  style: widget.descriptionTextStyle,
                ),
            ],
          );
  }

  /// Builds the timer hours with its description.
  Widget _hours(BuildContext context) {
    return countdownHours == '00'
        ? SizedBox()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                countdownHours,
                style: widget.timeTextStyle,
              ),
              if (widget.enableDescriptions)
                SizedBox(
                  height: 5,
                ),
              if (widget.enableDescriptions)
                Text(
                  widget.hoursDescription,
                  style: widget.descriptionTextStyle,
                ),
            ],
          );
  }

  /// Builds the timer minutes with its description.
  Widget _minutes(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          countdownMinutes,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.minutesDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// Builds the timer seconds with its description.
  Widget _seconds(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          countdownSeconds,
          style: widget.timeTextStyle,
        ),
        if (widget.enableDescriptions)
          SizedBox(
            height: 5,
          ),
        if (widget.enableDescriptions)
          Text(
            widget.secondsDescription,
            style: widget.descriptionTextStyle,
          ),
      ],
    );
  }

  /// Switches the UI to be displayed based on [CountDownTimerFormat].
  Widget _countDownTimerFormat() {
    switch (widget.format) {
      case CountDownTimerFormat.daysHoursMinutesSeconds:
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _days(context),
            countdownDays == '00' ? SizedBox() : _colon(),
            _hours(context),
            countdownHours == '00' ? SizedBox() : _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
      case CountDownTimerFormat.daysHoursMinutes:
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _days(context),
            countdownDays == '00' ? SizedBox() : _colon(),
            _hours(context),
            countdownHours == '00' ? SizedBox() : _colon(),
            _minutes(context),
          ],
        );
      case CountDownTimerFormat.daysHours:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
            countdownDays == '00' ? SizedBox() : _colon(),
            _hours(context),
          ],
        );
      case CountDownTimerFormat.daysOnly:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _days(context),
          ],
        );
      case CountDownTimerFormat.hoursMinutesSeconds:
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _hours(context),
            countdownHours == '00' ? SizedBox() : _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
      case CountDownTimerFormat.hoursMinutes:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _hours(context),
            countdownHours == '00' ? SizedBox() : _colon(),
            _minutes(context),
          ],
        );
      case CountDownTimerFormat.hoursOnly:
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _hours(context),
          ],
        );
      case CountDownTimerFormat.minutesSeconds:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );

      case CountDownTimerFormat.minutesOnly:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _minutes(context),
          ],
        );
      case CountDownTimerFormat.secondsOnly:
        return Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            _seconds(context),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _days(context),
            countdownDays == '00' ? SizedBox() : _colon(),
            _hours(context),
            countdownHours == '00' ? SizedBox() : _colon(),
            _minutes(context),
            _colon(),
            _seconds(context),
          ],
        );
    }
  }
}
