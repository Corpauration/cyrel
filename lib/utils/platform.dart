import 'package:flutter/foundation.dart';
import 'dart:io' as io show Platform;

class Platform {
  static String get name {
    if (kIsWeb) {
      return "web";
    } else if (io.Platform.isAndroid) {
      return "android";
    } else if (io.Platform.isIOS) {
      return "ios";
    } else if (io.Platform.isLinux) {
      return "linux";
    } else if (io.Platform.isMacOS) {
      return "macos";
    } else if (io.Platform.isWindows) {
      return "windows";
    } else {
      return "";
    }
  }
}
