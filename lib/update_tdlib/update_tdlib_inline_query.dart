// ignore_for_file: empty_catches

import 'package:telegram_client/telegram_client.dart';

Future<Map?> apiUpdateInlineQuery(
  UpdateTd update, {
  required Tdlib tg,
}) async {
  Map msg = {};
  Map from = {"id": update.raw["sender_user_id"]};
  msg["id"] = update.raw["id"];
  try {
    var fromResult = await tg.getUser(
      from["id"],
      clientId: update.client_id,
    );
    if (fromResult["ok"]) {
      from = fromResult["result"];
    }
  } catch (e) {}
  msg["from"] = from;
  if (update.raw["user_location"] is Map) {
    msg["user_location"] = update.raw["user_location"];
  }
  msg["chat_type"] = "unknown";
  if (update.raw["chat_type"] is Map) {
    msg["chat_type"] = (update.raw["chat_type"]["@type"] as String)
        .replaceAll(RegExp(r"chatType", caseSensitive: false), "")
        .toLowerCase();
    if (update.raw["chat_type"]["is_channel"] == true) {
      msg["chat_type"] = "channel";
    }
  }
  msg["query"] = update.raw["query"];
  msg["offset"] = update.raw["offset"];
  return msg;
}
