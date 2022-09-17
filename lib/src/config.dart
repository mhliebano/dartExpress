class ConfigServer {
  String? ip;
  int port;
  bool useSecure;

  ConfigServer({this.ip, this.port = 9090, this.useSecure = false});
}

class ConfigHttps {
  String chain;
  String key;
  String password = "";

  ConfigHttps({required this.chain, required this.key, this.password = ""});
}

class ConfigCORS {}
