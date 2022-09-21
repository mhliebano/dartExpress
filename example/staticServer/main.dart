import 'package:dart_express/dart_express.dart';

void main(List<String> args) {
  DartExpress server = DartExpress(conf: ConfigServer());
  server.useStatic(true);
  server.run();
}
