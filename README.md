# DARTEXPRESS

DartExpress is a simple api server inpired in package express to NodeJS

## Class

> DartExpress: Primary class

***Propertys***

None

***Methods***

* void run({String ip, int port}) => run server

* void useSecurityToken({required String phraseSecret, Duration? timeLive}) => enable security tokens

* String newSecurityToken() => generate a new security token

* void useGet({required String route, required Function function, security: false}) => set a endpoint get to server

* void usePost({required String route, required Function function, security: false}) => set a endpoint post to server

* void useList(`List<Route>` list) => set a list endpoints to sever (see examples)

> Response: secondary class

***Propertys***

`Map<String, dynamic> queryParams` => parameters on url (?a=x&b=122)

`Map<String, dynamic> bodyParams` => parameters on body (recived in body request)

`Map<String, dynamic> routeParams`=> parameters on url custom (/:param1/:param2/)

`List<FileDetails> bodyfiles` => List files recived un request

`HttpHeaders headers` => headers request (dart class)

`HttpConnectionInfo? connectionInfo` => info about conecction (dart class)

`securityTokenStatus securityStatus` => status token recived

***Methods***

None public

> HttpResponse: class HttpResponse dart
