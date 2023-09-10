import 'dart:io';

import 'routes.dart';
import 'enums.dart';

class RouteInternal extends Route {
  String regex;
  List paramSegment;
  bool isStatic = false;
  bool is404 = false;
  Map<String, dynamic> segmentsData = {};
  bool useSecurity = false;
  RouteInternal(
      {required super.verb,
      required super.path,
      required super.callback,
      required this.regex,
      required this.paramSegment,
      required this.useSecurity});
}

abstract class RoutesList {
  static List<RouteInternal?> _get = [];
  static List<RouteInternal?> _post = [];
  static List<RouteInternal?> _put = [];
  static List<RouteInternal?> _delete = [];
  static List<RouteInternal?> _patch = [];

  static void registerRoute(Route route) {
    Map<String, dynamic> reg = _validRoute(route.path);
    RouteInternal routeInternal = RouteInternal(
        verb: route.verb,
        path: route.path,
        callback: route.callback,
        useSecurity: route.security,
        regex: reg["regex"],
        paramSegment: reg["param"]);
    _isPathRegistred(path: routeInternal.path, method: routeInternal.verb);

    switch (route.verb) {
      case routeVerb.GET:
        _get.add(routeInternal);
        break;
      case routeVerb.POST:
        _post.add(routeInternal);
        break;
      case routeVerb.PUT:
        _put.add(routeInternal);
        break;
      case routeVerb.DELETE:
        _delete.add(routeInternal);
        break;
      case routeVerb.PATCH:
        _patch.add(routeInternal);
        break;
    }
  }

  static Map<String, dynamic> _validRoute(String path) {
    List parameterPath = [];
    String regexp = '^\/';
    bool variableseccion = false;
    bool isComodite = false;
    if (!path.startsWith("/")) {
      throw ({
        "code": "001",
        "description": "routes start with /",
        "path": path
      });
    }
    if (!path.endsWith("/")) {
      throw ({"code": "002", "description": "routes end with /", "path": path});
    }

    RegExpMatch? file =
        RegExp(r'(\:\*/)|(\:\w+/)', dotAll: false, multiLine: false)
            .firstMatch(path);
    if (file != null) {
      isComodite = true;
    }
    List<String> _segments = path.split("/");
    _segments.removeLast();
    _segments.removeAt(0);
    _segments.forEach((element) {
      bool isvar = element.startsWith(":") ? true : false;
      if (isvar && !variableseccion) {
        variableseccion = true;
      }
      if (!isvar && variableseccion) {
        throw ({
          "code": "003",
          "description": "routes bad config",
          "path": path
        });
      }
      if (!isvar) {
        regexp += "$element\/";
      } else {
        parameterPath.add(element.split(":")[1]);
      }
    });
    //(\:\*/)

    parameterPath.isNotEmpty
        ? regexp += '(\\w+\/){${parameterPath.length}}\$'
        : regexp += "\$";
    return {
      "regex": regexp,
      "param": parameterPath,
      "base": isComodite ? path.substring(0, file!.start) : path
    };
  }

  static Future<RouteInternal> isRouterRegister(
      String method, String path, bool isStatic) async {
    late RouteInternal? routeInternal;
    try {
      bool findStatic = false;
      RegExpMatch? fileMatch = RegExp(
              r'(\w+\.html|\w+\.css|\w+\.js|\w+\.ico|\w+\.gif|\w+\.png|\w+\.jpeg|\w+\.jpg|\w+\.svg|\w+\.webp){1}.*?',
              dotAll: false,
              multiLine: false)
          .firstMatch(path);
      String? file = fileMatch == null ? null : fileMatch[0]!;
      if (isStatic && file != null) {
        findStatic = true;
      } else {
        if (await FileSystemEntity.isDirectory("./www$path")) {
          if (!path.endsWith("/")) {
            path = "${path}/index.html";
          } else {
            path = "${path}index.html";
          }

          file = path;
          findStatic = true;
        }
      }

      switch (method.toUpperCase()) {
        case "GET":
          if (findStatic) {
            File a = File("./www$path");
            routeInternal = RouteInternal(
                verb: routeVerb.GET,
                path: path,
                callback: () {},
                regex: "",
                paramSegment: [],
                useSecurity: false);
            routeInternal.isStatic = true;

            if (a.existsSync()) {
              routeInternal.is404 = false;
              routeInternal.regex = _getType(file!);
            } else {
              routeInternal.is404 = true;
            }
          } else {
            routeInternal = _get.singleWhere((element) {
              return RegExp(element!.regex).hasMatch(path);
            });
            routeInternal!.isStatic = false;
            routeInternal.is404 = false;
          }
          break;
        case "POST":
          if (findStatic) {
            File a = File("./www$path");
            routeInternal = RouteInternal(
                verb: routeVerb.GET,
                path: path,
                callback: () {},
                regex: "",
                paramSegment: [],
                useSecurity: false);
            routeInternal.isStatic = true;
            if (a.existsSync()) {
              routeInternal.is404 = false;
              routeInternal.regex = _getType(file!);
            } else {
              routeInternal.is404 = true;
            }
          } else {
            routeInternal = _post.singleWhere(
                (element) => RegExp(element!.regex).hasMatch(path));
            routeInternal!.isStatic = false;
            routeInternal.is404 = false;
          }
          break;
        case "PUT":
          routeInternal = _put
              .singleWhere((element) => RegExp(element!.regex).hasMatch(path));
          routeInternal!.isStatic = false;
          routeInternal.is404 = false;
          break;
        case "DELETE":
          routeInternal = _delete
              .singleWhere((element) => RegExp(element!.regex).hasMatch(path));
          routeInternal!.isStatic = false;
          routeInternal.is404 = false;
          break;
        case "PATCH":
          routeInternal = _patch
              .singleWhere((element) => RegExp(element!.regex).hasMatch(path));
          routeInternal!.isStatic = false;
          routeInternal.is404 = false;
          break;
      }
      int lengthParam = routeInternal!.paramSegment.length;
      if (lengthParam > 0) {
        List<dynamic> valuesPath = path.split("/");
        valuesPath.removeLast();
        valuesPath.removeAt(0);
        List<dynamic> values = valuesPath
            .getRange(valuesPath.length - lengthParam, valuesPath.length)
            .toList();
        Map<String, dynamic> tmp = {};
        for (int i = 0; i < lengthParam; i++) {
          tmp[routeInternal.paramSegment[i]] = values[i];
        }

        routeInternal.segmentsData = tmp;
      }

      return routeInternal;
    } catch (e) {
      routeInternal = RouteInternal(
          verb: routeVerb.GET,
          path: path,
          callback: () {},
          regex: "",
          paramSegment: [],
          useSecurity: false);
      routeInternal.isStatic = false;
      routeInternal.is404 = true;
      return routeInternal;
    }
  }

  static String _getType(String file) {
    String ext = file.split(".")[1];
    String t = "";
    switch (ext) {
      case "html":
        t = "text/html; charset=utf-8";
        break;
      case "js":
        t = "text/javascript; charset=utf-8";
        break;
      case "css":
        t = "text/css; charset=utf-8";
        break;
      case "png":
        t = "image/png; charset=utf-8";
        break;
      case "svg":
        t = "image/svg+xml; charset=utf-8";
        break;
      case "gif":
        t = "image/gif; charset=utf-8";
        break;
      case "webp":
        t = "image/webp; charset=utf-8";
        break;
      case "jpg":
        t = "image/jpeg; charset=utf-8";
        break;
      case "jpeg":
        t = "image/jpeg; charset=utf-8";
        break;
    }
    return t;
  }

  static _isPathRegistred({required String path, required routeVerb method}) {
    bool result = false;
    switch (method) {
      case routeVerb.GET:
        if (_get.firstWhere(
              (element) => RegExp(element!.regex).hasMatch(path),
              orElse: () => null,
            ) !=
            null) {
          result = true;
        }
        break;
      case routeVerb.POST:
        if (_post.firstWhere(
              (element) => RegExp(element!.regex).hasMatch(path),
              orElse: () => null,
            ) !=
            null) {
          result = true;
        }
        break;
      case routeVerb.PUT:
        if (_put.firstWhere(
              (element) => RegExp(element!.regex).hasMatch(path),
              orElse: () => null,
            ) !=
            null) {
          result = true;
        }
        break;
      case routeVerb.DELETE:
        if (_delete.firstWhere(
              (element) => RegExp(element!.regex).hasMatch(path),
              orElse: () => null,
            ) !=
            null) {
          result = true;
        }
        break;
      case routeVerb.PATCH:
        if (_patch.firstWhere(
              (element) => RegExp(element!.regex).hasMatch(path),
              orElse: () => null,
            ) !=
            null) {
          result = true;
        }
        break;
    }
    if (result) {
      throw ({
        "code": "005",
        "description": "route already declared",
        "path": path
      });
    }
  }
}
