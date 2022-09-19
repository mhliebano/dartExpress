import 'dart:convert';
import 'dart:io';
import 'package:dart_express/dartExpress.dart';

class IncomingRequest {
  late HttpResponse _response;
  HttpResponse get response => _response;

  Map<String, dynamic> _body = {};
  Map<String, dynamic> get body => _body;
  set body(Map<String, dynamic> b) {
    _body = b;
  }

  Map<String, dynamic> _queryParams = {};
  Map<String, dynamic> get params => _queryParams;

  Map<String, dynamic> segmentsData = {};

  HttpHeaders? _headers;
  HttpConnectionInfo? _connection;
  securityTokenStatus securityStatus = securityTokenStatus.STATUS_OK;

  HttpHeaders? get headers => _headers;
  HttpConnectionInfo? get connectionInfo => _connection;

  late Uri _uri;

  String? _secretPhrase;

  IncomingRequest.fromHttpRequest({required HttpRequest req, String? securePhrase}) {
    _response = req.response;
    _headers = req.headers;
    _connection = req.connectionInfo;
    _uri = req.uri;
    _secretPhrase = securePhrase;
    if (req.uri.hasQuery) {
      _queryParams = req.uri.queryParameters;
    }
  }

  void responseJSON(Map<String, dynamic> response, int code) {
    _response.statusCode = code;
    _response.headers.contentType = ContentType.json;
    _response.write(jsonEncode(response));
    _response.close();
  }

  void responseFile(String file, headersFileType fileType, Map<String, dynamic> data) {
    print("en el sendifle ${_uri.path}");
    switch (fileType) {
      case headersFileType.HTML:
        _response.headers.set(HttpHeaders.contentTypeHeader, "text/html; charset=utf-8");
        break;
      case headersFileType.IMAGE_PNG:
        _response.headers.set(HttpHeaders.contentTypeHeader, "image/png; charset=utf-8");
        break;
      case headersFileType.IMAGE_JPG:
        _response.headers.set(HttpHeaders.contentTypeHeader, "image/jpg; charset=utf-8");
        break;
      case headersFileType.IMAGE_GIF:
        _response.headers.set(HttpHeaders.contentTypeHeader, "image/gif; charset=utf-8");
        break;
      case headersFileType.IMAGE_SVG:
        _response.headers.set(HttpHeaders.contentTypeHeader, "image/svg+xml; charset=utf-8");
        break;
      case headersFileType.JS:
        _response.headers.set(HttpHeaders.contentTypeHeader, "text/javascript; charset=utf-8");
        break;
      case headersFileType.CSS:
        _response.headers.set(HttpHeaders.contentTypeHeader, "text/css; charset=utf-8");
        break;
    }

    _response.statusCode = HttpStatus.ok;

    final sfile = File("./www${file}");
    if (sfile.existsSync()) {
      _response.statusCode = HttpStatus.ok;
      sfile.openRead().pipe(_response).catchError((e) {}).whenComplete(() => _response.close());
    } else {
      _response.statusCode = HttpStatus.notFound;
      _response.write(
          '<html><head></head><body><h2>404 Not Found</h2><h3>The page ${file} no found in this server</h3></body></html>');
      _response.close();
    }
  }

  String newSecurityToken({Map<String, dynamic>? payload}) {
    final Base64Encoder base64Encoder = base64.encoder;

    String header = 'DTS.${DateTime.now().millisecondsSinceEpoch}';
    String encodedHeader = base64Encoder.convert(header.codeUnits).replaceAll("=", '');
    Map<String, dynamic> pay;
    if (payload == null) {
      pay = {"payload": "no data"};
    } else {
      pay = payload;
    }
    final String encodedpayload = base64Encoder.convert(json.encode(pay).codeUnits).replaceAll("=", '');
    String secret = _secretPhrase!;
    String encodedFrase = base64Encoder.convert(secret.codeUnits).replaceAll("=", '');
    return "${encodedHeader}.${encodedpayload}.${encodedFrase}";
  }

  void renderFile(String file, Map<String, dynamic> data) async {
    _response.headers.set(HttpHeaders.contentTypeHeader, "text/html; charset=utf-8");
    _response.statusCode = HttpStatus.ok;

    final sfile = File("./www${file}");
    if (sfile.existsSync()) {
      _response.statusCode = HttpStatus.ok;
      String page = await sfile.readAsString();
      data.forEach((key, value) {
        page = page.replaceAll(RegExp('{{${key}}}'), value);
      });

      _response.write(page);
      _response.close();
    } else {
      _response.statusCode = HttpStatus.notFound;
      _response.write(
          '<html><head></head><body><h2>404 Not Found</h2><h3>The page ${file} no found in this server</h3></body></html>');
      _response.close();
    }
  }
}
