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

  static Version instance = Version();
}