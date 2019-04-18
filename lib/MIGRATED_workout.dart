import 'package:uuid/uuid.dart';
import 'dart:convert';

Workout workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return Workout.fromMap(jsonData);
}

String workoutToJson(Workout data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Workout {
  String uuid = new Uuid().v4();
  String name;
  int sets;
  int repetitions;
  int weight;
  bool useBodyWeight;
  String imageFilePath;

  Workout(this.name, this.sets, this.repetitions, this.weight, this.useBodyWeight, this.imageFilePath);

  factory Workout.fromMap(Map<String, dynamic> json) {
    bool tmpUseBodyWeight = json['useBodyWeight'] == 0 ? false : true;

    Workout w = new Workout(
      json['name'],
      json['sets'],
      json['repetitions'],
      json['weight'],
      tmpUseBodyWeight,
      json['imageFilePath']
    );
    w.uuid = json['uuid'];
    return w;
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'name': name,
    'sets': sets,
    'repetitions': repetitions,
    'weight': weight,
    'useBodyWeight': useBodyWeight,
    'imageFilePath': imageFilePath,
  };
}
