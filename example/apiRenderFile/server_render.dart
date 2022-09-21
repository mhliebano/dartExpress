import 'package:dart_express/dart_express.dart';

void main(List<String> args) {
  try {
    ConfigServer config = ConfigServer();
    DartExpress server = DartExpress(conf: config);
    server.useCors(true);
    server.useSecurity(true, secretFrase: "MyT0k3n!Secret");

    //server.useHTTPS(true, config: ConfigHttps(chain: "chain", key: "key"));
    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/render/:action/',
        callback: (IncomingRequest request) {
          Map<String, dynamic> dataSegment = request.segmentsData;
          String alert = "<div style='color:red'>No actions</div>";
          late String action;
          if (dataSegment["action"] == "1") {
            alert = "<div style='color:red;background:green'>1 actions</div>";
            action = "0";
          } else {
            action = "1";
          }
          request
              .renderFile("/test.html", {"name": "Miguel", "company": "MMSytems", "message": alert, "action": action});
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.POST,
        path: '/api/test/data/',
        callback: (IncomingRequest request) {
          request.renderFile("/test2.html", request.body);
        },
      ),
    );

    server.run();
  } catch (e) {
    print(e);
  }
}
