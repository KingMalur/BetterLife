import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:better_life/widgets/ImageHelper.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/pages/AddWorkoutSection.dart';
import 'package:better_life/pages/EditWorkoutSection.dart';
import 'package:better_life/database/models/WorkoutSection.dart';
import 'package:better_life/widgets/CustomAlertDialog.dart';

class EditWorkout extends StatefulWidget {
  EditWorkout({this.workout});

  final Workout workout;

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<WorkoutSection> _workoutSectionList = new List<WorkoutSection>();
  List<String> _workoutSectionToDeleteList = new List<String>();

  File _image;

  @override
  initState() {
    super.initState();

    _image = File(widget.workout.imageFilePath);
    _nameController.text = widget.workout.name;
    DatabaseHelper.db.getWorkoutSectionListOfWorkout(workoutUuid: widget.workout.workoutUuid).then((List<WorkoutSection> l) {
      if (l != null) {
        _workoutSectionList = l;
        _workoutSectionList.sort((a, b) => a.name.compareTo(b.name));
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
      title: Text('Add Workout'),
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
            Divider(),
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
          Divider(),
          _getWorkoutSectionFormFieldList(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var section = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  AddWorkoutSection(workoutUuid: widget.workout.workoutUuid, alreadyPresentSectionList: _workoutSectionList,)));
              if (section != null) {
                _workoutSectionList.add(section);
              }
              setState(() {});
            },
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    Workout w = Workout(workoutUuid: widget.workout.workoutUuid, tagUuid: "", name: _nameController.text, imageFilePath: _image == null ? "" : _image.path);

                    var exists = false;

                    if (widget.workout.name != w.name) {
                      exists = await DatabaseHelper.db.getWorkoutOfName(name: w.name) == null ? false : true;
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
                      await DatabaseHelper.db.updateWorkout(workout: w);

                      for (var e in _workoutSectionList) {
                        await DatabaseHelper.db.upsertWorkoutSection(workoutSection: e);
                      }

                      for (var e in _workoutSectionToDeleteList) {
                        await DatabaseHelper.db.deleteWorkoutSection(workoutSectionUuid: e);
                      }

                      Navigator.of(context).pop(w);
                    }
                  }
                }),
                child: Text('Save Workout'),
              ),
              VerticalDivider(),
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    switch(
                    await CustomAlertDialog.showYesNoAlert('You will loose this Workout!\n\nDo you really want to delete it?', context)
                    )
                    {
                      case AlertReturnDecide.Yes:
                        await DatabaseHelper.db.deleteWorkout(workoutUuid: widget.workout.workoutUuid);
                        Navigator.of(context).pop();
                        break;
                      case AlertReturnDecide.No: // Stay here, do nothing
                        break;
                    }
                  }
                }),
                child: Text('Delete Workout', style: TextStyle(color: Colors.red),),
              ),
            ],
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
        color: Colors.grey,
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
    var l = new List<Container>();
    if (_workoutSectionList != null) {
      _workoutSectionList.sort((a, b) => a.name.compareTo(b.name));
      for (var w in _workoutSectionList) {
        l.add(Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeText(
                w.name,
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
                      await Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          EditWorkoutSection(
                            alreadyPresentSectionList: _workoutSectionList,
                            sectionToEdit: w,)));
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (() async {
                      switch(
                      await CustomAlertDialog.showYesNoAlert('You will loose this Section!\n\nDo you really want to delete it?', context)
                      )
                      {
                        case AlertReturnDecide.Yes:
                          _workoutSectionToDeleteList.add(w.workoutSectionUuid);
                          _workoutSectionList.remove(w);
                          break;
                        case AlertReturnDecide.No: // Stay here, do nothing
                          break;
                      }
                      setState(() {});
                    }),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ));
      }
    }
    if (_workoutSectionList != null) {
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
