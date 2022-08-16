import 'dart:convert';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/token.dart';
import 'package:http/http.dart';

class Auth {
  final SecurityResource _security;
  final Client _httpClient;
  Token? _token;

  Auth(SecurityResource security, Client client)
      : _security = security,
        _httpClient = client;

  Future<void> login(String username, String password) async {
    _token = await _getCredentials(username, password);
    if (_token == null) throw Error();
  }

  String? getToken() {
    return _token?.accessToken;
  }

  Future<Token?> _getCredentials(String username, String password) async {
    try {
      return _security.getToken(username, password);
    } catch (e) {
      return null;
    }
  }
}
