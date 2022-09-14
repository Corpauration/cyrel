import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/ui/theme.dart';

class PreferenceEntity extends BaseEntity {
  String id = "";
  Theme theme = Theme.white;

  PreferenceEntity({required this.id, required this.theme});

  PreferenceEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        theme = Theme.fromJson(json["theme"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': {
        "id": theme.id,
        "background": theme.background.value.toString(),
        "foreground": theme.foreground.value.toString(),
        "card": theme.card.value.toString(),
        "navIcon": theme.navIcon.value.toString(),
      }
    };
  }
}
