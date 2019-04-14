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
  String imageFile;

  Workout(this.name, this.sets, this.repetitions, this.weight, this.useBodyWeight, this.imageFile);

  factory Workout.fromMap(Map<String, dynamic> json) {
    bool tmpUseBodyWeight = json['useBodyWeight'] == 0 ? false : true;

    Workout w = new Workout(
      json['name'],
      json['sets'],
      json['repetitions'],
      json['weight'],
      tmpUseBodyWeight,
      json['imageFile']
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
    'imageFile': imageFile,
  };
}
