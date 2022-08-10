class Group {
  String name = "";
  String? referent;
  Group? parent;
  bool private = false;

  Group(this.name, this.referent, this.parent, this.private);

  Group.fromJson(Map<String, dynamic> json) :
        name = json["name"],
        referent = json["referent"],
        parent = Group.fromJson(json["parent"]),
        private = json["private"];
}