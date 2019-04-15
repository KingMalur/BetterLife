import 'package:uuid/uuid.dart';
import 'dart:convert';

WorkoutData workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return WorkoutData.fromMap(jsonData);
}

String workoutToJson(WorkoutData data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class WorkoutData {
  String uuid = new Uuid().v4();
  String workoutUuid;
  String dateTimeIso8601;
  int sets;
  int repetitions;
  int weight;

  WorkoutData(this.workoutUuid, this.dateTimeIso8601, this.sets, this.repetitions, this.weight);

  factory WorkoutData.fromMap(Map<String, dynamic> json) {
    WorkoutData data = new WorkoutData(
        json['workoutUuid'],
        json['dateTimeIso8601'],
        json['sets'],
        json['repetitions'],
        json['weight']
    );
    data.uuid = json['uuid'];
    return data;
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'workoutUuid': workoutUuid,
    'dateTimeIso8601': dateTimeIso8601,
    'sets': sets,
    'repetitions': repetitions,
    'weight': weight,
  };
}
