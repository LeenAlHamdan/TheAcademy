import 'timer_countdown.dart';

/// Convert [Duration] in hours to String for UI.
String durationToStringHours(Duration duration, Duration difference,
    {CountDownTimerFormat format = CountDownTimerFormat.hoursMinutesSeconds}) {
  if (format == CountDownTimerFormat.hoursMinutesSeconds ||
      format == CountDownTimerFormat.hoursMinutes ||
      format == CountDownTimerFormat.hoursOnly) {
    return twoDigits(duration.inHours, "hours", format, difference);
  } else
    return twoDigits(
            duration.inHours.remainder(24), "hours", format, difference)
        .toString();
}

/// Convert [Duration] in days to String for UI.
String durationToStringDays(Duration duration, Duration difference,
    {CountDownTimerFormat format = CountDownTimerFormat.hoursMinutesSeconds}) {
  return twoDigits(duration.inDays, "days", format, difference).toString();
}

/// Convert [Duration] in minutes to String for UI.
String durationToStringMinutes(Duration duration, Duration difference,
    {CountDownTimerFormat format = CountDownTimerFormat.hoursMinutesSeconds}) {
  if (format == CountDownTimerFormat.minutesSeconds ||
      format == CountDownTimerFormat.minutesOnly) {
    return twoDigits(duration.inMinutes, "minutes", format, difference);
  } else
    return twoDigits(
        duration.inMinutes.remainder(60), "minutes", format, difference);
}

/// Convert [Duration] in seconds to String for UI.
String durationToStringSeconds(Duration duration, Duration difference,
    {CountDownTimerFormat format = CountDownTimerFormat.hoursMinutesSeconds}) {
  if (format == CountDownTimerFormat.secondsOnly) {
    return twoDigits(duration.inSeconds, "seconds", format, difference);
  } else
    return twoDigits(
        duration.inSeconds.remainder(60), "seconds", format, difference);
}

/// When the selected [CountDownTimerFormat] is leaving out the last unit, this function puts the UI value of the unit before up by one.
///
/// This is done to show the currently running time unit.
String twoDigits(
    int n, String unitType, CountDownTimerFormat format, Duration difference) {
  switch (unitType) {
    case "minutes":
      if (format == CountDownTimerFormat.daysHoursMinutes ||
          format == CountDownTimerFormat.hoursMinutes ||
          format == CountDownTimerFormat.minutesOnly) {
        if (difference > Duration.zero) {
          n++;
        }
      }
      if (n >= 10) return "$n";
      return "0$n";
    case "hours":
      if (format == CountDownTimerFormat.daysHours ||
          format == CountDownTimerFormat.hoursOnly) {
        if (difference > Duration.zero) {
          n++;
        }
      }
      if (n >= 10) return "$n";
      return "0$n";
    case "days":
      if (format == CountDownTimerFormat.daysOnly) {
        if (difference > Duration.zero) {
          n++;
        }
      }
      if (n >= 10) return "$n";
      return "0$n";
    default:
      if (n >= 10) return "$n";
      return "0$n";
  }
}
