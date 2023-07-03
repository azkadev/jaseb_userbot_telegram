// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:telegram_client/telegram_client.dart';

Future<Map?> apiUpdateCallbackQuery(UpdateTd update,
    {required Tdlib tg}) async {
  Map msg = {};
  msg["id"] = update.raw["id"];
  Map from = {"id": update.raw["sender_user_id"]};
  if (update.raw["@type"] == "updateNewInlineCallbackQuery") {
    try {
      var fromResult = await tg.getUser(
        from["id"],
        clientId: update.client_id,
      );
      if (fromResult["ok"]) {
        from = fromResult["result"];
      }
    } catch (e) {}
    msg["inline_message_id"] = update.raw["inline_message_id"];
    msg["from"] = from;
    msg["chat"] = from;
    msg["message"] = {"from": from, "chat": from};
  } else {
    Map chat = {"id": update.raw["chat_id"]};
    try {
      var fromResult = await tg.getChat(chat["id"], clientId: update.client_id);
      if (fromResult["ok"]) {
        chat = fromResult["result"];
      }
    } catch (e) {}
    try {
      var fromResult = await tg.getUser(
        from["id"],
        clientId: update.client_id,
      );
      if (fromResult["ok"]) {
        from = fromResult["result"];
      }
    } catch (e) {}

    try {
      var getMessage = await tg.getMessage(
        chat["id"],
        update.raw["message_id"],
        is_detail: true,
        is_super_detail: true,
        clientId: update.client_id,
      );
      if (getMessage["ok"]) {
        if (getMessage["result"]["update_message"] != null) {
          msg["message"] = getMessage["result"]["update_message"];
        }

        if (getMessage["result"]["update_channel_post"] != null) {
          msg["message"] = getMessage["result"]["update_channel_post"];
        }
      }
    } catch (e) {
      print(e);
    }
    msg["message_id"] = update.raw["message_id"];
    msg["from"] = from;
    msg["chat"] = chat;
  }

  msg["chat_instance"] = update.raw["chat_instance"];
  msg["data"] = utf8.decode(base64.decode(update.raw["payload"]["data"]));
  return msg;
}
