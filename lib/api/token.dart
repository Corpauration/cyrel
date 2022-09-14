import 'package:cyrel/api/base_entity.dart';

class Token extends BaseEntity {
  String scope;
  String sessionState;
  String tokenType;
  String accessToken;
  int expiresIn;
  String refreshToken;
  int refreshExpiresIn;
  int notBeforePolicy;
  String idToken;

  Token(this.accessToken,
      this.refreshToken,
      this.idToken,
      this.expiresIn,
      this.refreshExpiresIn,
      this.tokenType,
      this.notBeforePolicy,
      this.sessionState,
      this.scope);

  Token.fromJson(Map<String, dynamic> json)
      : accessToken = json["accessToken"],
        refreshToken = json["refreshToken"],
        idToken = json["idToken"],
        expiresIn = json["expiresIn"],
        refreshExpiresIn = json["refreshExpiresIn"],
        tokenType = json["tokenType"],
        notBeforePolicy = json["notBeforePolicy"],
        sessionState = json["sessionState"],
        scope = json["scope"];

  @override
  Map<String, dynamic> toMap() {
    return {
      "scope": scope,
      "sessionState": sessionState,
      "tokenType": tokenType,
      "accessToken": accessToken,
      "expiresIn": expiresIn,
      "refreshToken": refreshToken,
      "refreshExpiresIn": refreshExpiresIn,
      "notBeforePolicy": notBeforePolicy,
      "idToken": idToken
    };
  }
}
