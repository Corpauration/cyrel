import 'dart:convert';

import 'package:http/http.dart';

class Auth {
  final Client _httpClient;
  TokenResponse? _token;

  static const String baseUrl = "http://localhost:6969";
  static const String realm = "test-realm";
  static const String _clientId = "cyrel";
  static const String _grantType = "password";
  static const String _clientSecret = "Zpd00pIDZQWEa1VMoBYnZS84cATLwlee";
  static const String _scope = "openid";

  Auth(Client client) : _httpClient = client;

  Future<void> login(String username, String password) async {
    _token = await _getCredentials(username, password);
    if (_token == null) throw Error();
  }

  String? getToken() {
    return _token?.accessToken;
  }

  Future<TokenResponse?> _getCredentials(
      String username, String password) async {
    final Request request = Request("POST",
        Uri.parse("$baseUrl/realms/$realm/protocol/openid-connect/token"));
    Map<String, String> data = {
      "client_id": _clientId,
      "grant_type": _grantType,
      "client_secret": _clientSecret,
      "scope": _scope,
      "username": username,
      "password": password
    };
    request.body = Utils.buildQuery(data);
    request.headers["Content-Type"] = "application/x-www-form-urlencoded";
    print(request.body);
    StreamedResponse response = await _httpClient.send(request);
    Map<String, dynamic> chapterMap =
        jsonDecode(await response.stream.bytesToString());
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
    params.forEach((key, value) {
      list.add(
          "${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}");
    });
    return list.join("&");
  }
}

class TokenResponse {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  String? idToken;
  int? expiresIn;

  TokenResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json["access_token"],
        tokenType = json["token_type"],
        refreshToken = json["refresh_token"],
        idToken = json["id_token"],
        expiresIn = json["expires_in"];

  @override
  String toString() {
    return 'TokenResponse{\n\taccessToken: $accessToken, \n\trefreshToken: $refreshToken, \n\ttokenType: $tokenType, \n\tidToken: $idToken, \n\texpiresIn: $expiresIn\n}';
  }
}
