import 'package:dart_express/dartExpress.dart';

void main(List<String> args) {
  DartExpress server = DartExpress(conf: ConfigServer());
  server.useStatic(true);
  server.run();
}
