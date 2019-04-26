class ChartDataPoint {
  ChartDataPoint({this.dateTime, this.workoutSectionName, this.workoutSectionUuid, this.workoutDataUuid, this.dataPointUuid, this.value});

  final DateTime dateTime;
  final String workoutSectionName;
  final String workoutSectionUuid;
  final String workoutDataUuid;
  final String dataPointUuid;
  final int value;
}
