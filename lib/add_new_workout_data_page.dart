import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:better_life/workout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/image_helper.dart';
import 'package:better_life/horizontal_number_picker.dart';
import 'package:better_life/database.dart';
import 'package:better_life/workout_data.dart';

class AddNewWorkoutDataPage extends StatefulWidget {
  AddNewWorkoutDataPage({this.workout});

  final Workout workout;

  @override
  _AddNewWorkoutDataPageState createState() => _AddNewWorkoutDataPageState();
}

class _AddNewWorkoutDataPageState extends State<AddNewWorkoutDataPage> {
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
      setsAmount = widget.workout.sets;
      repsAmount = widget.workout.repetitions;
      weightAmount = widget.workout.weight;
      useBodyweight = widget.workout.useBodyWeight;
      workoutName = widget.workout.name;
      _image = widget.workout.imageFilePath.isEmpty ? File("") : File(widget.workout.imageFilePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Add new Workout-Data',),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              workoutImage,
              Divider(),
              AutoSizeText(
                workoutName,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                maxLines: 1,
                minFontSize: 15.0,
              ),
              Divider(),
              workoutDataForm,
              //Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget get workoutImage {
    return Container(
      height: MediaQuery.of(context).size.width / 2.0,
      width: MediaQuery.of(context).size.width / 2.0,
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
            format: DateFormat("EEEE, MMMM d, yyyy 'um' h:mma"),
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
                  minValue: 1,
                  maxValue: 20,
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
                  minValue: 1,
                  maxValue: 50,
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
                      minValue: 1,
                      maxValue: 250,
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
          RaisedButton(
            onPressed: (() async {
              if (_formKey.currentState.validate()) {
                WorkoutData data = WorkoutData(widget.workout.uuid, _date.toIso8601String(), setsAmount, repsAmount, weightAmount);
                await DatabaseProvider.db.insertWorkoutData(data);
                Navigator.of(context).pop();
              }
            }),
            child: Text('Save Workout-Data'),
          ),
        ],
      ),
    );
  }
}
