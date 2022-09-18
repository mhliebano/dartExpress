class ConfigServer {
  String ip;
  int port;

  ConfigServer({this.ip = "127.0.0.1", this.port = 9090});
}

class ConfigHttps {
  String chain;
  String key;
  String password = "";

  ConfigHttps({required this.chain, required this.key, this.password = ""});
}

class ConfigCORS {}
