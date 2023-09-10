import 'package:cyrel/api/base_entity.dart';

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
  Map<String, String> tags = {};

  UserEntity(this.email, this.firstname, this.lastname, this.type,
      this.birthday, this.tags);

  UserEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? null
            : DateTime.tryParse(json["birthday"]),
        tags = (json["tags"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as String));

  UserEntity.fromJsonLegacy(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        firstname = json["firstname"],
        lastname = json["lastname"],
        type = UserType.values[json["type"]],
        birthday = json["birthday"] == null
            ? null
            : DateTime.tryParse(json["birthday"]),
        tags = (json["tags"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as String));

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "firstname": firstname,
      "lastname": lastname,
      "type": type.index,
      "birthday": birthday,
      "tags": tags
    };
  }
}
