import 'package:flutter/material.dart';

import 'package:better_life/workout.dart';

class ViewWorkoutStatisticsPage extends StatefulWidget {
  ViewWorkoutStatisticsPage({this.workout});

  final Workout workout;

  @override
  _ViewWorkoutStatisticsPageState createState() => _ViewWorkoutStatisticsPageState();
}

class _ViewWorkoutStatisticsPageState extends State<ViewWorkoutStatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Statistics',),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Return',),
        ),
      ),
    );
  }
}
