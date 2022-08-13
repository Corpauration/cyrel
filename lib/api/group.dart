class Group {
  int id = -1;
  String name = "";
  String? referent;
  Group? parent;
  bool private = false;

  Group(this.id, this.name, this.referent, this.parent, this.private);

  Group.fromJson(Map<String, dynamic> json) :
        id = json["id"],
        name = json["name"],
        referent = json["referent"],
        parent = json["parent"] != null? Group.fromJson(json["parent"]): null,
        private = json["private"];
}