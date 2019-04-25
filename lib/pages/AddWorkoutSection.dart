import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life/widgets/HorizontalNumberPicker.dart';
import 'package:better_life/database/models/WorkoutSection.dart';

class AddWorkoutSection extends StatefulWidget {
  AddWorkoutSection({this.workoutUuid, this.alreadyPresentSectionList});

  final String workoutUuid;
  final List<WorkoutSection> alreadyPresentSectionList;

  @override
  _AddWorkoutSectionState createState() => _AddWorkoutSectionState();
}

class _AddWorkoutSectionState extends State<AddWorkoutSection> {
  final TextEditingController nameController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  final String sectionUuid = Uuid().v4(); // Generate one time on build and one time only!
  int minValue = 1;
  int maxValue = 999;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Add Section'),
      backgroundColor: Colors.black45,
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField( // Name
                controller: nameController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.title),
                    hintText: 'What should the Section be called?',
                    labelText: 'Section Name'
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                },
                maxLength: 40,
                maxLengthEnforced: true,
              ),
              Divider(color: Colors.black45,),
              Text('Minimal Value'),
              HorizontalNumberPicker(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.isTight
                        ? Container() : HorizontalSlider(
                      width: constraints.maxWidth,
                      value: minValue,
                      onChanged: (val) => setState(() => minValue = val),
                    );
                  },
                ),
              ),
              Divider(color: Colors.black45,),
              Text('Maximal Value'),
              HorizontalNumberPicker(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.isTight
                        ? Container() : HorizontalSlider(
                      width: constraints.maxWidth,
                      value: maxValue,
                      onChanged: (val) => setState(() => maxValue = val),
                    );
                  },
                ),
              ),
              Divider(color: Colors.black45,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    onPressed: (() async {
                      if (formKey.currentState.validate()) {
                        WorkoutSection section = WorkoutSection(
                            name: nameController.text,
                            workoutSectionUuid: sectionUuid,
                            minValue: minValue,
                            maxValue: maxValue,
                            workoutUuid: widget.workoutUuid
                        );

                        bool exists = false;

                        if (widget.alreadyPresentSectionList != null) {
                          for (var e in widget.alreadyPresentSectionList) {
                            if (e.name == section.name) {
                              exists = true;
                              break;
                            }
                          }
                        }

                        if (exists) {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  elevation: 5.0,
                                  title: Text('Error saving Section'),
                                  content: Text('A Section of name ' + section.name + ' already exists.'),
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
                          Navigator.of(context).pop(section);
                        }
                      }
                    }),
                    child: Text('Save Section'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*


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


*/
