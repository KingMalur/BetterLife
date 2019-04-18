import 'dart:convert';

DataPoint workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return DataPoint.fromMap(jsonData);
}

String workoutToJson(DataPoint data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class DataPoint {
  String dataPointUuid;
  String workoutSectionUuid;
  String workoutDataUuid;
  int value;

  DataPoint({this.dataPointUuid, this.workoutSectionUuid, this.workoutDataUuid, this.value});

  factory DataPoint.fromMap(Map<String, dynamic> json) {

    DataPoint w = new DataPoint(
        dataPointUuid: json['dataPointUuid'],
        workoutSectionUuid: json['workoutSectionUuid'],
        workoutDataUuid: json['workoutDataUuid'],
        value: json['value']
    );
    return w;
  }

  Map<String, dynamic> toMap() => {
    'dataPointUuid': dataPointUuid,
    'workoutSectionUuid': workoutSectionUuid,
    'workoutDataUuid': workoutDataUuid,
    'value': value,
  };
}
