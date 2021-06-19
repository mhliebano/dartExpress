class Route {
  String route = "";
  Function function = () {};
  bool security;

  Route({required this.route, required this.function, this.security: false});
}

abstract class RoutesList {
  static Map<String, List<Route>> routes = {"GET": [], "POST": []};

  static void useGET(Route r) {
    routes["GET"]?.add(r);
  }

  static void usePOST(Route r) {
    routes["POST"]?.add(r);
  }
}
