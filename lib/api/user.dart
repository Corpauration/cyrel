import 'package:cyrel/api/group.dart';

enum UserType { student, professor }

class User {
  String email = "";
  String firstname = "";
  String lastname = "";
  UserType type = UserType.student;
  DateTime? birthday;
  List<Group> groups = List.empty();

  User(this.email, this.firstname, this.lastname, this.type, this.birthday,
      this.groups);
}