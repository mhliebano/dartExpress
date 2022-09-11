enum routeVerb {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
}

enum headersFileType {
  HTML,
  IMAGE_PNG,
  IMAGE_JPG,
  IMAGE_GIF,
  IMAGE_SVG,
  JS,
  CSS,
}

enum securityTokenStatus {
  STATUS_OK,
  AUTHORIZATION_HEADER_REQUIRED,
  TOKEN_NOT_VALID,
  TOKEN_NOT_EXIST,
  TOKEN_EXPIRED,
}
