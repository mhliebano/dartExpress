import 'dart:io';
import 'package:dart_express/dartExpress.dart';

void main(List<String> args) {
  try {
    ConfigServer config = ConfigServer();
    DartExpress server = DartExpress(conf: config);
    server.useCors(true);
    server.useStatic(true);
    server.useSecurity(true, secretFrase: "MyT0k3n!Secret");
    //server.useHTTPS(true, config: ConfigHttps(chain: "chain", key: "key"));
    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/test/cool/render/',
        callback: (IncomingRequest request) {
          print(request.params);
          request.responseFile("/hello.html", headersFileType.HTML, {});
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/test/cool/image/',
        callback: (IncomingRequest request) {
          print(request.params);
          request.responseFile("/img/dart.png", headersFileType.IMAGE_PNG, {});
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/test/render/',
        callback: (IncomingRequest request) {
          print(request.params);
          request.responseFile("/src/hello.html", headersFileType.HTML, {});
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/test/cool/',
        callback: (IncomingRequest request) {
          request.responseJSON({"code": 200, "message": "Nice tool in te path test/cool"}, HttpStatus.ok);
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/test/nice/:data1/:data3/',
        callback: (IncomingRequest request) {
          print(request.body);
          print(request.segmentsData);
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
              '{"status":200, "response":"Ok test/nice with 2 parameters","data":"${request.segmentsData["data1"]} ${request.segmentsData["data3"]}"}');
          request.response.close();
        },
        security: true,
      ),
    );

    server.route(
      Route(
        verb: routeVerb.POST,
        path: '/test/posting/',
        callback: (IncomingRequest request) {
          print("route => ${request.body}");
          print(request.body["file"].fileName);
          request.response.statusCode = HttpStatus.ok;
          request.response.write('{"status":200, "response":"Ok post it"}');
          request.response.close();
        },
      ),
    );

    //enable securty tokens
    // server.useSecurityToken(phraseSecret: "phraseSecret!");

    // //List endpoints
    // server.useList(Test.getRoute());

    // //Simple endpoint GET return html
    // server.useGet(
    //     route: "/api/test/",
    //     function: (Request req, HttpResponse response) {
    //       response.statusCode = HttpStatus.ok;
    //       response.headers.contentType = ContentType.html;
    //       response.writeAll(["<h1>", "Respuesta", "</h1>"]);
    //     });

    // //Simple endpoint GET return html file
    // server.useGet(
    //     route: "/api/test/file/",
    //     function: (Request req, HttpResponse response) async {
    //       response.statusCode = HttpStatus.ok;
    //       response.headers.contentType = ContentType.html;
    //       Uint8List f = File("./index.html").readAsBytesSync();
    //       response.write(String.fromCharCodes(f));
    //     });

    // //Simple endpoint GET protected by securty tokens
    // server.useGet(
    //     route: "/api/test/private/",
    //     security: true,
    //     function: (Request req, HttpResponse response) async {
    //       if (req.securityStatus == securityTokenStatus.STATUS_OK) {
    //         response.statusCode = HttpStatus.ok;
    //         response.headers.contentType = ContentType.html;
    //         response.write("<h2>Hello open secret</h2>");
    //       } else {
    //         response.statusCode = HttpStatus.forbidden;
    //         response.headers.contentType = ContentType.html;
    //         response.write("<h2>fail request by ${req.securityStatus}</h2>");
    //       }
    //     });

    // //Simple endpoint POST recive data form body form
    // server.usePost(
    //     route: "/api/test/auth/",
    //     function: (Request req, HttpResponse res) {
    //       print(req.bodyParams["user"]);
    //       print(req.bodyParams["pass"]);
    //       if (req.bodyParams["user"] == "admin" &&
    //           req.bodyParams["pass"] == "dart2.12") {
    //         String token = server.newSecurityToken();
    //         res.statusCode = HttpStatus.ok;
    //         res.headers.contentType = ContentType.json;
    //         res.write('{"message":"welcome user dart","token":"$token"}');
    //       } else {
    //         res.statusCode = HttpStatus.ok;
    //         res.headers.contentType = ContentType.json;
    //         res.write('{"message":"your credentials is broken","token":""}');
    //       }
    //     });
    //Default run server 127.0.0.1:9090
    // server.run(
    //     vhost: "satus.mmsystems.xyz",
    //     useSecure: ConfigSecure(
    //         pathToChain: "/etc/letsencrypt/archive/mmsystems.xyz/fullchain1.pem",
    //         pathToKey: "/etc/letsencrypt/archive/mmsystems.xyz/privkey1.pem",
    //         password: ""));
    server.run();
  } catch (e) {
    print(e);
  }
}
