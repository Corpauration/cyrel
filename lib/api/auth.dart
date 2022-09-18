import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_ram.dart';
import 'package:cyrel/cache/fs/fs_web.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Auth {
  final SecurityResource _security;
  final Client _httpClient;
  Token? _token;

  final CacheManager _cache = CacheManager("auth_cache");

  Auth(SecurityResource security, Client client)
      : _security = security,
        _httpClient = client {
    if (kIsWeb) {
      _cache.mount(WebFileSystem(), FileSystemPriority.both);
    } else {
      _cache.mount(RamFileSystem(), FileSystemPriority.both);
    }
  }

  Future<bool> isTokenCached() async {
    try {
      if (!Api.instance.isOffline && await _cache.isExpired("token"))
        return false;
      _token = await _cache.get<Token>("token",
          evenIfExpired: Api.instance.isOffline);
      _refreshToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAuthCache() async {
    await _cache.deleteCache();
  }

  Future<void> login(String username, String password) async {
    _token = await _getCredentials(username, password);
    if (_token == null) throw Error();
    _refreshToken();
    await _cache.save<Token>("token", _token!,
        expireAt:
            DateTime.now().add(Duration(seconds: _token!.refreshExpiresIn)));
  }

  Future<void> logout() async {
    if (_token == null) return;
    await _security.logout(_token!.refreshToken);
    _token = null;
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
      }
      _refreshToken();
      await _cache.save<Token>("token", _token!,
          expireAt:
              DateTime.now().add(Duration(seconds: _token!.refreshExpiresIn)));
    } catch (e) {
      _token = null;
      if (kDebugMode) {
        print("\x1B[31mAUTH\x1B[0m Error during refresh!");
        print(e);
      }
    }
  }
}
