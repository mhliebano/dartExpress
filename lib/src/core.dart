import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'filedetails.dart';
import 'request.dart';
import 'routes.dart';
import 'securitytoken.dart';

import 'routeserver.dart';

class DartExpress {
  Map<String, List<RoutesServer>> _routes = {"POST": [], "GET": []};
  bool _security = false;
  String _phrase = "";
  Duration? _tokenLive;

  void run({
    String? ip,
    int port: 9090,
    String? vhost,
    ConfigSecure? useSecure: null,
  }) {
    if (!Directory("./tmp").existsSync()) {
      Directory("./tmp/files").createSync(recursive: true);
      Directory("./tmp/tokens").createSync(recursive: true);
    }
    runZonedGuarded(() async {
      print(
          "Server run at ${ip == null ? "*" : ip}:$port ${vhost == null ? "" : "(with $vhost)"}");
      HttpServer server;
      if (useSecure == null) {
        server = await HttpServer.bind(
            ip == null ? InternetAddress.anyIPv4 : ip, port);
      } else {
        String chain = useSecure.pathToChain;
        String key = useSecure.pathToKey;
        SecurityContext context = SecurityContext()
          ..useCertificateChain(chain)
          ..usePrivateKey(key, password: useSecure.password);
        server = await HttpServer.bindSecure(
            ip == null ? InternetAddress.anyIPv4 : ip, port, context);
      }
      server.listen((HttpRequest req) async {
        RoutesServer? rs = _getRoute(req.method, req.uri);
        HttpResponse resp = req.response;
        Request reqs = Request.fromHttpRequest(req: req);
        print(
            "Request entrante ${req.requestedUri.hasAuthority}, ${req.requestedUri.authority}, ${req.requestedUri.host}");
        if (req.requestedUri.hasAuthority) {
          if (vhost != null) {
            if (req.requestedUri.host != vhost) {
              resp.headers.contentType = ContentType.json;
              resp.statusCode = HttpStatus.notFound;
              resp.write('{"status":404, "response":"Not found"}');
              resp.close();
              return;
            }
          }
        } else {
          resp.headers.contentType = ContentType.json;
          resp.statusCode = HttpStatus.notFound;
          resp.write('{"status":404, "response":"Not found"}');
          resp.close();
          return;
        }
        List bd = [];
        if (rs != null) {
          rs.security
              ? reqs.securityStatus =
                  _checkSecurity(req.headers["authorization"])
              : null;
          if (req.contentLength > 0) {
            String type = req.headers.contentType!.mimeType;
            String ct = req.headers.contentType.toString();
            await req.listen((e) async {
              await _parseBody(type: type, e: e, contentType: ct)
                  .then((value) => bd = value);
            }).asFuture();
            // print("ready");
            // print(bd);
          }
          reqs.parametersRequest(
              body: bd.isEmpty ? <String, dynamic>{} : bd[0],
              files: bd.isEmpty ? <FileDetails>[] : bd[1],
              route: rs.parametersRoute);
          await rs.function(reqs, resp);
        } else {
          resp.headers.contentType = ContentType.json;
          resp.statusCode = HttpStatus.notFound;
          resp.write('{"status":404, "response":"Not found"}');
        }

        resp.close();
      });
    }, (e, s) => print("$e $s"));
  }

  securityTokenStatus _checkSecurity(tokenclient) {
    if (_security) {
      if (tokenclient != null) {
        //_dsWT
        //print(tokenclient);
        if (tokenclient.first.startsWith("_dsWT")) {
          File tmpT = File("./tmp/tokens/${tokenclient.first}");
          if (tmpT.existsSync()) {
            String datatoken = tmpT.readAsStringSync();
            if (DateTime.now().millisecondsSinceEpoch >
                int.parse(datatoken.split(";")[1])) {
              tmpT.deleteSync();
              return securityTokenStatus.TOKEN_EXPIRED;
            } else {
              return securityTokenStatus.STATUS_OK;
            }
          } else {
            return securityTokenStatus.TOKEN_NOT_EXIST;
          }
        } else {
          return securityTokenStatus.TOKEN_NOT_VALID;
        }
      } else {
        return securityTokenStatus.AUTHORIZATION_HEADER_REQUIRED;
      }
    } else {
      throw ({"code": "009", "description": "security token is disabled"});
    }
  }

  RoutesServer? _getRoute(String method, Uri uri) {
    RoutesServer? rsr = null;
    List<RoutesServer> rs = _routes[method]!
        .where((element) => RegExp(element.regexp).hasMatch(uri.path))
        .toList();
    rs.forEach((element) {
      if (uri.pathSegments.length - 1 == element.pathlen) {
        rsr = element;
        if (rsr!.parametersRouteList.isNotEmpty) {
          rsr!.parametersRouteList.asMap().forEach((i, element) {
            rsr!.parametersRoute[element] =
                uri.pathSegments[i + (rsr!.basePathlen)];
          });
        }
      }
    });
    return rsr;
  }

  Future<List> _parseBody(
      {required String type,
      required Uint8List e,
      required String contentType}) async {
    Map<String, dynamic> bodyParams = {};
    List<FileDetails> bodyParamsFile = [];
    List<dynamic> result = [];
    // {"body": {}, "files": []};
    if (type.compareTo("application/x-www-form-urlencoded") == 0) {
      String content = utf8.decode(e);
      List<String> params = content.split("&");
      params.forEach((element) {
        List key_val = element.split("=");
        bodyParams[key_val.first] = key_val.last;
      });
    } else if (type.compareTo("application/json") == 0) {
      bodyParams = json.decode(utf8.decode(e));
    } else if (type.compareTo("multipart/form-data") == 0) {
      String rq = String.fromCharCodes(e);

      String boundary =
          RegExp(r"boundary=(.*)$").stringMatch(contentType)!.split("=")[1];
      List<RegExpMatch> fields =
          RegExp("--$boundary", dotAll: true, multiLine: true)
              .allMatches(rq)
              .toList();

      for (int i = 0; i < fields.length - 1; i++) {
        String block =
            rq.substring(fields[i].end + 34, fields[i + 1].start - 1);
        List<RegExpMatch> fieldsdata =
            RegExp(r'(?:name=\")(.+?)(?:\")').allMatches(block).toList();

        if (fieldsdata.length > 1) {
          int l = fieldsdata[0].group(0)!.length - 1;
          String fieldname =
              fieldsdata[0].group(0)!.substring(6, l).trim().toString();
          l = fieldsdata[1].group(0)!.length - 1;
          String filename =
              fieldsdata[1].group(0)!.substring(6, l).trim().toString();

          RegExpMatch? detailsfile =
              RegExp(r"^(?:Content-Type:)(.+)", multiLine: true)
                  .firstMatch(block);

          String? typefile = detailsfile?.group(0);
          int len = block.substring(detailsfile!.end + 4, block.length).length;
          String tmpname = "tmp${DateTime.now().millisecondsSinceEpoch}";
          File tmp = File("./tmp/files/${tmpname}");
          tmp.writeAsBytes(
              block.substring(detailsfile.end + 4, block.length).codeUnits);

          bodyParamsFile.add(FileDetails(
              fieldName: fieldname,
              fileName: filename,
              fileSize: len,
              fileType: typefile.toString(),
              tmpName: tmpname));
        } else {
          int st = fields[i].end;
          int sn = fields[i + 1].start;
          int l = fieldsdata[0].group(0)!.length - 1;
          bodyParams[fieldsdata[0]
              .group(0)!
              .substring(6, l)
              .trim()
              .toString()] = rq.substring(st + fieldsdata[0].end + 38, sn - 1);
        }
      }
    }
    //print(bodyParams);
    result.add(bodyParams);
    result.add(bodyParamsFile);
    return result;
  }

  bool _verifyRoute(RoutesServer r, String method) {
    bool rs = true;
    _routes[method]!.forEach((element) {
      if (element.routeBase.compareTo(r.routeBase) == 0 &&
          element.parametersRouteList.length == r.parametersRouteList.length) {
        rs = false;
      }
    });
    return rs;
  }

  void useList(Map<String, List<Route>> list) {
    list["GET"]?.forEach((element) {
      useGet(
          route: element.route,
          function: element.function,
          security: element.security);
    });
    list["POST"]?.forEach((element) {
      usePost(
          route: element.route,
          function: element.function,
          security: element.security);
    });
  }

  void useGet(
      {required String route, required Function function, security: false}) {
    RoutesServer _r =
        RoutesServer(function: function, route: route, security: security);
    _verifyRoute(_r, "GET")
        ? _routes["GET"]!.add(_r)
        : throw ({"code": "004", "description": "route already defined"});
  }

  void usePost(
      {required String route, required Function function, security: false}) {
    RoutesServer _r =
        RoutesServer(function: function, route: route, security: security);
    _verifyRoute(_r, "POST")
        ? _routes["POST"]!.add(_r)
        : throw ({"code": "004", "description": "route already defined"});
  }

  void useSecurityToken({required String phraseSecret, Duration? timeLive}) {
    _security = true;
    _phrase = phraseSecret;
    if (timeLive != null) {
      _tokenLive = timeLive;
    }
  }

  String newSecurityToken() {
    if (!_security) {
      throw ({"code": "008", "description": "Security Token is disabled"});
    }
    SecurityToken t;
    if (_tokenLive != null) {
      t = SecurityToken(secretKey: _phrase, expireTime: _tokenLive);
    } else {
      t = SecurityToken(secretKey: _phrase);
    }
    File("./tmp/tokens/${t.token}").writeAsStringSync(
        "${t.init.millisecondsSinceEpoch.toString()};${t.exprire.millisecondsSinceEpoch.toString()}");
    return t.token;
  }
}

class ConfigSecure {
  String? _pathToChain;
  String? _pathToKey;
  String? _password;
  String get pathToChain => _pathToChain!;
  String get pathToKey => _pathToKey!;
  String get password => _password!;

  ConfigSecure(
      {required String pathToChain,
      required String pathToKey,
      required String password}) {
    _pathToChain = pathToChain;
    _pathToKey = pathToKey;
    _password = password;
  }

  factory ConfigSecure.none() {
    return ConfigSecure(pathToChain: "", pathToKey: "", password: "");
  }
}

//Cors
//Access-Control-Allow-Origin: ¿qué origen está permitido?
// Access-Control-Allow-Credentials: ¿también se aceptan solicitudes cuando el modo de credenciales es incluir (include)?
// Access-Control-Allow-Headers: ¿qué cabeceras pueden utilizarse?
// Access-Control-Allow-Methods: ¿qué métodos de petición HTTP están permitidos?
// Access-Control-Expose-Headers: ¿qué cabeceras pueden mostrarse?
// Access-Control-Max-Age: ¿cuándo pierde su validez la solicitud preflight?
// Access-Control-Request-Headers: ¿qué header HTTP se indica en la solicitud preflight?
// Access-Control-Request-Method: ¿qué método de petición HTTP se indica en la solicitud preflight?
// Origin:
