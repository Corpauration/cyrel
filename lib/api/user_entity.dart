import 'package:cyrel/api/group_entity.dart';

enum UserType { student, professor }

class UserEntity {
  String id = "";
  String email = "";
  String firstname = "";
  String lastname = "";
  UserType type = UserType.student;
  DateTime? birthday;
  List<GroupEntity> groups = List.empty();

  UserEntity(this.email, this.firstname, this.lastname, this.type, this.birthday,
      this.groups);

  UserEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? DateTime.tryParse(json["birthday"])
            : null,
        groups = List.generate(json["groups"].length,
            (index) => GroupEntity.fromJson(json["groups"][index]));
}
