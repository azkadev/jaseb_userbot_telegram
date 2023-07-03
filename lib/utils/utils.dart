int parserBotUserIdFromToken(dynamic tokenBot) {
  try {
    return int.parse(tokenBot.split(":")[0]);
  } catch (e) {
    return 0;
  }
}
