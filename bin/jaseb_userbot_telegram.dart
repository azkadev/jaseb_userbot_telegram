// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unused_import

import "dart:io";

import "package:galaxeus_lib/galaxeus_lib.dart";
import "package:jaseb_userbot_telegram/jaseb_userbot_telegram.dart";
import "package:telegram_client/telegram_client.dart";
import "package:path/path.dart" as path;

String get getFormatLibrary {
  if (Platform.isAndroid || Platform.isLinux) {
    return "so";
  } else if (Platform.isIOS || Platform.isMacOS) {
    return "dylib";
  } else {
    return "dll";
  }
}

String ask({
  required String question,
}) {
  while (true) {
    stdout.write(question);
    String? res = stdin.readLineSync();
    if (res != null && res.isNotEmpty) {
      return res;
    }
  }
}

void main(List<String> arguments) async {
  Directory directory_current = Directory.current;
  Directory telegram_directory = Directory(path.join(directory_current.path, "tg_database"));

  List<String> name_clients = [
    "azka",
  ];

  /// telegram database
  int api_id = int.tryParse(Platform.environment["api_id"] ?? "0") ?? 0; // telegram api id https://my.telegram.org/
  String api_hash = Platform.environment["api_hash"] ?? ""; // telegram api hash https://my.telegram.org/
  int owner_chat_id = int.tryParse(Platform.environment["owner_chat_id"] ?? "0") ?? 0; // owner telegram chat id
  Tdlib tg = Tdlib(
    pathTdl: "libtdjson.${getFormatLibrary}",
    clientOption: {
      'api_id': api_id,
      'api_hash': api_hash,
    },
    invokeTimeOut: Duration(minutes: 10),
    delayInvoke: Duration(milliseconds: 10),
  );

  JasebUserbotTelegram jaseb_userbot_telegram = JasebUserbotTelegram(
    tg: tg,
    telegram_directory: telegram_directory,
    owner_chat_id: owner_chat_id,
    name_clients: name_clients,
  );

  await jaseb_userbot_telegram.userbot(
    onAuthState: (int client_id, String name_client, AuthorizationStateType authorizationStateType) async {
      ///
      if (authorizationStateType == AuthorizationStateType.phone_number) {
        String phone_number = ask(question: "Phone Number: ");
        phone_number = phone_number.replaceAll(RegExp(r"(\+|([ ]+))", caseSensitive: false), "");
        await tg.request(
          "setAuthenticationPhoneNumber",
          parameters: {
            "phone_number": phone_number,
          },
          clientId: client_id, // add this if your project more one client
        );
      }

      if (authorizationStateType == AuthorizationStateType.code) {
        String code = ask(question: "Code: ");
        await tg.request(
          "checkAuthenticationCode",
          parameters: {
            "code": code,
          },
          clientId: client_id, // add this if your project more one client
        );
      }
      if (authorizationStateType == AuthorizationStateType.password) {
        String password = ask(question: "Password: ");
        await tg.request(
          "checkAuthenticationPassword",
          parameters: {
            "password": password,
          },
          clientId: client_id, // add this if your project more one client
        );
      }
    },
  );
}
