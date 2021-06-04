import 'dart:io';

import 'filedetails.dart';

enum securityTokenStatus {
  STATUS_OK,
  AUTHORIZATION_HEADER_REQUIRED,
  TOKEN_NOT_VALID,
  TOKEN_NOT_EXIST,
  TOKEN_EXPIRED,
}

class Request {
  Map<String, dynamic> _queryParams = {};
  Map<String, dynamic> _bodyParams = {};
  Map<String, dynamic> _routeParams = {};
  List<FileDetails> _bodyfiles = [];
  HttpHeaders? _headers;
  HttpConnectionInfo? _connection;
  securityTokenStatus securityStatus = securityTokenStatus.STATUS_OK;

  Map<String, dynamic> get queryParams => _queryParams;
  Map get bodyParams => _bodyParams;
  Map<String, dynamic> get routeParams => _routeParams;
  List<FileDetails> get bodyfiles => _bodyfiles;
  HttpHeaders? get headers => _headers;
  HttpConnectionInfo? get connectionInfo => _connection;

  Request.fromHttpRequest({required HttpRequest req}) {
    _headers = req.headers;
    _connection = req.connectionInfo;
    if (req.uri.hasQuery) {
      _queryParams = req.uri.queryParameters;
    }
  }
  void parametersRequest(
      {required body,
      required Map<String, dynamic> route,
      required List<FileDetails> files}) {
    _bodyParams = body;
    _bodyfiles = files;
    _routeParams = route;
    ;
  }
}
