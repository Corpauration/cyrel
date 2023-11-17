import 'package:cyrel/api/base_entity.dart';

class GroupEntity extends BaseEntity {
  int id = -1;
  String name = "";
  String? referent;
  GroupEntity? parent;
  bool private = false;
  Map<String, String> tags = {};

  GroupEntity(
      this.id, this.name, this.referent, this.parent, this.private, this.tags);

  GroupEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        referent = json["referent"],
        parent = json["parent"] != null
            ? GroupEntity.fromJson(json["parent"])
            : null,
        private = json["private"],
        tags = (json["tags"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as String));

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "referent": referent,
      "parent": parent != null ? parent!.toMap() : null,
      "private": private,
      "tags": tags
    };
  }

  @override
  operator ==(other) => other is GroupEntity && other.id == id;
}

enum Groups { admin, homeworkResp, delegate }

extension GroupsExtension on Groups {
  int get value {
    switch (this) {
      case Groups.admin:
        return -1;
      case Groups.homeworkResp:
        return -2;
      case Groups.delegate:
        return 3;
    }
  }
}
