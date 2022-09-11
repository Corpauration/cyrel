abstract class FileSystem {
  Future<void> init(String name);

  Future<File> getFile(String name);

  Future<List<File>> getAllFiles();

  Future<void> delete();
}

abstract class File {
  DateTime get expireAt;

  String get name;

  bool get isExpired;

  Future<K> get<K>();

  Future<void> save<K>(K data);

  Future<void> delete();

  setExpiration(DateTime expireAt);
}

enum FileSystemPriority { read, write, both }
