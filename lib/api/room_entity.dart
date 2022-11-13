import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/course_entity.dart';

class RoomEntity extends BaseEntity {
  String id = "";
  String name = "";
  int capacity = -1;
  bool computers = false;
  List<CourseEntity> courses = [];

  RoomEntity(this.id, this.name, this.capacity, this.computers, this.courses);

  RoomEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        capacity = json["capacity"],
        computers = json["computers"],
        courses = List.generate(json["courses"].length,
            (index) => CourseEntity.fromJson(json["courses"][index]));

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "capacity": capacity,
      "computers": computers,
      "courses": MagicList.from(courses).toMap()
    };
  }
}
