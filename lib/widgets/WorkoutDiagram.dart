import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/database/models/DataPoint.dart';
import 'package:better_life/database/models/WorkoutData.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/models/ChartDataPoint.dart';

class WorkoutDiagram extends StatefulWidget {
  WorkoutDiagram({this.workoutUuid, this.showTimeSpanOptions = true});

  final String workoutUuid;
  bool showTimeSpanOptions;

  @override
  _WorkoutDiagramState createState() => _WorkoutDiagramState();
}

class _WorkoutDiagramState extends State<WorkoutDiagram> {
  Map<String, ChartDataPoint> _chartDataPointMap = new Map<String, ChartDataPoint>();
  Map<String, ChartDataPoint> _chartDataPointMapForDiagram = new Map<String, ChartDataPoint>();
  bool _dataPointsLoaded = false;
  List<DropdownMenuItem<int>> _timeSpanItems;
  int _currentTimeSpan;
  int _timeSpanInDays;

  @override
  initState() {
    super.initState();

    _timeSpanItems = _getTimeSpanItems();
    _currentTimeSpan = 0;
    _updateTimeSpan(_currentTimeSpan);
    _getDataPoints();
  }

  void _getDataPoints() async {
    await DatabaseHelper.db.getWorkoutDataListOfWorkout(workoutUuid: widget.workoutUuid).then((List<WorkoutData> dataList) async {
      if (dataList == null) {
        _dataPointsLoaded = true;
        setState(() {});
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
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _excludeDataPoints();

    if (_chartDataPointMap != null && _chartDataPointMap.isNotEmpty && _dataPointsLoaded) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2.75,
              child: _generateChart(),
            ),
            widget.showTimeSpanOptions ?
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: DropdownButton(
                    onChanged: _updateTimeSpan,
                    items: _timeSpanItems,
                    value: _currentTimeSpan,
                    hint: Text('Select Timespan of Diagram'),
                  )
                )
                : Container(width: 0.0, height: 0.0,),
          ],
        ),
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

  _updateTimeSpan(int selectedTimeSpan) {
    _currentTimeSpan = selectedTimeSpan;

    int days;

    if (_currentTimeSpan == 0) {
      // Get days since year one
      days = DateTime.now().difference(DateTime(0)).inDays;
    } else {
      var now = DateTime.now();
      days = DateTime.now().difference(DateTime(now.year, now.month - _currentTimeSpan, now.day)).inDays;
    }
    _timeSpanInDays = days;

    setState(() {});
  }

  List<DropdownMenuItem<int>> _getTimeSpanItems() {
    return [
      new DropdownMenuItem(child: Text('Last 3 Months'), value: 3,),
      new DropdownMenuItem(child: Text('Last 6 Months'), value: 6,),
      new DropdownMenuItem(child: Text('Last 12 Months'), value: 12,),
      new DropdownMenuItem(child: Text('All Time'), value: 0,),
    ];
  }

  void _excludeDataPoints() {
    if (_chartDataPointMap != null) {
      Map<String, ChartDataPoint> _tmpChartDataPointList = new Map<String, ChartDataPoint>();

      DateTime nDaysAgo = DateTime.now().subtract(Duration(days: _timeSpanInDays));
      _chartDataPointMap.forEach((String key, ChartDataPoint value) {
        if (nDaysAgo.compareTo(value.dateTime) <= 0) {
          _tmpChartDataPointList[key] = value;
        }
      });

      if (_tmpChartDataPointList != null) {
        _chartDataPointMapForDiagram = _tmpChartDataPointList;
      }
    }
  }

  Widget _generateChart() {
    List<charts.Series<ChartDataPoint, DateTime>> _dataSeries = _getChartDataPointsForChart();

    return new charts.TimeSeriesChart(
      _dataSeries,
      animate: true,
      animationDuration: Duration(milliseconds: 50),
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

    _chartDataPointMapForDiagram.forEach((String key, ChartDataPoint value) {
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

        String title = "Selected Data Point of\n\n" + DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").format(model.selectedDatum[0].datum.dateTime);
        Map<String, ChartDataPoint> selectedDataPoints = new Map<String, ChartDataPoint>();
        for (var d in model.selectedDatum) {
          selectedDataPoints[d.datum.dataPointUuid] = d.datum;
        }

        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return new SimpleDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                elevation: 5.0,
                title: AutoSizeText(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  maxLines: 4,
                  minFontSize: 15.0,
                ),
                children: <Widget>[
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: null,
                      ),
                      VerticalDivider(),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: null,
                      ),
                    ],
                  ),
                ],
              );
            }
        );
      }
    }
  }
}
