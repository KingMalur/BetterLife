import 'package:flutter/material.dart';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:better_life/widgets/models/ChartDataPoint.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/database/models/WorkoutSection.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/widgets/ImageHelper.dart';
import 'package:better_life/widgets/HorizontalNumberPicker.dart';

class EditWorkoutData extends StatefulWidget {
  EditWorkoutData({this.workout, this.dataPointMap, this.dataPointsToEdit});

  final Workout workout;
  final Map<String, ChartDataPoint> dataPointsToEdit;
  final Map<String, ChartDataPoint> dataPointMap;

  @override
  _EditWorkoutDataState createState() => _EditWorkoutDataState();
}

class _EditWorkoutDataState extends State<EditWorkoutData> {
  Map<String, int> _sections = new Map<String, int>(); // Key-Value-Storage for Sections and their Value
  List<WorkoutSection> _sectionList = new List<WorkoutSection>(); // List of Sections to generate Widgets
  List<Widget> _sectionWidgetList = new List<Widget>(); // List of Widgets of Sections

  DateTime _date = DateTime.now();
  final _formKeyDate = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _initSections();
  }

  _initSections() {
    widget.dataPointsToEdit.forEach((String key, ChartDataPoint value) async {
      _date = value.dateTime;
      var section = await DatabaseHelper.db.getWorkoutSection(workoutSectionUuid: value.workoutSectionUuid);
      if (section != null) {
        _sectionList.add(section);

        if (!_sections.containsKey(section.workoutSectionUuid)) {
          _sections[section.workoutSectionUuid] = value.value;
        }

        setState(() {});
      }
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
      title: Text('Edit Workout Data'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: (() async {
                    Navigator.of(context).pop();
                  }),
                  child: Text('Save Workout Data'),
                ),
                VerticalDivider(),
                RaisedButton(
                  onPressed: (() async {
                    Navigator.of(context).pop();
                  }),
                  child: Text('Delete Workout Data', style: TextStyle(color: Colors.red),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _workoutImage {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
      width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey,
        borderRadius: BorderRadiusDirectional.circular(5.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: ImageHelper.getImageProvider(File(widget.workout.imageFilePath)),
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

  Widget get _workoutSections {
    if (_sectionList != null) {
      _sectionWidgetList.clear();
      _sectionList.sort((a, b) => a.name.compareTo(b.name));
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
