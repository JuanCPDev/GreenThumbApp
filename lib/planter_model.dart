class Planter {
  List<Planters> planters=[];

  Planter({required this.planters});

  Planter.fromJson(Map<String, dynamic> json) {
    if (json['planters'] != null) {
      planters = <Planters>[];
      json['planters'].forEach((v) {
        planters.add(new Planters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.planters != null) {
      data['planters'] = this.planters.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Planters {
  String lastTimeChecked="";
  String name="";
  int value=0;
  String thumbnailUrl="";

  Planters({required this.lastTimeChecked, required this.name, required this.value, required this.thumbnailUrl});

  Planters.fromJson(Map<String, dynamic> json) {
    lastTimeChecked = json['lastTimeChecked'];
    name = json['name'];
    value = json['value'];
    thumbnailUrl = json['thumbnailUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lastTimeChecked'] = this.lastTimeChecked;
    data['name'] = this.name;
    data['value'] = this.value;
    data['thumbnailUrl'] = this.thumbnailUrl;
    return data;
  }
}