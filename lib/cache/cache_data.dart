import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/course_alert_entity.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/preference_entity.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/api/version_entity.dart';
import 'package:cyrel/ui/theme.dart';

class CacheData<K extends BaseEntity> {
  DateTime expireAt;
  K? data;

  CacheData(this.expireAt, {this.data});

  CacheData.fromJson(Map<String, dynamic> json)
      : expireAt = DateTime.parse(json["expireAt"]),
        data = entitiesFactory[K]!(json["data"]);

  Map<String, dynamic> toMap() {
    return {"expireAt": expireAt.toString(), "data": data!.toMap()};
  }
}

final entitiesFactory = <Type, Function>{
  CourseEntity: (Map<String, dynamic> json) => CourseEntity.fromJson(json),
  GroupEntity: (Map<String, dynamic> json) => GroupEntity.fromJson(json),
  HomeworkEntity: (Map<String, dynamic> json) => HomeworkEntity.fromJson(json),
  PreferenceEntity: (Map<String, dynamic> json) =>
      PreferenceEntity.fromJson(json),
  Token: (Map<String, dynamic> json) => Token.fromJson(json),
  UserEntity: (Map<String, dynamic> json) => UserEntity.fromJson(json),
  Theme: (Map<String, dynamic> json) => Theme.fromJson(json),
  MagicEntity: (Map<String, dynamic> json) => MagicEntity.fromJson(json),
  BoolEntity: (Map<String, dynamic> json) => BoolEntity.fromJson(json),
  StringEntity: (Map<String, dynamic> json) => StringEntity.fromJson(json),
  CourseAlertEntity: (Map<String, dynamic> json) =>
      CourseAlertEntity.fromJson(json),
  MagicList: (Map<String, dynamic> json) => MagicList.fromJson(json),
  MagicList<CourseEntity>: (Map<String, dynamic> json) =>
      MagicList<CourseEntity>.fromJson(json),
  MagicList<GroupEntity>: (Map<String, dynamic> json) =>
      MagicList<GroupEntity>.fromJson(json),
  MagicList<HomeworkEntity>: (Map<String, dynamic> json) =>
      MagicList<HomeworkEntity>.fromJson(json),
  MagicList<Theme>: (Map<String, dynamic> json) =>
      MagicList<Theme>.fromJson(json),
  MagicList<StringEntity>: (Map<String, dynamic> json) =>
      MagicList<StringEntity>.fromJson(json),
  MagicList<CourseAlertEntity>: (Map<String, dynamic> json) =>
      MagicList<CourseAlertEntity>.fromJson(json),
  VersionEntity: (Map<String, dynamic> json) => VersionEntity.fromJson(json),
};
