import 'dart:io';
import 'package:dart_express/dartExpress.dart';

//Abstract Calss inhereted from RouteList
abstract class Test extends RoutesList {
  //Implement a method to expose routes
  static Map<String, List<Route>> getRoute() {
    //Enpoint public
    RoutesList.useGET(
      Route(
        route: "/api/route/",
        function: (Request req, HttpResponse res) {
          res.statusCode = HttpStatus.ok;
          res.write("<h1>From Class Test</h1>");
        },
      ),
    );
    //Endpoint public
    RoutesList.useGET(
      Route(
        route: "/api/route/v2/",
        function: (Request req, HttpResponse res) {
          res.statusCode = HttpStatus.ok;
          res.headers.contentType = ContentType.json;
          res.write('{"code":9090,"message":"Nice!!! are you agree?"}');
        },
      ),
    );

    return RoutesList.routes;
  }
}
