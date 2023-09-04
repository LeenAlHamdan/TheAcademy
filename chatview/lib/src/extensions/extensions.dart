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

import '../../chatview.dart';
import '../utils/emoji_parser.dart';
import '../widgets/chat_view_inherited_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

/// Extension for DateTime to get specific formats of dates and time.
extension TimeDifference on DateTime {
  String get getDay {
    final DateTime formattedDate =
        DateFormat(dateFormat).parse(toString()).toLocal();
    final DateFormat formatter = DateFormat.yMMMMd(enUS);
    final differenceInDays =
        formattedDate.difference(DateTime.now().toLocal()).inDays;
    if (differenceInDays == 0) {
      return PackageStrings.today;
    } else if (differenceInDays <= 1 && differenceInDays >= -1) {
      return PackageStrings.yesterday;
    } else {
      return formatter.format(formattedDate);
    }
  }

  String get getDateFromDateTime {
    final DateFormat formatter = DateFormat(dateFormat);
    return formatter.format(this);
  }

  String get getTimeFromDateTime => DateFormat.Hm().format(this);
}

/// Extension on String which implements different types string validations.
extension ValidateString on String {
  bool get isImageUrl {
    final imageUrlRegExp = RegExp(imageUrlRegExpression);
    return imageUrlRegExp.hasMatch(this) || startsWith('data:image');
  }

  bool get fromMemory => startsWith('data:image');

  bool get isAllEmoji {
    for (String s in EmojiParser().unemojify(this).split(" ")) {
      if (!s.startsWith(":") || !s.endsWith(":")) {
        return false;
      }
    }
    return true;
  }

  bool get isUrl => Uri.tryParse(this)?.isAbsolute ?? false;
}

/// Extension on State for accessing inherited widget.
extension StatefulWidgetExtension on State {
  ChatViewInheritedWidget? get provide => ChatViewInheritedWidget.of(context);
}
