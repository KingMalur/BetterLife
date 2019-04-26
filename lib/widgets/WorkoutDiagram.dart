import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:better_life/database/models/DataPoint.dart';
import 'package:better_life/database/models/WorkoutData.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/models/ChartDataPoint.dart';
import 'package:better_life/pages/EditWorkoutData.dart';

class WorkoutDiagram extends StatefulWidget {
  WorkoutDiagram({this.workoutUuid, this.timeSpanInDays});

  final String workoutUuid;
  int timeSpanInDays;

  @override
  _WorkoutDiagramState createState() => _WorkoutDiagramState();
}

class _WorkoutDiagramState extends State<WorkoutDiagram> {
  Map<String, ChartDataPoint> _chartDataPointMap = new Map<String, ChartDataPoint>();
  bool _dataPointsLoaded = false;

  @override
  initState() {
    super.initState();

    DatabaseHelper.db.getWorkoutDataListOfWorkout(workoutUuid: widget.workoutUuid).then((List<WorkoutData> dataList) async {
      if (dataList == null) {
        _dataPointsLoaded = true;
        setState(() {}); // Refresh GUI
        return;
      }

      dataList.sort((a, b) => DateTime.parse(a.dateTimeIso8601).compareTo(DateTime.parse(b.dateTimeIso8601)));

      for (var data in dataList) {
        await DatabaseHelper.db.getDataPointListOfWorkoutData(workoutDataUuid: data.workoutDataUuid).then((List<DataPoint> dataPointList) async {
          if (dataPointList == null) {
            return;
          }

          for (var dataPoint in dataPointList) {
            var section = await DatabaseHelper.db.getWorkoutSection(workoutSectionUuid: dataPoint.workoutSectionUuid);
            _chartDataPointMap[dataPoint.dataPointUuid] = ChartDataPoint(
                dateTime: DateTime.parse(data.dateTimeIso8601),
                workoutSectionName: section.name,
                workoutSectionUuid: section.workoutSectionUuid,
                workoutDataUuid: data.workoutDataUuid,
                dataPointUuid: dataPoint.dataPointUuid,
                value: dataPoint.value);
          }
        });
      }

      _dataPointsLoaded = true;
      setState(() {}); // Refresh GUI
    });
  }

  @override
  Widget build(BuildContext context) {
    _excludeDataPoints();

    if (_chartDataPointMap != null && _chartDataPointMap.isNotEmpty && _dataPointsLoaded) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.75,
        padding: EdgeInsets.all(8.0),
        child: _generateChart(),
      );
    } else {
      if (_dataPointsLoaded) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.75,
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('No Workout Data found!'),
        );
      } else {
        return new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.75,
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: new CircularProgressIndicator(),
        );
      }
    }
  }

  void _excludeDataPoints() {
    if (_chartDataPointMap != null) {
      Map<String, ChartDataPoint> _tmpChartDataPointList = new Map<String, ChartDataPoint>();

      DateTime nDaysAgo = DateTime.now().subtract(Duration(days: widget.timeSpanInDays));
      _chartDataPointMap.forEach((String key, ChartDataPoint value) {
        if (nDaysAgo.compareTo(value.dateTime) <= 0) {
          _tmpChartDataPointList[key] = value;
        }
      });

      if (_tmpChartDataPointList != null) {
        _chartDataPointMap = _tmpChartDataPointList;
      }
    }
  }

  Widget _generateChart() {
    List<charts.Series<ChartDataPoint, DateTime>> _dataSeries = _getChartDataPointsForChart();

    return new charts.TimeSeriesChart(
      _dataSeries,
      animate: true,
      animationDuration: Duration(milliseconds: 200),
      defaultInteractions: false,
      defaultRenderer: new charts.LineRendererConfig(),
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        ),
      ],
      behaviors: [
        new charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tap,),
        new charts.LinePointHighlighter(selectionModelType: charts.SelectionModelType.info),
      ],
    );
  }

  List<charts.Series<ChartDataPoint, DateTime>> _getChartDataPointsForChart() {
    List<charts.Series<ChartDataPoint, DateTime>> l = new List<charts.Series<ChartDataPoint, DateTime>>();

    Map<String, List<ChartDataPoint>> points = new Map<String, List<ChartDataPoint>>();

    _chartDataPointMap.forEach((String key, ChartDataPoint value) {
      if (!points.containsKey(value.workoutSectionName)) {
        points[value.workoutSectionName] = new List<ChartDataPoint>();
      }

      points[value.workoutSectionName].add(value);
    });

    points.forEach((String key, List<ChartDataPoint> value) {
      value.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      l.add(
        new charts.Series<ChartDataPoint, DateTime>(
          id: key,
          domainFn: (ChartDataPoint data, _) => data.dateTime,
          measureFn: (ChartDataPoint data, _) => data.value,
          data: value,
        ),
      );
    });

    return l;
  }

  _onSelectionChanged(charts.SelectionModel model) async {
    if (model.hasDatumSelection) {
      if (model.selectedDatum != null && model.selectedDatum.isNotEmpty) {
        List<String> dataPointsToEdit = new List<String>();
        for (var d in model.selectedDatum) {
          dataPointsToEdit.add(d.datum.dataPointUuid);
        }

        List<ChartDataPoint> newPoints = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
            EditWorkoutData(dataPointsToEdit: dataPointsToEdit,)));

        if (newPoints == null || newPoints.isEmpty) {
          for (var point in dataPointsToEdit) {
            if (_chartDataPointMap.containsKey(point))
            _chartDataPointMap.remove(point);
          }
        } else {
          for (var point in newPoints) {
            _chartDataPointMap[point.dataPointUuid] = point;
          }
        }

        setState(() {});
      }
    }
  }
}
