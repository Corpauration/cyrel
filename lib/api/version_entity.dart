import 'package:cyrel/api/base_entity.dart';

class VersionEntity extends BaseEntity {
  String version = "";
  String platform = "";
  String url = "";

  VersionEntity(this.version, this.platform, this.url);

  VersionEntity.fromJson(Map<String, dynamic> json)
      : version = json["version"],
        platform = json["platform"],
        url = json["url"];

  @override
  Map<String, dynamic> toMap() {
    return {
      "version": version,
      "platform": platform,
      "url": url
    };
  }
}
