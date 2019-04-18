import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:better_life/MIGRATED_workout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/MIGRATED_image_helper.dart';
import 'package:better_life/MIGRATED_horizontal_number_picker.dart';
import 'package:better_life/MIGRATED_database.dart';
import 'package:better_life/workout_data.dart';
import 'package:better_life/MIGRATED_alert_yes_no.dart';

class EditWorkoutDataPage extends StatefulWidget {
  EditWorkoutDataPage({this.workout, this.workoutData});

  final Workout workout;
  final WorkoutData workoutData;

  @override
  _EditWorkoutDataPageState createState() => _EditWorkoutDataPageState();
}

class _EditWorkoutDataPageState extends State<EditWorkoutDataPage> {
  int setsAmount;
  int repsAmount;
  int weightAmount;
  bool useBodyweight;
  String workoutName;

  final _formKey = GlobalKey<FormState>();

  File _image = new File("");

  DateTime _date = DateTime.now();

  @override
  initState() {
    super.initState();

    setState(() {
      setsAmount = widget.workoutData.sets;
      repsAmount = widget.workoutData.repetitions;
      weightAmount = widget.workoutData.weight;
      useBodyweight = widget.workout.useBodyWeight;
      workoutName = widget.workout.name;
      _image = widget.workout.imageFilePath.isEmpty ? File("") : File(widget.workout.imageFilePath);
      _date = DateTime.parse(widget.workoutData.dateTimeIso8601);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Edit Workout-Data',),
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
              Divider(),
              workoutImage,
              Divider(),
              workoutDataForm,
            ],
          ),
        ),
      ),
    );
  }

  Widget get workoutImage {
    return Container(
      height: MediaQuery.of(context).size.width / 3.0,
      width: MediaQuery.of(context).size.width / 3.0,
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

  Widget get workoutDataForm {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DateTimePickerFormField(
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
          Divider(),
          Text('Sets'),
          HorizontalNumberPicker(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.isTight
                    ? Container() : HorizontalSlider(
                  width: constraints.maxWidth,
                  value: setsAmount,
                  onChanged: (val) => setState(() => setsAmount = val),
                );
              },
            ),
          ),
          Divider(),
          Text('Repetitions'),
          HorizontalNumberPicker(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.isTight
                    ? Container() : HorizontalSlider(
                  width: constraints.maxWidth,
                  value: repsAmount,
                  onChanged: (val) => setState(() => repsAmount = val),
                );
              },
            ),
          ),
          Column(
            children: <Widget>[
              Divider(),
              Text('Weight'),
              useBodyweight // If active only show Text "Use Bodyweight" otherwise show a HorizontalNumberPicker
                  ? Text('Uses Bodyweight')
                  : HorizontalNumberPicker(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.isTight
                        ? Container() : HorizontalSlider(
                      width: constraints.maxWidth,
                      value: weightAmount,
                      onChanged: (val) => setState(() => weightAmount = val),
                    );
                  },
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    widget.workoutData.dateTimeIso8601 = _date.toIso8601String();
                    widget.workoutData.sets = setsAmount;
                    widget.workoutData.repetitions = repsAmount;
                    widget.workoutData.weight = weightAmount;
                    await DatabaseProvider.db.updateWorkoutData(widget.workoutData);
                    Navigator.of(context).pop();
                  }
                }),
                child: Text('Save Workout-Data'),
              ),
              VerticalDivider(),
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    switch(
                    await CustomAlertDialog.showYesNoAlert('You will loose this Workout-Data!\n\nDo you really want to delete it?', context, yesColor: Colors.red)
                    )
                    {
                      case AlertReturnDecide.Yes:
                        await DatabaseProvider.db.deleteSingleWorkoutData(widget.workoutData.uuid);
                        Navigator.of(context).pop();
                        break;
                      case AlertReturnDecide.No: // Stay here, do nothing
                        break;
                    }
                  }
                }),
                child: Text(
                  'Delete Workout-Data',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
