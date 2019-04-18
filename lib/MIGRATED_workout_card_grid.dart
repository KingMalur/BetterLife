import 'package:flutter/material.dart';

import 'package:better_life/MIGRATED_workout.dart';
import 'package:better_life/MIGRATED_workout_card.dart';

class WorkoutCardGrid extends StatefulWidget {
  final List<Workout> workoutList;

  WorkoutCardGrid({this.workoutList});

  @override
  _WorkoutCardGridState createState() => _WorkoutCardGridState();
}

class _WorkoutCardGridState extends State<WorkoutCardGrid> {
  @override
  Widget build(BuildContext context) {
    return buildCards();
  }

  Widget buildCards() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
      childAspectRatio: 10 / 9,
      padding: EdgeInsets.all(10.0),
      children: _getWorkoutCards(),
    );
  }

  _getWorkoutCards() {
    var list = new List<Widget>();

    for (var w in widget.workoutList) {
      list.add(WorkoutCard(workout: w,));
    }

    return list;
  }
}
