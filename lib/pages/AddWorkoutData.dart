import 'package:flutter/material.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/widgets/ImageHelper.dart';
import 'package:better_life/database/models/WorkoutData.dart';
import 'package:better_life/database/models/DataPoint.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/HorizontalNumberPicker.dart';
import 'package:better_life/database/models/WorkoutSection.dart';

class AddWorkoutData extends StatefulWidget {
  AddWorkoutData({this.workout});

  final Workout workout;

  @override
  _AddWorkoutDataState createState() => _AddWorkoutDataState();
}

class _AddWorkoutDataState extends State<AddWorkoutData> {
  final String _workoutDataUuid = Uuid().v4();

  DateTime _date = DateTime.now();
  final _formKeyDate = GlobalKey<FormState>();

  Map<String, int> _sections = new Map<String, int>(); // Key-Value-Storage for Sections and their Value
  List<WorkoutSection> _sectionList = new List<WorkoutSection>(); // List of Sections to generate Widgets
  List<Widget> _sectionWidgetList = new List<Widget>(); // List of Widgets of Sections

  @override
  initState() {
    super.initState();

    DatabaseHelper.db.getWorkoutSectionListOfWorkout(workoutUuid: widget.workout.workoutUuid).then((List<WorkoutSection> l) async {
      if (l == null) {
        return;
      }

      for (WorkoutSection s in l) {
        await DatabaseHelper.db.getLatestWorkoutData(workoutUuid: s.workoutUuid).then((WorkoutData data) async {
          if (data == null) {
            return;
          }

          await DatabaseHelper.db.getDataPointOfWorkoutDataAndWorkoutSection(workoutDataUuid: data.workoutDataUuid, workoutSectionUuid: s.workoutSectionUuid).then((DataPoint p) {
            if (p == null) {
              return;
            }

            if (!_sections.containsKey(s.workoutSectionUuid)) {
              _sections[s.workoutSectionUuid] = p.value; // Add Value if exists
            }

          });
        });

        if (!_sections.containsKey(s.workoutSectionUuid)) {
          _sections[s.workoutSectionUuid] = s.minValue;
        }

        _sectionList.add(s);
      }

      if (_sectionList != null) {
        _sectionList.sort((a, b) => a.name.compareTo(b.name));
      }

      setState(() {});
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
      title: Text('Add Workout Data'),
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
            _workoutImage,
            Divider(),
            _dateTime,
            Divider(),
            _workoutSections,
            RaisedButton(
              onPressed: (() async {
                var workoutData = WorkoutData(workoutUuid: widget.workout.workoutUuid, workoutDataUuid: _workoutDataUuid, dateTimeIso8601: _date.toIso8601String());
                await DatabaseHelper.db.insertWorkoutData(workoutData: workoutData);

                _sections.forEach((key, value) async {
                  DataPoint dataPoint = DataPoint(dataPointUuid: Uuid().v4(), workoutDataUuid: _workoutDataUuid, workoutSectionUuid: key, value: value);
                  await DatabaseHelper.db.insertDataPoint(dataPoint: dataPoint);
                });

                Navigator.of(context).pop();
              }),
              child: Text('Save Workout Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _dateTime {
    return Form(
      key: _formKeyDate,
      child: DateTimePickerFormField(
        inputType: InputType.both,
        format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
        editable: false,
        decoration: InputDecoration(
          labelText: 'Date/Time',
          hasFloatingPlaceholder: false,
        ),
        initialValue: _date,
        onChanged: (dt) => setState(() => _date = dt),
      ),
    );
  }

  Widget get _workoutImage {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
      width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadiusDirectional.circular(5.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: ImageHelper.getImageProvider(File(widget.workout.imageFilePath)),
        ),
      ),
    );
  }

  Widget get _workoutSections {
    if (_sectionList != null) {
      _sectionWidgetList.clear();
      _sectionList.forEach((WorkoutSection s) {
        _sectionWidgetList.add(Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                s.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                maxLines: 1,
                minFontSize: 15.0,
              ),
              HorizontalNumberPicker(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.isTight
                        ? Container() : HorizontalSlider(
                      width: constraints.maxWidth,
                      value: _sections[s.workoutSectionUuid],
                      minValue: s.minValue,
                      maxValue: s.maxValue,
                      onChanged: (val) {
                        _sections[s.workoutSectionUuid] = val;
                        setState(() {}); // Refresh GUI
                      },
                    );
                  },
                ),
              ),
              Divider(),
            ],
          ),
        ));
      });
    }

    if (_sectionWidgetList.isEmpty) {
      _sectionWidgetList.add(Container(height: 0.0, width: 0.0,));
    }

    var col = Column(
      children: _sectionWidgetList,
    );

    return col;
  }
}
