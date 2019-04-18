import 'dart:convert';

Tag workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return Tag.fromMap(jsonData);
}

String workoutToJson(Tag data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Tag {
  String tagUuid;
  String name;
  int colorA;
  int colorR;
  int colorG;
  int colorB;

  Tag({this.tagUuid, this.name, this.colorA, this.colorR, this.colorG, this.colorB});

  factory Tag.fromMap(Map<String, dynamic> json) {

    Tag w = new Tag(
        tagUuid: json['tagUuid'],
        name: json['name'],
        colorA: json['colorA'],
        colorR: json['colorR'],
        colorG: json['colorG'],
        colorB: json['colorB']
    );
    return w;
  }

  Map<String, dynamic> toMap() => {
    'tagUuid': tagUuid,
    'name': name,
    'colorA': colorA,
    'colorR': colorR,
    'colorG': colorG,
    'colorB': colorB,
  };
}
