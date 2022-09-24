# DARTEXPRESS

DartExpress is a simple api server inspired in package express to NodeJS

## Class

> DartExpress: Primary class

***Constructor***

DartExpress(optional ConfigServer conf)

***Propertys***

None

***Methods***

* void run() => run server

* void route( required Route route ) => add route to server

* void useCors(bool use, {options}) => enabled/disabled Cors Headers response

* void useHTTPS(bool use, {options}) => enable Secure Protocol HTTPS

* void useStatic(bool use) => enable server files statics from folder www

* void useSecurity(bool) => enable/disable secure tokens (as like JWT)

> Route

***Constructor***

Route(
    Function callback,
    RouteVerb verb,
    String path,
    bool? securty
)

***Propertys***

* callback: Function (IncomingRequest request){ you code here }
    Required, Contains the code and logic to execute in the http request

* verb: RouteVerb enum
    Required, is a action in the request GET, POST,PUT, DELETE, OPTION

* path: String /segm1/segm2/segment3/
    Required, It is the route that validates an http request,  note that the route starts with / and ends with /

* securty; Bool true/false
    Optional, tells the server whether to validate an authorization token in the http request

> IncomingRequest

***Constructor***
    No need to instantiate the class, is a parameter to callback y Route class

***Propertys***

* body => Map<String,dynamic>, data send by POST, JSON, FORMS

* connectionInfo => ConnectionsInfo, object inherited from HttpRequest object

* headers => HttpHeaders, object inherited from HttpRequest object

* params  => Map<String,dynamic>, data send by URL (?data=1&data=foo)

* payload => Map<String,dynamic>, data decoded from token security

* response => HttpResponse, object inherited from HttpRequest object

* securityStatus =>  SecurtyTokenStatus, status of token security

* segmentsData => Map<String,dynamic>, data send by segments of path

***Methods***
