import 'package:flutter/material.dart';

import 'package:better_life/MIGRATED_workout.dart';
import 'package:better_life/MIGRATED_workout_card.dart';

class WorkoutCardList extends StatefulWidget {
  final List<Workout> workoutList;

  WorkoutCardList({this.workoutList});

  @override
  _WorkoutCardListState createState() => _WorkoutCardListState();
}

class _WorkoutCardListState extends State<WorkoutCardList> {
  @override
  Widget build(BuildContext context) {
    return buildCards();
  }
  
  Widget buildCards() {
    return new ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemBuilder: (context, i) {
          return WorkoutCard(workout: widget.workoutList[i],);
        //for (Workout w in widget.workoutList) {
        //  widget.workoutCardList.add()
      },
      itemCount: widget.workoutList.length,
    );
  }
}
