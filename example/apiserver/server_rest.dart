import 'dart:convert';
import 'dart:io';
import 'package:dear/dear.dart';

void main(List<String> args) {
  try {
    ConfigServer config = ConfigServer();
    Dear server = Dear(conf: config);
    server.useCors(true);
    server.useSecurity(
      true,
      security_conf: ConfigSecurity(
          securityPhrase: "MyT0k3n!Secret",
          securityTokenDuration: Duration(minutes: 1)),
    );

    //server.useHTTPS(true, config: ConfigHttps(chain: "chain", key: "key"));
    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/single/',
        callback: (IncomingRequest request) {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
              '{"status":200, "response":"Ok single api endpoint","data":"{}"}');
          request.response.close();
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/single/:id/',
        callback: (IncomingRequest request) {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
              '{"status":200, "response":"Ok single api endpoint with patameter","data":"${request.segmentsData["id"]}"}');
          request.response.close();
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/all/',
        callback: (IncomingRequest request) async {
          File dataBrute = File("./datos.json");
          String data = await dataBrute.readAsString();
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
              '{"status":200, "response":"Data from Api","data":${data}}');
          request.response.close();
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/get/:id/',
        callback: (IncomingRequest request) async {
          final dataRequestUrl = request.segmentsData;
          File dataBrute = File("./datos.json");
          final data = json.decode(await dataBrute.readAsString());
          final lang = data.firstWhere((element) {
            return element["id"].toString() == dataRequestUrl["id"].toString();
          }, orElse: () => {});
          request.response.headers.contentType = ContentType.json;
          if (lang.isNotEmpty) {
            request.response.statusCode = HttpStatus.ok;
            request.response.write(
                '{"status":200, "response":"Data from Api","data":${lang}}');
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response
                .write('{"status":404, "response":"Data not found","data":{}}');
          }
          request.response.close();
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.POST,
        path: '/api/test/set/',
        callback: (IncomingRequest request) async {
          File dataBrute = File("./datos.json");
          final data = json.decode(await dataBrute.readAsString());
          data.add({
            "name": request.body["name"],
            "skill": request.body["skill"],
            "id": data.length + 1
          });
          final saveData = json.encode(data);
          dataBrute.writeAsString(saveData);
          request.responseJSON(
              {"code": 200, "message": "Actualizada la lista"}, HttpStatus.ok);
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.PUT,
        path: '/api/test/put/:id/',
        callback: (IncomingRequest request) async {
          final dataRequestUrl = request.segmentsData;
          final dataBody = request.body;
          File dataBrute = File("./datos.json");
          List data = json.decode(await dataBrute.readAsString());
          int langIndex = data.indexWhere((element) {
            return element["id"].toString() == dataRequestUrl["id"].toString();
          });

          if (langIndex != -1) {
            data[langIndex] = {
              "name": dataBody["name"],
              "skill": dataBody["skill"],
              "id": data[langIndex]["id"]
            };
            final saveData = json.encode(data);
            dataBrute.writeAsString(saveData);
            request.responseJSON(
                {"code": 200, "message": "Actualizado el registro"},
                HttpStatus.ok);
          } else {
            request.responseJSON(
                {"code": 408, "message": "El Registro no existe"},
                HttpStatus.badRequest);
          }
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.DELETE,
        path: '/api/test/delete/:id/',
        callback: (IncomingRequest request) async {
          final dataRequestUrl = request.segmentsData;
          File dataBrute = File("./datos.json");
          List data = json.decode(await dataBrute.readAsString());
          int langIndex = data.indexWhere((element) {
            return element["id"].toString() == dataRequestUrl["id"].toString();
          });

          if (langIndex != -1) {
            data.removeAt(langIndex);
            final saveData = json.encode(data);
            dataBrute.writeAsString(saveData);
            request.responseJSON(
                {"code": 200, "message": "Se ha eliminado el registro"},
                HttpStatus.ok);
          } else {
            request.responseJSON(
                {"code": 408, "message": "El Registro no existe"},
                HttpStatus.badRequest);
          }
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.POST,
        path: '/api/test/auth/',
        callback: (IncomingRequest request) async {
          if (request.body["user"] == "admin" &&
              request.body["pass"] == "admin") {
            String token = request
                .newSecurityToken(payload: {"user": "admin", "id": 9999});
            request.responseJSON({
              "code": 200,
              "message": "login success",
              "data": {"token": token}
            }, HttpStatus.ok);
          } else {
            request.responseJSON({
              "code": 201,
              "message": "login fail",
              "data": {"token": ""}
            }, HttpStatus.notFound);
          }
        },
      ),
    );

    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/private/',
        security: true,
        callback: (IncomingRequest request) async {
          request.responseJSON({
            "code": 200,
            "message": "you're welcome",
            "data": request.payload,
          }, HttpStatus.ok);
        },
      ),
    );

    server.run();
  } catch (e) {
    print("=> Fail $e");
  }
}
