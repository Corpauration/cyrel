import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Auth {
  final http.Client _httpClient = http.Client();

  static const String baseUrl = "http://localhost:6969";
  static const String realm = "test-realm";

  Future<TokenResponse?> getCredentials(String clientId, String grantType, String clientSecret, String scope, String username, String password) async {
    final http.Request request = http.Request("POST", Uri.parse("$baseUrl/realms/$realm/protocol/openid-connect/token"));
    Map<String, String> data = {
      "client_id": clientId,
      "grant_type": grantType,
      "client_secret": clientSecret,
      "scope": scope,
      "username": username,
      "password": password
    };
    request.body = Utils.buildQuery(data);
    request.headers["Content-Type"] = "application/x-www-form-urlencoded";
    print(request.body);
    http.StreamedResponse response = await _httpClient.send(request);
    Map<String, dynamic> chapterMap = jsonDecode(await response.stream.bytesToString());
    print(response.statusCode);
    if (response.statusCode == 200) {
      return TokenResponse.fromJson(chapterMap);
    } else {
      return null;
    }
  }

}

class Utils {
  static String buildQuery(Map<String, String> params) {
    List<String> list = List.empty(growable: true);
    params.forEach((key, value) { list.add("${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}"); });
    return list.join("&");
  }
}

class TokenResponse {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  String? idToken;
  int? expiresIn;

  TokenResponse.fromJson(Map<String, dynamic> json) :
      accessToken = json["access_token"],
      tokenType = json["token_type"],
      refreshToken = json["refresh_token"],
      idToken = json["id_token"],
      expiresIn = json["expires_in"];

  @override
  String toString() {
    return 'TokenResponse{\n\taccessToken: $accessToken, \n\trefreshToken: $refreshToken, \n\ttokenType: $tokenType, \n\tidToken: $idToken, \n\texpiresIn: $expiresIn\n}';
  }
}
