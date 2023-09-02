import 'enums.dart';

class Route {
  final routeVerb verb;
  final String path;
  final Function callback;
  bool security;

  Route({required this.verb, required this.path, required this.callback, this.security = false});
}
