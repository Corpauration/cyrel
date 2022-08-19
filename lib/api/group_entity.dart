class GroupEntity {
  int id = -1;
  String name = "";
  String? referent;
  GroupEntity? parent;
  bool private = false;

  GroupEntity(this.id, this.name, this.referent, this.parent, this.private);

  GroupEntity.fromJson(Map<String, dynamic> json) :
        id = json["id"],
        name = json["name"],
        referent = json["referent"],
        parent = json["parent"] != null? GroupEntity.fromJson(json["parent"]): null,
        private = json["private"];
}