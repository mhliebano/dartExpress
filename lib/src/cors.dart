import 'dart:io';

class Cors {
  String _accessControlAllowOrigin = "*";
  String _accessControlAllowHeader =
      "Origin, X-API-KEY, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method, Access-Control-Allow-Headers, Authorization, observe, enctype, Content-Length, X-Csrf-Token";
  String _accessControlAllowMethods = "GET, PUT, POST, DELETE, PATCH";
  String _accessControlAllowCredential = "true";
  String _accessControlAllowMaxAge = "3600";

  void responseCORS(HttpResponse response) {
    response.headers.set("Access-Control-Allow-Origin", this._accessControlAllowOrigin);
    response.headers.set("Access-Control-Allow-Headers", this._accessControlAllowHeader);
    response.headers.set("Access-Control-Allow-Methods", this._accessControlAllowMethods);
    response.headers.set("Access-Control-Allow-Credentials", this._accessControlAllowCredential);
    response.headers.set("Access-Control-Max-Age", this._accessControlAllowMaxAge);
    response.close();
  }

  void setHeaderCORS(String key, String value) {}
}
