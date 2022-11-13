import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/group_entity.dart';

enum UserType { student, professor }

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.student:
        return "Étudiant";
      case UserType.professor:
        return "Enseignant";
    }
  }
}

class UserEntity extends BaseEntity {
  String id = "";
  String email = "";
  String firstname = "";
  String lastname = "";
  UserType type = UserType.student;
  DateTime? birthday;
  List<GroupEntity> groups = List.empty();

  UserEntity(this.email, this.firstname, this.lastname, this.type,
      this.birthday, this.groups);

  UserEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? null
            : DateTime.tryParse(json["birthday"]),
        groups = List.generate(json["groups"]["list"].length,
            (index) => GroupEntity.fromJson(json["groups"]["list"][index]));

  UserEntity.fromJsonLegacy(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? null
            : DateTime.tryParse(json["birthday"]),
        groups = List.generate(json["groups"].length,
            (index) => GroupEntity.fromJson(json["groups"][index]));

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "firstname": firstname,
      "lastname": lastname,
      "type": type.index,
      "birthday": birthday,
      "groups": MagicList.from(groups).toMap()
    };
  }
}
