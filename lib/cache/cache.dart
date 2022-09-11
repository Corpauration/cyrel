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

  Future<void> syncThenMount(FileSystem fs, FileSystemPriority priority) async {
    List<File> files = await fs.getAllFiles();
    await _runOnFss((p0) => true, (p0) async {
      for (var file in files) {
        File df = await p0.getFile(file.name);
        df.setExpiration(file.expireAt);
        await df.save(file.get());
      }
    });
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

  Future<void> _runOnFss(bool Function(FileSystemPriority) condition,
      Function(FileSystem) run) async {
    if (_fs.isEmpty) {
      throw NoFileSystemMounted();
    }
    if (_fs.length > 1) {
      for (var value in _fs.where((element) => condition(element.second))) {
        await run(value.first);
      }
    } else {
      await run(_fs.first.first);
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
    expireAt ??= DateTime.now().add(const Duration(minutes: 20));
    await _runOnFss(
        (p0) => p0 == FileSystemPriority.write || p0 == FileSystemPriority.both,
        (fs) async {
      File file = await fs.getFile(name);
      file.setExpiration(expireAt!);
      file.save(data);
    });
  }

  Future<bool> isExpired<K>(String name) async {
    File file =
        await _getFs((p0) => p0 == FileSystemPriority.both).getFile(name);
    return file.isExpired;
  }

  Future<void> invalidate(String name) async {
    await _runOnFss((p0) => true, (fs) async {
      File file = await fs.getFile(name);
      file.setExpiration(DateTime.now().subtract(const Duration(seconds: 1)));
    });
  }

  Future<void> deleteCache() async {
    await _runOnFss((p0) => true, (fs) async {
      await fs.delete();
    });
  }
}
