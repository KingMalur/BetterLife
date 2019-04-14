import 'package:flutter/material.dart';
import 'package:better_life/database.dart';

import 'workout.dart';

class ModifyWorkoutPage extends StatefulWidget {
  ModifyWorkoutPage({this.workout});

  Workout workout;

  @override
  _ModifyWorkoutPageState createState() => _ModifyWorkoutPageState();
}

class _ModifyWorkoutPageState extends State<ModifyWorkoutPage> {
  final testController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Modify Workout',),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'New Workout Name...',
              ),
              controller: testController,
            ),
            RaisedButton(
              onPressed: () {
                if (testController.text.isNotEmpty) {
                  widget.workout.name = testController.text;
                  DatabaseProvider.db.updateWorkout(widget.workout);
                }
                Navigator.pop(context);
              },
              child: Text('Save Workout',),
            ),
            IconButton(
              icon: Icon(Icons.delete,),
              color: Colors.black45,
              onPressed: () {
                DatabaseProvider.db.deleteWorkout(widget.workout);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
