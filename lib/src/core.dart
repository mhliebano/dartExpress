import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dear/src/config.dart';
import 'package:dear/src/cors.dart';
import 'package:dear/src/enums.dart';
import 'package:dear/src/request.dart';
import 'package:dear/src/routerInternal.dart';
import 'package:dear/src/routes.dart';

import 'filedetails.dart';

class Dear {
  String _securityPhrase = "";
  Duration? _securityTokenDuration = Duration(minutes: 10);

  ConfigServer? _conf;
  Cors? _cors;
  bool _useCors = false;
  bool _useStatic = false;
  bool _useSecurity = false;
  bool _useHttps = false;
  ConfigHttps? _configHttps;

  Dear({required ConfigServer conf}) {
    _conf = conf;
  }

  void run() {
    if (!Directory("./tmp").existsSync()) {
      Directory("./tmp/files").createSync(recursive: true);
    }
    runZonedGuarded(() async {
      print("Server run at ${_conf!.ip}:${_conf!.port}");
      late HttpServer server;
      if (_useHttps) {
        SecurityContext context = SecurityContext()
          ..useCertificateChain(_configHttps!.chain)
          ..usePrivateKey(_configHttps!.key, password: _configHttps!.password);
        server =
            await HttpServer.bindSecure(_conf!.ip == "*" ? InternetAddress.anyIPv4 : _conf!.ip, _conf!.port, context);
      } else {
        server = await HttpServer.bind(_conf!.ip == "*" ? InternetAddress.anyIPv4 : _conf!.ip, _conf!.port);
      }
      server.listen((request) async {
        if (_useCors) {
          if (request.method == 'OPTIONS') {
            _cors!.responseCORS(request.response);
            return;
          }
          request.response.headers.set("Access-Control-Allow-Origin", "*");
        }
        RouteInternal? handleroute = await _getRoute(request.method, request.uri);
        IncomingRequest reqs = IncomingRequest.fromHttpRequest(req: request, securePhrase: _securityPhrase);
        if (handleroute.isStatic) {
          if (handleroute.is404) {
            request.response.headers.contentType = ContentType.html;
            request.response.statusCode = HttpStatus.notFound;
            request.response.write(
                '<html><head></head><body><h2>404 Not Found </h2><h3>The page ${handleroute.path} no found in this server</h3><h5>DartExpress by mmsystems</h5></body></html>');
            request.response.close();
          } else {
            if (request.contentLength > 0) {
              await request.listen((e) async {
                await _parseBody(e: e, contentType: request.headers.contentType!).then((value) {
                  reqs.body = value;
                });
              }, onDone: () => print("ok")).asFuture();
            }
            request.response.headers.set(HttpHeaders.contentTypeHeader, handleroute.regex);
            request.response.statusCode = HttpStatus.ok;
            File file = File("./www${handleroute.path}");
            file.openRead().pipe(reqs.response).catchError((e) {}).whenComplete(() => reqs.response.close());
          }
        } else {
          if (handleroute.is404) {
            request.response.headers.contentType = ContentType.json;
            request.response.statusCode = HttpStatus.notFound;
            request.response.write('{"status":404, "response":"Not found"}');
            request.response.close();
          } else {
            if (request.contentLength > 0) {
              await request.listen((e) async {
                await _parseBody(e: e, contentType: request.headers.contentType!).then((value) {
                  reqs.body = value;
                });
              }, onDone: () => print("ok")).asFuture();
            }
            if (handleroute.segmentsData.isNotEmpty) {
              reqs.segmentsData = handleroute.segmentsData;
            }
            if (handleroute.useSecurity && _useSecurity) {
              String? auth = request.headers["authorization"] == null ? null : request.headers["authorization"]!.first;
              Map<String, dynamic> checkStatus = _checkToken(auth);
              reqs.payload = checkStatus["payload"];
              reqs.securityStatus = checkStatus["tokenStatus"];

              if (checkStatus["tokenStatus"] != securityTokenStatus.STATUS_OK) {
                request.response.headers.contentType = ContentType.json;
                request.response.statusCode = HttpStatus.forbidden;
                request.response.write('{"status":403, "response":${checkStatus["tokenStatus"]}}');
                request.response.close();
                return;
              }
            }
            handleroute.callback(reqs);
          }
        }
      }, onDone: () {
        print("Listo cerrando el stream");
      }, onError: (e, s) {
        print("Salto un error");
      });
    }, (error, stack) => print("$error, $stack"));
  }

  void route(Route route) {
    try {
      RoutesList.registerRoute(route);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  void useCors(bool use, {options}) {
    _useCors = use;
    if (use) {
      _cors = Cors();
    }
  }

  void useStatic(bool use, {options}) {
    _useStatic = use;
  }

  void useSecurity(bool use, {String? secretFrase}) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    _useSecurity = use;
    if (secretFrase == null) {
      _securityPhrase =
          String.fromCharCodes(Iterable.generate(15, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    } else {
      _securityPhrase = secretFrase;
    }
  }

  void useHTTPS(bool use, {ConfigHttps? config}) {
    _useHttps = use;
    if (use) {
      _configHttps = config;
    }
  }

  Future<RouteInternal> _getRoute(String method, Uri uri) {
    return RoutesList.isRouterRegister(method, uri.path, _useStatic);
  }

  Future<Map<String, dynamic>> _parseBody({required Uint8List e, required ContentType contentType}) async {
    Map<String, dynamic> body = {};
    switch (contentType.mimeType) {
      case "application/x-www-form-urlencoded":
        String content = utf8.decode(e);
        List<String> params = content.split("&");
        params.forEach((element) {
          List key_val = element.split("=");
          body[key_val.first] = key_val.last;
        });
        break;
      case "application/json":
        body = json.decode(utf8.decode(e));
        break;
      case "multipart/form-data":
        String? boundary = contentType.parameters["boundary"];
        String rq = String.fromCharCodes(e);
        List<RegExpMatch> fields = RegExp("(--$boundary)", dotAll: true, multiLine: true).allMatches(rq).toList();
        for (var i = 0; i < fields.length - 1; i++) {
          int star = 0;
          int end = 0;
          if (i == 0) {
            star = fields[0].end + 1;
            end = fields[1].start - 1;
          } else {
            star = fields[i].end + 1;
            end = fields[i + 1].start - 1;
          }
          String x = rq.substring(star, end).trim();
          RegExpMatch? dis =
              RegExp("^Content-Disposition: form-data.+?\n", dotAll: true, multiLine: true).firstMatch(x);
          if (dis != null) {
            String disposition = x.substring(dis.start, dis.end).trim();
            RegExpMatch? field = RegExp(r'name="(\w.+?)"', dotAll: false, multiLine: false).firstMatch(disposition);
            String fieldName = field!.group(1)!;

            if (disposition.contains("filename")) {
              RegExpMatch? fileName =
                  RegExp(r'filename="(\w.+?)"', dotAll: false, multiLine: false).firstMatch(disposition);
              RegExpMatch? detailsfile = RegExp(r"^(?:Content-Type:)(.+)", multiLine: true).firstMatch(x);
              String? typefile = detailsfile?.group(0);
              int len = x.substring(detailsfile!.end + 4, x.length).length;
              String tmpname = "tmp${DateTime.now().millisecondsSinceEpoch}";
              File tmp = File("./tmp/files/${tmpname}");
              tmp.writeAsBytes(x.substring(detailsfile.end + 4, x.length).codeUnits);
              body[fieldName] = FileDetails(
                  fieldName: fieldName,
                  fileName: fileName!.group(1)!,
                  fileSize: len,
                  fileType: typefile.toString(),
                  tmpName: tmpname);
            } else {
              String data = x.substring((dis.end + 1), (x.length)).trim();
              body[fieldName] = data;
            }
          }
        }
        break;
    }

    return body;
  }

  Map<String, dynamic> _checkToken(String? auth) {
    securityTokenStatus st = securityTokenStatus.STATUS_OK;
    Map<String, dynamic> payload = {};
    if (auth != null) {
      List<String> pieces = auth.split(" ");
      if (pieces.length == 2) {
        if (pieces[0] == "Bearer") {
          List<String> fragToken = pieces[1].split(".");
          if (fragToken.length == 3) {
            final Base64Decoder base64decoder = base64.decoder;
            String encodedHeader = fragToken[0];
            String encodedFrase = fragToken[2];
            String encodedPayload = fragToken[1];
            int dif = 0;
            if (encodedHeader.length % 4 != 0) {
              dif = 4 - (encodedHeader.length % 4);
              encodedHeader = encodedHeader.padRight(encodedHeader.length + dif, "=");
            }
            if (encodedFrase.length % 4 != 0) {
              dif = 4 - (encodedFrase.length % 4);
              encodedFrase = encodedFrase.padRight(encodedFrase.length + dif, "=");
            }
            if (encodedPayload.length % 4 != 0) {
              dif = 4 - (encodedPayload.length % 4);
              encodedPayload = encodedPayload.padRight(encodedPayload.length + dif, "=");
            }
            String header = utf8.decode(base64decoder.convert(encodedHeader));
            String secret = utf8.decode(base64decoder.convert(encodedFrase));
            payload = json.decode(utf8.decode(base64decoder.convert(encodedPayload)));
            if (header.split(".")[0] != "DTS") {
              st = securityTokenStatus.TOKEN_NOT_VALID;
            } else {
              int diference = DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(int.parse(header.split(".")[1])))
                  .inMinutes;
              if (diference > _securityTokenDuration!.inMinutes) {
                st = securityTokenStatus.TOKEN_EXPIRED;
              } else {
                if (secret != _securityPhrase) {
                  st = securityTokenStatus.TOKEN_NOT_VALID;
                }
              }
            }
          } else {
            st = securityTokenStatus.TOKEN_NOT_VALID;
          }
        } else {
          st = securityTokenStatus.TOKEN_NOT_VALID;
        }
      } else {
        st = securityTokenStatus.TOKEN_NOT_VALID;
      }
    } else {
      st = securityTokenStatus.TOKEN_NOT_VALID;
    }
    return {"tokenStatus": st, "payload": payload};
  }
}
