import 'package:cyrel/cache/cache_data.dart';
import 'package:cyrel/cache/fs/fs.dart';

class RamFileSystem implements FileSystem {
  final Map<String, RamFile> _directory = {};

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<File>> getAllFiles() {
    // TODO: implement getAllFiles
    throw UnimplementedError();
  }

  @override
  Future<File> getFile(String name) async {
    if (!_directory.containsKey(name)) {
      _directory[name] = RamFile(name);
    }
    return _directory[name]!;
  }

  @override
  Future<void> init(String name) async {}
}

class RamFile implements File {
  final String _filename;
  late DateTime _expireAt;
  late CacheData _data;

  RamFile(this._filename) {
    _expireAt = DateTime.now().subtract(const Duration(seconds: 1));
    _data = CacheData(_expireAt);
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  DateTime get expireAt => _expireAt;

  @override
  Future<K> get<K>() async {
    return _data.data;
  }

  @override
  String get name => _filename;

  @override
  Future<void> save<K>(K data) async {
    _data.data = data;
  }

  @override
  setExpiration(DateTime expireAt) {
    _expireAt = expireAt;
  }

  @override
  bool get isExpired => DateTime.now().isAfter(_expireAt);
}
