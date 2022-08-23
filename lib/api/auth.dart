import 'dart:convert';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/token.dart';
import 'package:flutter/foundation.dart';
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
    _refreshToken();
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

  _refreshToken() async {
    if (kDebugMode) {
      print("\x1B[32mAUTH\x1B[0m Watching token expiration");
    }
    await Future.delayed(Duration(seconds: _token!.expiresIn - 15));
    if (kDebugMode) {
      print("\x1B[33mAUTH\x1B[0m Token expiring in 15 seconds!");
    }
    try {
      _token = await _security.refreshToken(_token!.refreshToken);
      if (kDebugMode) {
        print("\x1B[32mAUTH\x1B[0m Token refreshed!");
        _refreshToken();
      }
    } catch (e) {
      _token = null;
      if (kDebugMode) {
        print("\x1B[31mAUTH\x1B[0m Error during refresh!");
        print(e);
      }
    }
  }
}
