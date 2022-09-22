import 'package:dartExpress/dartExpress.dart';

void main(List<String> args) {
  DartExpress server = DartExpress(conf: ConfigServer());
  server.useStatic(true);
  server.run();
}
