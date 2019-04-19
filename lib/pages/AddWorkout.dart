import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life/widgets/ImageHelper.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/WorkoutSectionFormField.dart';
import 'package:better_life/database/models/WorkoutSection.dart';

class AddWorkout extends StatefulWidget {
  AddWorkout({Key key, this.alreadyPresentCardList}) : super(key: key);

  final List<Workout> alreadyPresentCardList;

  @override
  _AddWorkoutState createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<WorkoutSectionFormField> _workoutSectionFormFieldList = new List<WorkoutSectionFormField>();

  File _image = new File("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Add Workout'),
      backgroundColor: Colors.black45,
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
            workoutImage,
            Divider(),
            workoutForm,
          ],
        ),
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
            controller: _nameController,
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
          _getWorkoutSectionFormFieldList(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewWorkoutSectionFormField,
          ),
          Divider(),
          RaisedButton(
            onPressed: (() async {
              if (_formKey.currentState.validate()) {
                Workout w = Workout(workoutUuid: Uuid().v4(), tagUuid: "", name: _nameController.text,imageFilePath: _image == null ? "" : _image.path);
                bool exists = false;

                for (var e in _workoutSectionFormFieldList) {
                  e.formKey.currentState.validate();
                  if (e.nameController.text.isEmpty) {
                    return;
                  }
                }

                for (var e in widget.alreadyPresentCardList) {
                  if (e.name == w.name) {
                    exists = true;
                    break;
                  }
                }

                if (exists) {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          elevation: 5.0,
                          title: Text('Error saving Workout'),
                          content: Text('A Workout of name ' + w.name + ' already exists.'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      }
                  );
                } else {
                  await DatabaseHelper.db.insertWorkout(workout: w);

                  for (var e in _workoutSectionFormFieldList) {
                    WorkoutSection ws = WorkoutSection(workoutSectionUuid: e.uuid, workoutUuid: w.workoutUuid, name: e.nameController.text);
                    await DatabaseHelper.db.insertWorkoutSection(workoutSection: ws);
                  }

                  widget.alreadyPresentCardList.add(w);
                  Navigator.of(context).pop();
                }
              }
            }),
            child: Text('Save Workout'),
          ),
      ],
    ),
    );
  }

  void _addNewWorkoutSectionFormField() {
    _workoutSectionFormFieldList.add(new WorkoutSectionFormField());
    setState(() {
      _workoutSectionFormFieldList; // Repaint Widget
    });
  }

  Widget get workoutImage {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.0 : MediaQuery.of(context).size.height / 2.0,
      width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.0 : MediaQuery.of(context).size.height / 2.0,
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

  Widget _getWorkoutSectionFormFieldList() {
    if (_workoutSectionFormFieldList.isNotEmpty) {
      return Column(
        children: _workoutSectionFormFieldList,
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }
}
