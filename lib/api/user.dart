import 'package:cyrel/api/group.dart';

enum UserType { student, professor }

class User {
  String id = "";
  String email = "";
  String firstname = "";
  String lastname = "";
  UserType type = UserType.student;
  DateTime? birthday;
  List<Group> groups = List.empty();

  User(this.email, this.firstname, this.lastname, this.type, this.birthday,
      this.groups);

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? DateTime.tryParse(json["birthday"])
            : null,
        groups = List.generate(json["groups"].length,
            (index) => Group.fromJson(json["groups"][index]));
}
