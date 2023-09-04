import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

handelPendnigMessages(String tempId, SharedPreferences sharedPrefs) {
  var string = sharedPrefs.getString("pendingMessages");
  List<dynamic> pendingMessages = [];
  if (string != null) {
    pendingMessages = jsonDecode(string) as List<dynamic>;
  }
  try {
    var pendingMessage = pendingMessages
        .indexWhere((element) => element['message']['_id'] == tempId);
    if (pendingMessage != -1) {
      pendingMessages.removeAt(pendingMessage);
      sharedPrefs.remove(
        "pendingMessages",
      );
      sharedPrefs.setString("pendingMessages", jsonEncode(pendingMessages));
    }
  } catch (_) {}
}
