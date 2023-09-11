class ConfigServer {
  String ip;
  int port;
  bool useDebug;
  ConfigServer({this.ip = "127.0.0.1", this.port = 9090, this.useDebug = true});
}

class ConfigHttps {
  String chain;
  String key;
  String password = "";

  ConfigHttps({required this.chain, required this.key, this.password = ""});
}

class ConfigSecurity {
  Duration securityTokenDuration;
  String securityPhrase;

  ConfigSecurity(
      {this.securityTokenDuration = const Duration(minutes: 10),
      this.securityPhrase = ""});
}

class ConfigCORS {}
