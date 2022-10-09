import 'package:cyrel/api/base_entity.dart';

class GroupEntity extends BaseEntity {
  int id = -1;
  String name = "";
  String? referent;
  GroupEntity? parent;
  bool private = false;

  GroupEntity(this.id, this.name, this.referent, this.parent, this.private);

  GroupEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        referent = json["referent"],
        parent = json["parent"] != null
            ? GroupEntity.fromJson(json["parent"])
            : null,
        private = json["private"];

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "referent": referent,
      "parent": parent != null ? parent!.toMap() : null,
      "private": private
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
