import 'package:flutter/material.dart';

import 'package:better_life/workout.dart';

class AddNewWorkoutDataPage extends StatefulWidget {
  AddNewWorkoutDataPage({this.workout});

  Workout workout;

  @override
  _AddNewWorkoutDataPageState createState() => _AddNewWorkoutDataPageState();
}

class _AddNewWorkoutDataPageState extends State<AddNewWorkoutDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Add new Workout-Data',),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Save Workout-Data',),
        ),
      ),
    );
  }
}
