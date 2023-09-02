# dear

Dart

easy

api

rest

server

is a simple and easy builder api server inspired in package express to NodeJS


<code><img height="24" src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/dart/dart.png"></code>

Your contributing is welcome

## Installing

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  dear: any
```

## Usage
```dart
  //Simple server static files (folder wwww)
  Dear server = Dear(conf: ConfigServer());
  server.useStatic(true);
  server.run();
```

```dart
ConfigServer config = ConfigServer();
    //Simple server API response
    Dear server = Dear(conf: config);
    server.useCors(true);
    server.useSecurity(true, secretFrase: "MyT0k3n!Secret");
    //server.useHTTPS(true, config: ConfigHttps(chain: "chain", key: "key"));

    // Public endpoint
    server.route(
      Route(
        verb: routeVerb.GET,
        path: '/api/test/single/',
        callback: (IncomingRequest request) {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write('{"status":200, "response":"Ok single api endpoint","data":"{}"}');
          request.response.close();
        },
      ),
    );

    //Auth end point to send Token
    server.route(
      Route(
        verb: routeVerb.POST,
        path: '/api/test/auth/',
        callback: (IncomingRequest request) async {
          if (request.body["user"] == "admin" && request.body["pass"] == "admin") {
            String token = request.newSecurityToken(payload: {"user": "admin", "id": 9999});
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

    //private end point
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
```

