import 'package:cyrel/api/base_entity.dart';

abstract class FileSystem {
  Future<void> init(String name);

  Future<File> getFile(String name);

  Future<void> updateFile(File file);

  Future<List<File>> getAllFiles();

  Future<void> delete();
}

abstract class File {
  DateTime get expireAt;

  String get name;

  bool get isExpired;

  Future<K?> get<K extends BaseEntity>();

  Future<void> save<K extends BaseEntity>(K data);

  Future<void> delete();

  setExpiration(DateTime expireAt);

  Future<void> loadMetadata();
}

enum FileSystemPriority { read, write, both }
