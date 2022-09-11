class ConfigServer {
  String? ip;
  int port;
  bool useSecure;

  ConfigServer({this.ip, this.port = 9090, this.useSecure = false});
}

class ConfigCORS {}
