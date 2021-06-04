class RoutesServer {
  String _route = "";
  List<String> _basepath = [];
  List<String> _parameterpath = [];
  String _routeBase = "/";
  String _regexp = "^\/";
  int _pathLen = 0;
  Function? _function;
  bool _security = false;
  Map<String, dynamic> parametersRoute = {};

  String get route => _route;
  String get routeBase => _routeBase;
  List<String> get parametersRouteList => _parameterpath;
  String get regexp => _regexp;
  int get pathlen => _pathLen;
  int get basePathlen => _basepath.length;
  Function get function => _function!;
  bool get security => _security;
  RoutesServer(
      {required Function function, required String route, security: false}) {
    _route = route;
    _validRoute();
    _pathLen = _basepath.length + _parameterpath.length;
    _function = function;
    security ? _security = true : _security = false;
  }

  void _validRoute() {
    bool variableseccion = false;
    if (!_route.startsWith("/")) {
      throw ({"code": "001", "description": "routes start with /"});
    }
    if (!_route.endsWith("/")) {
      throw ({"code": "002", "description": "routes end with /"});
    }
    List<String> _paths = _route.split("/");
    _paths.removeLast();
    _paths.removeAt(0);
    _paths.forEach((element) {
      bool isvar = element.startsWith(":") ? true : false;
      if (isvar && !variableseccion) {
        variableseccion = true;
      }
      if (!isvar && variableseccion) {
        throw ({"code": "003", "description": "routes bad config"});
      }
      isvar
          ? _parameterpath.add(element.split(":")[1])
          : _basepath.add(element);
      if (!isvar) {
        _routeBase += "$element/";
        _regexp += "$element\/";
      }
    });
    _parameterpath.isNotEmpty ? _regexp += "(.+?\/)\$" : _regexp += "\$";
  }
}
