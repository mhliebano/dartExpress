import 'package:crypto/crypto.dart' as crypto;

class SecurityToken {
  String _token = "";
  DateTime _init = DateTime.now();
  DateTime _expire = DateTime.now().add(Duration(hours: 2));

  String get token => _token;
  DateTime get init => _init;
  DateTime get exprire => _expire;

  SecurityToken({required String secretKey, Duration? expireTime}) {
    if (expireTime == null) {
      _expire = _init.add(Duration(hours: 2));
    } else {
      _expire = _init.add(expireTime);
    }
    crypto.Digest shatoken = crypto.sha256.convert(
        "{$secretKey}${_init.toString()}${_expire.toString()}".codeUnits);
    _token = "_dsWT${shatoken.toString()}";
  }

  bool isExpired() {
    return DateTime.now().millisecondsSinceEpoch >
            _expire.millisecondsSinceEpoch
        ? true
        : false;
  }
}
