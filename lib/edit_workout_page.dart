import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';

import 'package:better_life/workout.dart';
import 'package:better_life/image_helper.dart';
import 'package:better_life/horizontal_number_picker.dart';
import 'package:better_life/database.dart';
import 'package:better_life/alert_yes_no.dart';

class ModifyWorkoutPage extends StatefulWidget {
  ModifyWorkoutPage({this.workout});

  final Workout workout;

  @override
  _ModifyWorkoutPageState createState() => _ModifyWorkoutPageState();
}

class _ModifyWorkoutPageState extends State<ModifyWorkoutPage> {
  final nameController = TextEditingController();
  int setsAmount;
  int repsAmount;
  int weightAmount;
  bool useBodyweight;

  final _formKey = GlobalKey<FormState>();

  File _image = new File("");

  @override
  initState() {
    super.initState();

    setState(() {
      setsAmount = widget.workout.sets;
      repsAmount = widget.workout.repetitions;
      weightAmount = widget.workout.weight;
      useBodyweight = widget.workout.useBodyWeight;
      nameController.text = widget.workout.name;
      _image = widget.workout.imageFilePath.isEmpty ? File("") : File(widget.workout.imageFilePath);
    });
  }

  Future getImageFromPickerDialog() async {
    File image;

    var choice = await ImageHelper.getImageSource(context);

    if (choice == GetImageSource.Camera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else if (choice == GetImageSource.Gallery) {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else if (choice == GetImageSource.Reset) {
      if (_image != image) {
        setState(() {
          _image = null;
        });
      }
    }

    if (image != null) {
      if (_image != image) {
        setState(() {
          _image = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text('Edit Workout',),
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
              workoutForm,
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
      child: IconButton(
        icon: Icon(Icons.edit),
        tooltip: 'Change the photo',
        alignment: Alignment.bottomRight,
        color: Colors.white,
        onPressed: getImageFromPickerDialog,
      ),
    );
  }

  Widget get workoutForm {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField( // Name
            controller: nameController,
            decoration: const InputDecoration(
                icon: Icon(Icons.title),
                hintText: 'What should the Workout be called?',
                labelText: 'Workout Name'
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name';
              }
            },
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
              CheckboxListTile(
                title: Text('Use Bodyweight'),
                value: useBodyweight,
                onChanged: (bool value) {
                  setState(() {
                    useBodyweight = value;
                  });
                },
              ),
              Visibility(
                visible: !useBodyweight,
                child: HorizontalNumberPicker(
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
                    Workout w = Workout(nameController.text, setsAmount, repsAmount, weightAmount, useBodyweight, _image == null ? "" : _image.path);
                    w.uuid = widget.workout.uuid;

                    await DatabaseProvider.db.updateWorkout(w);
                    Navigator.of(context).pop();
                  }
                }),
                child: Text('Save Workout'),
              ),
              VerticalDivider(),
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    Workout w = Workout(nameController.text, setsAmount, repsAmount, weightAmount, useBodyweight, _image == null ? "" : _image.path);
                    w.uuid = widget.workout.uuid;

                    switch(
                      await CustomAlertDialog.showYesNoAlert('You will loose this Workout!\n\nDo you really want to delete it?', context, yesColor: Colors.red)
                    )
                    {
                      case AlertReturnDecide.Yes:
                        await DatabaseProvider.db.deleteWorkout(w, deleteWorkoutDataPoints: true);
                        await _showDeleteSuccess();
                        Navigator.of(context).pop();
                        break;
                      case AlertReturnDecide.No: // Stay here, do nothing
                        break;
                    }
                  }
                }),
                child: Text(
                  'Delete Workout',
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

  _showDeleteSuccess() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          elevation: 5.0,
          title: AutoSizeText(
            'Success',
            style: TextStyle(
              fontSize: 20.0,
            ),
            maxLines: 1,
            minFontSize: 15.0,
          ),
          content: AutoSizeText(
            'The Workout and all its data was deleted.',
            style: TextStyle(
              fontSize: 20.0,
            ),
            maxLines: 3,
            minFontSize: 15.0,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      }
    );
  }
}
