import 'dart:convert';
import 'dart:html';

import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/cache/cache_data.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebFileSystem implements FileSystem {
  late final String _name;

  WebFileSystem() {
    if (!kIsWeb) throw Exception("The targeted platform is not web");
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<File>> getAllFiles() async {
    List<WebFile> files = [];
    for (var key in window.localStorage.keys) {
      if (key.startsWith("${_name}_")) {
        files.add(WebFile(key, key.replaceFirst("${_name}_", "")));
      }
    }
    return files;
  }

  @override
  Future<File> getFile(String name) async {
    return WebFile("${_name}_$name", name);
  }

  @override
  Future<void> init(String name) async {
    _name = name;
  }

  @override
  Future<void> updateFile(File file) async {}
}

class WebFile implements File {
  final String _name;
  final String _realName;
  late DateTime _expireAt;

  WebFile(this._name, this._realName);

  @override
  Future<void> delete() async {
    window.localStorage.remove(_name);
  }

  @override
  DateTime get expireAt => _expireAt;

  @override
  Future<K?> get<K extends BaseEntity>() async {
    if (!window.localStorage.containsKey(_name)) {
      return null;
    }
    try {
      CacheData data =
          CacheData<K>.fromJson(jsonDecode(window.localStorage[_name]!));
      _expireAt = data.expireAt;
      return data.data as K;
    } catch (e) {
      print(e);
      print("Error while trying to get ${_name}");
    }
  }

  @override
  bool get isExpired => DateTime.now().isAfter(_expireAt);

  @override
  String get name => _realName;

  @override
  Future<void> save<K extends BaseEntity>(K data) async {
    CacheData<K> cacheData = CacheData(_expireAt, data: data);
    window.localStorage[_name] = jsonEncode(cacheData.toMap());
  }

  @override
  setExpiration(DateTime expireAt) {
    _expireAt = expireAt;
  }

  @override
  Future<void> loadMetadata() async {
    if (!window.localStorage.containsKey(_name)) {
      return;
    }
    _expireAt =
        DateTime.parse(jsonDecode(window.localStorage[_name]!)["expireAt"]);
  }
}
