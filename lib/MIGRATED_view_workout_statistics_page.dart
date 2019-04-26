import 'package:flutter/material.dart';

import 'package:better_life/MIGRATED_workout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:better_life/MIGRATED_database.dart';
import 'package:better_life/MIGRATED_workout_data.dart';
import 'package:better_life/MIGRATED_workout_data_point.dart';
import 'package:better_life/MIGRATED_add_new_workout_data_page.dart';
import 'package:better_life/MIGRATED_alert_yes_no.dart';
import 'package:better_life/edit_workout_data_page.dart';

class ViewWorkoutStatisticsPage extends StatefulWidget {
  ViewWorkoutStatisticsPage({this.workout});

  final Workout workout;

  @override
  _ViewWorkoutStatisticsPageState createState() => _ViewWorkoutStatisticsPageState();
}

class _ViewWorkoutStatisticsPageState extends State<ViewWorkoutStatisticsPage> {
  List<DropdownMenuItem<int>> _timeSpanItems;
  int _currentTimeSpan;

  @override
  initState() {
    super.initState();

    _timeSpanItems = _getTimeSpanItems();
    setState(() {
      _currentTimeSpan = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Statistics',),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                widget.workout.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                maxLines: 1,
                minFontSize: 15.0,
              ),
              widget.workout.useBodyWeight ?
                AutoSizeText(
                  '(Uses Bodyweight)',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                  maxLines: 1,
                  minFontSize: 10.0,
                ) : Container(),
              Divider(),
              workoutDiagram,
              Divider(),
              DropdownButton(
                onChanged: _updateTimeSpan,
                items: _timeSpanItems,
                value: _currentTimeSpan,
                hint: Text('Select Timespan of Diagram'),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete,),
                    color: Colors.black45,
                    onPressed: deleteAllWorkoutData,
                  ),
                  VerticalDivider(),
                  IconButton(
                    icon: Icon(Icons.add,),
                    color: Colors.black45,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          AddNewWorkoutDataPage(workout: widget.workout,)));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _getTimeSpanItems() {
    return [
      new DropdownMenuItem(child: Text('3 Months'), value: 3,),
      new DropdownMenuItem(child: Text('6 Months'), value: 6,),
      new DropdownMenuItem(child: Text('12 Months'), value: 12,),
      new DropdownMenuItem(child: Text('All Time'), value: 0,),
    ];
  }

  _updateTimeSpan(int selectedTimeSpan) {
    setState(() {
      _currentTimeSpan = selectedTimeSpan;
    });
  }

  Widget get workoutDiagram {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.75,
      padding: EdgeInsets.all(8.0),
      child: new FutureBuilder(
      future: DatabaseProvider.db.getWorkoutDataPointsOfWorkout(widget.workout.uuid, excludeOlderThanTimeSpan: true, notOlderThanDays: _currentTimeSpan * 30.0), // For approximately months * days per month
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return new Container(
                padding: EdgeInsets.all(8.0),
                child: _getWorkoutDataChart(snapshot),
              );
            } else {
              return new Container(
                alignment: Alignment.center,
                child: new CircularProgressIndicator(), // TODO: Change color
              );
           }
         } else {
           return new Container(
             alignment: Alignment.center,
             child: new CircularProgressIndicator(), // TODO: Change color
            );
          }
        },
      ),
    );
  }

  Widget _getWorkoutDataChart(AsyncSnapshot snapshot) {
    List<WorkoutData> _data = new List<WorkoutData>();
    for (var e in snapshot.data) {
      _data.add(e);
    }

    List<charts.Series<WorkoutDataPoint, DateTime>> _dataSeries = _getDataPointsList(_data);

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

  List<charts.Series<WorkoutDataPoint, DateTime>> _getDataPointsList(List<WorkoutData> data) {
    final List<WorkoutDataPoint> setsData = new List<WorkoutDataPoint>();
    for (var d in data) {
      setsData.add(WorkoutDataPoint(DateTime.parse(d.dateTimeIso8601), d.sets, d.repetitions, d.weight, d.uuid));
    }
    final List<WorkoutDataPoint> repsData = new List<WorkoutDataPoint>();
    for (var d in data) {
      repsData.add(WorkoutDataPoint(DateTime.parse(d.dateTimeIso8601), d.sets, d.repetitions, d.weight, d.uuid));
    }
    final List<WorkoutDataPoint> weightData = new List<WorkoutDataPoint>();
    for (var d in data) {
      weightData.add(WorkoutDataPoint(DateTime.parse(d.dateTimeIso8601), d.sets, d.repetitions, d.weight, d.uuid));
    }

    List<charts.Series<WorkoutDataPoint, DateTime>> l = new List<charts.Series<WorkoutDataPoint, DateTime>>();

    l.add(
      new charts.Series<WorkoutDataPoint, DateTime>(
        id: 'Sets',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WorkoutDataPoint data, _) => data.dateTime,
        measureFn: (WorkoutDataPoint data, _) => data.sets,
        data: setsData,
      ),
    );
    l.add(
      new charts.Series<WorkoutDataPoint, DateTime>(
        id: 'Reps',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (WorkoutDataPoint data, _) => data.dateTime,
        measureFn: (WorkoutDataPoint data, _) => data.repetitions,
        data: repsData,
      ),
    );
    if (!widget.workout.useBodyWeight) {
      l.add(
        new charts.Series<WorkoutDataPoint, DateTime>(
          id: 'Weight',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (WorkoutDataPoint data, _) => data.dateTime,
          measureFn: (WorkoutDataPoint data, _) => data.weight,
          data: weightData,
        ),
      );
    }

    return l;
  }

  _onSelectionChanged(charts.SelectionModel model) {
    if (model.hasDatumSelection) {
      var d = model.selectedDatum[0];

      var w = WorkoutData(widget.workout.uuid, d.datum.dateTime.toIso8601String(), d.datum.sets, d.datum.repetitions, d.datum.weight);
      w.uuid = d.datum.uuid;
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          EditWorkoutDataPage(workout: widget.workout, workoutData: w)));
    }
  }

  deleteAllWorkoutData() async {
    switch(
      await CustomAlertDialog.showYesNoAlert('You will loose all progress of this Workout!\n\nDo you really want to delete it?', context, yesColor: Colors.red)
    )
    {
      case AlertReturnDecide.Yes:
        await DatabaseProvider.db.deleteWorkoutDataOfWorkout(widget.workout.uuid);
        setState(() {}); // Rebuild the Widgets
        break;
      case AlertReturnDecide.No: // Stay here, do nothing
        break;
    }
  }
}
