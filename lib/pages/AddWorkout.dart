import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:better_life/widgets/ImageHelper.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/pages/AddWorkoutSection.dart';
import 'package:better_life/pages/EditWorkoutSection.dart';
import 'package:better_life/database/models/WorkoutSection.dart';

class AddWorkout extends StatefulWidget {
  AddWorkout({this.alreadyPresentCardList});

  final List<Workout> alreadyPresentCardList;

  final workoutUuid = Uuid().v4();

  @override
  _AddWorkoutState createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<WorkoutSection> _workoutSectionList = new List<WorkoutSection>();

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
            _workoutImage,
            Divider(color: Colors.black45,),
            _workoutForm,
          ],
        ),
      ),
    );
  }

  Widget get _workoutForm {
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
            maxLength: 40,
            maxLengthEnforced: true,
          ),
          Divider(color: Colors.black45,),
          _getWorkoutSectionFormFieldList(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var section = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  AddWorkoutSection(workoutUuid: widget.workoutUuid, alreadyPresentSectionList: _workoutSectionList,)));
              if (section != null) {
                _workoutSectionList.add(section);
              }
              setState(() {
                _workoutSectionList;
              });
            },
          ),
          Divider(color: Colors.black45,),
          RaisedButton(
            onPressed: (() async {
              if (_formKey.currentState.validate()) {
                Workout w = Workout(workoutUuid: widget.workoutUuid, tagUuid: "", name: _nameController.text,imageFilePath: _image == null ? "" : _image.path);
                bool exists = false;

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

                  for (var e in _workoutSectionList) {
                    await DatabaseHelper.db.insertWorkoutSection(workoutSection: e);
                  }

                  Navigator.of(context).pop(w);
                }
              }
            }),
            child: Text('Save Workout'),
          ),
        ],
      ),
    );
  }

  Widget get _workoutImage {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
      width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75,
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
    if (_workoutSectionList.isNotEmpty) {
      var l = new List<Container>();
      for (var e in _workoutSectionList) {
        l.add(Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeText(
                e.name,
                style: TextStyle(
                  fontSize: 20.0,
                ),
                maxLines: 1,
                minFontSize: 10.0,
                maxFontSize: 20.0,
                overflow: TextOverflow.fade,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          EditWorkoutSection(alreadyPresentSectionList: _workoutSectionList, sectionToEdit: e,)));
                      setState(() {
                        _workoutSectionList;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _workoutSectionList.remove(e);
                      setState(() {
                        _workoutSectionList;
                      });
                    },
                  ),
                ],
              ),
              Divider(color: Colors.black45,),
            ],
          ),
        ));
      }

      return Column(
        children: l,
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }
}
