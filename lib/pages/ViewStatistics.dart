import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/WorkoutDiagram.dart';
import 'package:better_life/widgets/CustomAlertDialog.dart';

class ViewStatistics extends StatefulWidget {
  ViewStatistics({this.workout});

  final Workout workout;

  @override
  _ViewStatisticsState createState() => _ViewStatisticsState();
}

class _ViewStatisticsState extends State<ViewStatistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('View Statistics'),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
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
            Divider(),
            workoutDiagram,
            Divider(),
            IconButton(
              icon: Icon(Icons.delete,),
              onPressed: deleteAllWorkoutData,
            ),
          ],
        ),
      ),
    );
  }

  deleteAllWorkoutData() async {
    switch(
    await CustomAlertDialog.showYesNoAlert('You will loose all progress of this Workout!\n\nDo you really want to delete it?', context)
    )
    {
      case AlertReturnDecide.Yes:
        await DatabaseHelper.db.deleteWorkoutDataOfWorkout(workoutUuid: widget.workout.workoutUuid);
        setState(() {}); // Rebuild the Widgets
        break;
      case AlertReturnDecide.No: // Stay here, do nothing
        break;
    }
  }

  Widget get workoutDiagram {
    return WorkoutDiagram(workoutUuid: widget.workout.workoutUuid, selectableDataPoints: true, showTimeSpanOptions: true,);
  }
}
