import 'package:dear/dear.dart';

void main(List<String> args) {
  Dear server = Dear(conf: ConfigServer());
  server.useStatic(true);
  server.run();
}
