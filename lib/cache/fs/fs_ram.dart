import 'package:cyrel/api/base_entity.dart';
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

  @override
  Future<void> updateFile(File file) async {
    _directory[file.name] = file as RamFile;
  }
}

class RamFile implements File {
  final String _filename;
  late CacheData _data;

  RamFile(this._filename) {
    _data = CacheData(DateTime.now().subtract(const Duration(seconds: 1)));
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  DateTime get expireAt => _data.expireAt;

  @override
  Future<K?> get<K extends BaseEntity>() async {
    if (_data.data.toString().contains("MagicEntity") &&
        K.toString() != "MagicEntity") {
      _data.data = (_data.data as MagicEntity).convertTo(K);
    }

    return _data.data as K?;
  }

  @override
  String get name => _filename;

  @override
  Future<void> save<K extends BaseEntity>(K data) async {
    _data.data = data;
  }

  @override
  setExpiration(DateTime expireAt) {
    _data.expireAt = expireAt;
  }

  @override
  bool get isExpired => DateTime.now().isAfter(_data.expireAt);

  @override
  Future<void> loadMetadata() async {}
}
