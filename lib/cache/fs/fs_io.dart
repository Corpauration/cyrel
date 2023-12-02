import 'dart:convert';
import 'dart:io' as IO;

import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/cache/cache_data.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class IOFileSystem implements FileSystem {
  late final String _name;
  late final IO.Directory _dir;
  late final LocalFileSystem _fs;

  IOFileSystem() {
    if (kIsWeb) throw Exception("The targeted platform is web");
  }

  @override
  Future<void> delete() async {
    (await getAllFiles()).forEach((element) => element.delete());
  }

  @override
  Future<List<File>> getAllFiles() async {
    List<IOFile> files = [];
    List<IO.FileSystemEntity> stream = _dir.listSync();
    for (IO.FileSystemEntity e in stream) {
      files.add(IOFile(_fs, e));
    }
    return files;
  }

  @override
  Future<File> getFile(String name) async {
    Iterable<File> res =
        (await getAllFiles()).where((element) => element.name == name);
    if (res.length == 1)
      return res.first;
    else
      return IOFile(_fs, _fs.file(p.join(_dir.path, name)));
  }

  @override
  Future<void> init(String name) async {
    _name = name;
    IO.Directory cacheDir = await getTemporaryDirectory();
    _fs = const LocalFileSystem();
    _dir = _fs.directory(p.join(cacheDir.path, name));
    print(_dir.path);
    await _dir.create(recursive: true);
  }

  @override
  Future<void> updateFile(File file) async {}
}

class IOFile implements File {
  final LocalFileSystem _fs;
  late final IO.File _file;
  late final String _name;
  late DateTime _expireAt;

  IOFile(this._fs, IO.FileSystemEntity _f) {
    _file = _fs.file(_f.path);
    _name = _file.path.split("/").last;
  }

  @override
  Future<void> delete() async {
    await _file.delete();
  }

  @override
  DateTime get expireAt => _expireAt;

  @override
  Future<K?> get<K extends BaseEntity>() async {
    if (!await _file.exists()) {
      return null;
    }
    try {
      CacheData data =
          CacheData<K>.fromJson(jsonDecode(await _file.readAsString()));
      _expireAt = data.expireAt;
      return data.data as K;
    } catch (e) {
      print(e);
      print("Error while trying to get ${_name}");
    }
  }

  @override
  bool get isExpired =>
      DateTime.now().isAfter(_expireAt) || !_file.existsSync();

  @override
  String get name => _name;

  @override
  Future<void> save<K extends BaseEntity>(K data) async {
    if (!await _file.exists()) {
      await _file.create(recursive: true);
    }
    CacheData<K> cacheData = CacheData(_expireAt, data: data);
    await _file.writeAsString(jsonEncode(cacheData.toMap()));
  }

  @override
  setExpiration(DateTime expireAt) {
    _expireAt = expireAt;
  }

  @override
  Future<void> loadMetadata() async {
    if (!await _file.exists()) {
      _expireAt = DateTime.now().subtract(const Duration(minutes: 1));
      return;
    }
    _expireAt =
        DateTime.parse(jsonDecode(await _file.readAsString())["expireAt"]);
  }
}
