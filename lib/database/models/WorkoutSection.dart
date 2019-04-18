import 'dart:convert';

WorkoutSection workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return WorkoutSection.fromMap(jsonData);
}

String workoutToJson(WorkoutSection data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class WorkoutSection {
  String workoutSectionUuid;
  String workoutUuid;
  String name;

  WorkoutSection({this.workoutSectionUuid, this.workoutUuid, this.name});

  factory WorkoutSection.fromMap(Map<String, dynamic> json) {

    WorkoutSection w = new WorkoutSection(
        workoutSectionUuid: json['workoutSectionUuid'],
        workoutUuid: json['workoutUuid'],
        name: json['name']
    );
    return w;
  }

  Map<String, dynamic> toMap() => {
    'workoutSectionUuid': workoutSectionUuid,
    'workoutUuid': workoutUuid,
    'name': name,
  };
}
