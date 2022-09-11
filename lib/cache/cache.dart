import 'package:cyrel/cache/fs/fs.dart';

class Tuple<K, V> {
  late K first;
  late V second;

  Tuple(this.first, this.second);
}

class NoFileSystemMounted extends Error {
  @override
  String toString() => "No file system is mounted!";
}

class Expired extends Error {
  @override
  String toString() => "The cache is expired!";
}

class CacheManager {
  final String _name;
  late final List<Tuple<FileSystem, FileSystemPriority>> _fs;

  CacheManager(this._name) {
    _fs = List.empty(growable: true);
  }

  mount(FileSystem fs, FileSystemPriority priority) {
    _fs.add(Tuple(fs, priority));
  }

  FileSystem _getFs(bool Function(FileSystemPriority) condition) {
    if (_fs.isEmpty) {
      throw NoFileSystemMounted();
    }
    if (_fs.length > 1) {
      return _fs.where((element) => condition(element.second)).first.first;
    } else {
      return _fs.first.first;
    }
  }

  Future<K> get<K>(String name, {bool evenIfExpired = false}) async {
    File file = await _getFs((p0) =>
            p0 == FileSystemPriority.read || p0 == FileSystemPriority.both)
        .getFile(name);
    if (file.isExpired && !evenIfExpired) throw Expired();
    return await file.get();
  }

  Future<void> save<K>(String name, K data, {DateTime? expireAt}) async {
    File file = await _getFs((p0) =>
            p0 == FileSystemPriority.write || p0 == FileSystemPriority.both)
        .getFile(name);
    expireAt ??= DateTime.now().add(const Duration(minutes: 20));
    file.setExpiration(expireAt);
    return await file.save(data);
  }

  Future<bool> isExpired<K>(String name) async {
    File file =
        await _getFs((p0) => p0 == FileSystemPriority.both).getFile(name);
    return file.isExpired;
  }

  Future<void> invalidate(String name) async {
    File file =
        await _getFs((p0) => p0 == FileSystemPriority.both).getFile(name);
    file.setExpiration(DateTime.now().subtract(const Duration(seconds: 1)));
  }

  Future<void> deleteCache() async {
    for (var value in _fs) {
      await value.first.delete();
    }
  }
}
