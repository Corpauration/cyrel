import 'package:cyrel/api/base_entity.dart';
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

  Future<void> mount(FileSystem fs, FileSystemPriority priority) async {
    _fs.add(Tuple(fs, priority));
    await fs.init(_name);
  }

  Future<void> syncThenMount(FileSystem fs, FileSystemPriority priority) async {
    await fs.init(_name);
    List<File> files = await fs.getAllFiles();
    for (int i = 0; i < _fs.length; i++) {
      for (var file in files) {
        File df = await _fs[i].first.getFile(file.name);
        await file.loadMetadata();
        df.setExpiration(file.expireAt);
        await df
            .save<MagicEntity>(await file.get<MagicEntity>() as MagicEntity);
        await _fs[i].first.updateFile(df);
      }
    }
    await _runOnFss((p0) => true, (p0) async {
      // Don't use this shit
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

  Future<K?> get<K extends BaseEntity>(String name,
      {bool evenIfExpired = false}) async {
    File file = await _getFs((p0) =>
            p0 == FileSystemPriority.read || p0 == FileSystemPriority.both)
        .getFile(name);
    await file.loadMetadata();
    if (file.isExpired && !evenIfExpired) throw Expired();
    return await file.get<K>();
  }

  Future<void> save<K extends BaseEntity>(String name, K data,
      {DateTime? expireAt}) async {
    expireAt ??= DateTime.now().add(const Duration(minutes: 5));
    for (int i = 0; i < _fs.length; i++) {
      if (_fs[i].second == FileSystemPriority.write ||
          _fs[i].second == FileSystemPriority.both) {
        File file = await _fs[i].first.getFile(name);
        file.setExpiration(expireAt);
        await file.save<K>(data).then((_) => _fs[i].first.updateFile(file));
      }
    }
  }

  Future<bool> isExpired(String name) async {
    File file =
        await _getFs((p0) => p0 == FileSystemPriority.both).getFile(name);
    await file.loadMetadata();
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
