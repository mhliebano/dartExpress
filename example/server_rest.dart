import 'dart:io';
import 'dart:typed_data';

import 'package:dart_express/dartExpress.dart';

import 'test.dart';

void main(List<String> args) {
  DartExpress server = DartExpress();

  //enable securty tokens
  server.useSecurityToken(phraseSecret: "phraseSecret!");

  //List endpoints
  server.useList(Test.getRoute());

  //Simple endpoint GET return html
  server.useGet(
      route: "/api/test/",
      function: (Request req, HttpResponse response) {
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.html;
        response.writeAll(["<h1>", "Respuesta", "</h2>"]);
      });

  //Simple endpoint GET return html file
  server.useGet(
      route: "/api/test/file/",
      function: (Request req, HttpResponse response) async {
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.html;
        Uint8List f = File("./index.html").readAsBytesSync();
        response.write(String.fromCharCodes(f));
      });

  //Simple endpoint GET protected by securty tokens
  server.useGet(
      route: "/api/test/private/",
      security: true,
      function: (Request req, HttpResponse response) async {
        if (req.securityStatus == securityTokenStatus.STATUS_OK) {
          response.statusCode = HttpStatus.ok;
          response.headers.contentType = ContentType.html;
          response.write("<h2>Hello open secret</h2>");
        } else {
          response.statusCode = HttpStatus.forbidden;
          response.headers.contentType = ContentType.html;
          response.write("<h2>fail request by ${req.securityStatus}</h2>");
        }
      });

  //Simple endpoint POST recive data form body form
  server.usePost(
      route: "/api/test/auth/",
      function: (Request req, HttpResponse res) {
        print(req.bodyParams["user"]);
        print(req.bodyParams["pass"]);
        if (req.bodyParams["user"] == "admin" &&
            req.bodyParams["pass"] == "dart2.12") {
          String token = server.newSecurityToken();
          res.statusCode = HttpStatus.ok;
          res.headers.contentType = ContentType.json;
          res.write('{"message":"welcome user dart","token":"$token"}');
        } else {
          res.statusCode = HttpStatus.ok;
          res.headers.contentType = ContentType.json;
          res.write('{"message":"your credentials is broken","token":""}');
        }
      });
  //Default run server 127.0.0.1:9090
  server.run();
}
