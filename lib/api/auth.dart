import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/auth_io.dart';
import 'package:cyrel/api/auth_web.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_io.dart';
import 'package:cyrel/cache/fs/fs_ram.dart';
import 'package:cyrel/cache/fs/fs_web.dart';
import 'package:cyrel/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';

class Auth {
  final SecurityResource _security;
  final Client _httpClient;
  Token? _token;

  final CacheManager _cache = CacheManager("auth_cache");

  late final Future<void> initFuture;

  Auth(SecurityResource security, Client client)
      : _security = security,
        _httpClient = client {
    if (kIsWeb) {
      initFuture = _cache.mount(WebFileSystem(), FileSystemPriority.both);
    } else {
      initFuture =
          _cache.mount(RamFileSystem(), FileSystemPriority.both).then((_) {
        return _cache.syncThenMount(IOFileSystem(), FileSystemPriority.write);
      });
    }
  }

  Future<bool> isTokenCached() async {
    try {
      if (!Api.instance.isOffline && await _cache.isExpired("token")) {
        return false;
      }
      _token = await _cache.get<Token>("token",
          evenIfExpired: Api.instance.isOffline);
      _token = await _security.refreshToken(_token!.refreshToken);
      _refreshToken();
      return true;
    } catch (e) {
      if (Api.instance.isOffline &&
          await _cache.get("token", evenIfExpired: true) != null) {
        return true;
      }
      return false;
    }
  }

  Future<void> clearAuthCache() async {
    await _cache.deleteCache();
  }

  Future<void> login(BuildContext context) async {
    if (kIsWeb) {
      WebAuth.login();
    } else {
      await resumeLogin(t: await IoAuth.login(_httpClient));
      print(await _cache.get<Token>("token"));
      HotRestartController.performHotRestart(context);
    }
  }

  Future<void> resumeLogin({Token? t}) async {
    Token? tok;
    if (kIsWeb) {
      tok = await WebAuth.resumeLogin(_httpClient);
    } else {
      tok = t;
    }
    if (tok != null) {
      _token = tok;
      await _cache.save<Token>("token", _token!,
          expireAt: DateTime.now().add(_token!.refreshExpiresIn == 0
              ? const Duration(days: 21)
              : Duration(seconds: _token!.refreshExpiresIn)));
    }
  }

  Future<void> logout() async {
    if (_token == null) return;
    await _security.logout(_token!.refreshToken);
    _token = null;
  }

  String? getToken() {
    return _token?.accessToken;
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
