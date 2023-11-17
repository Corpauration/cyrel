import 'package:cyrel/api/base_entity.dart';

class PreregistrationBiscuit extends BaseEntity {
  int promo = -100;
  int group = -100;

  PreregistrationBiscuit({required this.promo, required this.group});

  PreregistrationBiscuit.fromJson(Map<String, dynamic> json)
      : promo = json["promo"],
        group = json["group"];

  Map<String, dynamic> toMap() {
    return {'promo': promo, 'group': group};
  }
}
