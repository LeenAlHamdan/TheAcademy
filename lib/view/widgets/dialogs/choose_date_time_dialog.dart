import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

Future<DateTime?> showChooseDateAndTimeDialog(
  BuildContext context,
  DateTime init,
  DateTime firstDate,
) async {
  DateTime? _selectedDateTime = await _selectDate(context, init, firstDate);
  return _selectedDateTime;
}

Future<DateTime?> _selectDate(
  BuildContext context,
  DateTime init,
  DateTime firstDate,
) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: init,
    firstDate: firstDate,
    confirmText: 'ok'.tr,
    cancelText: 'cancel'.tr,
    helpText: 'select_date'.tr,
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Themes.customLightTheme,
        child: child!,
      );
    },
  );

  if (picked != null) {
    final time = await _selectTime(context, TimeOfDay.fromDateTime(init));

    DateTime newDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );
    return newDateTime;
  }
  return init;
}

Future<TimeOfDay> _selectTime(
    BuildContext context, TimeOfDay _selectedTime) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: _selectedTime,
    confirmText: 'ok'.tr,
    cancelText: 'cancel'.tr,
    minuteLabelText: 'minute'.tr,
    hourLabelText: 'hour'.tr,
    helpText: 'select_time'.tr,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Themes.customLightTheme,
        child: child!,
      );
    },
  );

  if (picked != null) {
    // Combine the selected date and time

    return picked;
  }
  return _selectedTime;
}
