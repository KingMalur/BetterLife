import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/pages/AddWorkoutData.dart';
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
                        AddWorkoutData(workout: widget.workout,)));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _updateTimeSpan(int selectedTimeSpan) {
    setState(() {
      _currentTimeSpan = selectedTimeSpan;
    });
  }

  List<DropdownMenuItem<int>> _getTimeSpanItems() {
    return [
      new DropdownMenuItem(child: Text('Last 3 Months'), value: 3,),
      new DropdownMenuItem(child: Text('Last 6 Months'), value: 6,),
      new DropdownMenuItem(child: Text('Last 12 Months'), value: 12,),
      new DropdownMenuItem(child: Text('All Time'), value: 0,),
    ];
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
    int days;

    if (_currentTimeSpan == 0) {
      // Get days since year one
      days = DateTime.now().difference(DateTime(0)).inDays;
    } else {
      var now = DateTime.now();
      days = DateTime.now().difference(DateTime(now.year, now.month - _currentTimeSpan, now.day)).inDays;
    }

    return WorkoutDiagram(workoutUuid: widget.workout.workoutUuid, timeSpanInDays: days);
  }
}
