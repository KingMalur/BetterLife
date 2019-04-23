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

  File _image;

  @override
  initState() {
    super.initState();

    _image = File(widget.workout.imageFilePath);
    _nameController.text = widget.workout.name;
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
            maxLength: 40,
            maxLengthEnforced: true,
          ),
          Divider(color: Colors.black45,),
          _getWorkoutSectionFormFieldList(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var section = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  AddWorkoutSection(workoutUuid: widget.workout.workoutUuid, alreadyPresentSectionList: _workoutSectionList,)));
              if (section != null) {
                await DatabaseHelper.db.insertWorkoutSection(workoutSection: section);
                _workoutSectionList.add(section);
              }
              setState(() {
                _workoutSectionList;
              });
            },
          ),
          Divider(color: Colors.black45,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: (() async {
                  if (_formKey.currentState.validate()) {
                    Workout w = Workout(workoutUuid: widget.workout.workoutUuid, tagUuid: "", name: _nameController.text, imageFilePath: _image == null ? "" : _image.path);

                    var exists = false;

                    if (widget.workout.name != w.name) {
                      exists = DatabaseHelper.db.getWorkoutOfName(name: _nameController.text) == null ? false : true;
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
                    await CustomAlertDialog.showYesNoAlert('You will loose this Workout!\n\nDo you really want to delete it?', context, yesColor: Colors.red)
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
    return FutureBuilder(
      future: DatabaseHelper.db.getWorkoutSectionListOfWorkout(workoutUuid: widget.workout.workoutUuid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        _workoutSectionList.clear();
        var l = new List<Container>();
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            for (WorkoutSection w in snapshot.data) {
              _workoutSectionList.add(w);
              l.add(Container(
                width: MediaQuery.of(context).size.width,
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
                            await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                EditWorkoutSection(alreadyPresentSectionList: _workoutSectionList, sectionToEdit: w,)));
                            setState(() {
                              _workoutSectionList;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            _workoutSectionList.remove(w);
                            await DatabaseHelper.db.deleteWorkoutSection(workoutSectionUuid: w.workoutSectionUuid);
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
          }
        }
        if (_workoutSectionList.isNotEmpty) {
          return Column(
            children: l,
          );
        } else {
          return Container(
            height: 0,
          );
        }
      },
    );
  }
}
