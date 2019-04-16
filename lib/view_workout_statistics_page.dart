import 'package:flutter/material.dart';
import 'dart:io';

import 'package:better_life/workout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/image_helper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:better_life/database.dart';
import 'package:better_life/workout_data.dart';
import 'package:better_life/workout_data_point.dart';

class ViewWorkoutStatisticsPage extends StatefulWidget {
  ViewWorkoutStatisticsPage({this.workout});

  final Workout workout;

  @override
  _ViewWorkoutStatisticsPageState createState() => _ViewWorkoutStatisticsPageState();
}

class _ViewWorkoutStatisticsPageState extends State<ViewWorkoutStatisticsPage> {
  File _image = new File("");

  @override
  initState() {
    super.initState();

    setState(() {
      _image = widget.workout.imageFilePath.isEmpty ? File("") : File(
          widget.workout.imageFilePath);
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
              //Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget get workoutImage {
    return Container(
      height: MediaQuery.of(context).size.width / 4.0,
      width: MediaQuery.of(context).size.width / 4.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.black26,
        borderRadius: BorderRadiusDirectional.circular(5.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: ImageHelper.getImageProvider(_image == null ? File("") : _image),
        ),
      ),
    );
  }

  Widget get workoutDiagram {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8.0),
      child: new FutureBuilder(//_buildWorkoutCardList(widget._workouts),
      future: DatabaseProvider.db.getWorkoutDataPointsOfWorkout(widget.workout.uuid),
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
      animate: false,
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

  _onSelectionChanged(charts.SelectionModel model) async {
    if (model.hasDatumSelection) {
      var d = model.selectedDatum[0];
      String id = d.datum.uuid;

      await showDialog(
          context: context,
          builder: (BuildContext context) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          elevation: 5.0,
          title: AutoSizeText(
            'Success',
            style: TextStyle(
              fontSize: 20.0,
            ),
            maxLines: 1,
            minFontSize: 15.0,
          ),
          content: AutoSizeText(
            'The selected Workout-Data is: ' + d.datum.uuid + '\nDate: ' + d.datum.dateTime.toIso8601String() + '\nSets: ' + d.datum.sets.toString() + '\nReps: ' + d.datum.repetitions.toString() + '\nWeight: ' + d.datum.weight.toString(),
            style: TextStyle(
              fontSize: 15.0,
            ),
            maxLines: 10,
            minFontSize: 10.0,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      }
    );
    }
  }
}
