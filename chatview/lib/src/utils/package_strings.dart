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
class PackageStrings {
  PackageStrings({
    String? todayText,
    String? yesterdayText,
    String? repliedToYouText,
    String? repliedByText,
    String? replyToText,
    String? moreText,
    String? unsendText,
    String? replyText,
    String? messageText,
    String? reactionPopupTitleText,
    String? photoText,
    String? sendText,
    String? youText,
  }) {
    today = todayText;
    yesterday = yesterdayText;
    repliedToYou = repliedToYouText;
    repliedBy = repliedByText;
    replyTo = replyToText;
    more = moreText;
    unsend = unsendText;
    reply = replyText;
    message = messageText;
    reactionPopupTitle = reactionPopupTitleText;
    photo = photoText;
    send = sendText;
    you = youText;
  }

  static String _today = "Today";
  static String _yesterday = 'Yesterday';
  static String _repliedBy = "Replied by";
  static String _more = "More";
  static String _unsend = 'Unsend';
  static String _reply = 'Reply';
  static String _message = 'Message';
  static String _photo = 'Photo';
  static String _send = 'Send';
  static String _you = 'You';

  static String _repliedToYou = 'Replied to you';
  static String _reactionPopupTitle = 'Tap and hold to multiply your reaction';

  static String _replyTo = "Replying to";

  static String get today => _today;
  static String get yesterday => _yesterday;
  static String get repliedToYou => _repliedToYou;
  static String get repliedBy => _repliedBy;
  static String get more => _more;
  static String get unsend => _unsend;
  static String get reply => _reply;
  static String get replyTo => _replyTo;
  static String get message => _message;
  static String get reactionPopupTitle => _reactionPopupTitle;
  static String get photo => _photo;
  static String get send => _send;
  static String get you => _you;

  static set today(String? value) => _today = value ?? _today;
  static set yesterday(String? value) => _yesterday = value ?? _yesterday;
  static set repliedToYou(String? value) =>
      _repliedToYou = value ?? _repliedToYou;
  static set repliedBy(String? value) => _repliedBy = value ?? _repliedBy;
  static set more(String? value) => _more = value ?? _more;
  static set unsend(String? value) => _unsend = value ?? unsend;
  static set reply(String? value) => _reply = value ?? reply;
  static set replyTo(String? value) => _replyTo = value ?? replyTo;
  static set message(String? value) => _message = value ?? message;
  static set reactionPopupTitle(String? value) =>
      _reactionPopupTitle = value ?? reactionPopupTitle;
  static set photo(String? value) => _photo = value ?? photo;
  static set send(String? value) => _send = value ?? send;
  static set you(String? value) => _you = value ?? you;
}
