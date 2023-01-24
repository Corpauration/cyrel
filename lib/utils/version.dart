import 'package:package_info_plus/package_info_plus.dart';

class Version {
  late Future<void> init;
  PackageInfo? _packageInfo;

  Version() {
    init = PackageInfo.fromPlatform().then((value) {
      _packageInfo = value;
      return null;
    });
  }

  @override
  String toString() {
    return _packageInfo?.version ?? "";
  }

  static int toInt(String v) {
    List<int> comp = v.split(".").map((e) => int.parse(e)).toList();
    return comp[0] * 10000000000 + comp[1] * 100000 + comp[2];
  }

  static int compare(String a, String b) {
    return toInt(a) - toInt(b);
  }

  static Version instance = Version();
}
