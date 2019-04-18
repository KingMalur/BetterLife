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
  String workoutDataUuid;
  String workoutUuid;
  String dateTimeIso8601;

  WorkoutData({this.workoutDataUuid, this.workoutUuid, this.dateTimeIso8601});

  factory WorkoutData.fromMap(Map<String, dynamic> json) {

    WorkoutData w = new WorkoutData(
        workoutDataUuid: json['workoutDataUuid'],
        workoutUuid: json['workoutUuid'],
        dateTimeIso8601: json['dateTimeIso8601']
    );
    return w;
  }

  Map<String, dynamic> toMap() => {
    'workoutDataUuid': workoutDataUuid,
    'workoutUuid': workoutUuid,
    'dateTimeIso8601': dateTimeIso8601,
  };
}
