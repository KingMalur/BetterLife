import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life/widgets/HorizontalNumberPicker.dart';
import 'package:better_life/database/models/WorkoutSection.dart';
import 'package:better_life/widgets/CustomAlertDialog.dart';
import 'package:better_life/database/DatabaseHelper.dart';

class AddWorkoutSection extends StatefulWidget {
  AddWorkoutSection({this.workoutUuid, this.alreadyPresentSectionList, this.addSection = true, this.sectionToEdit = null});

  final String workoutUuid;
  final List<WorkoutSection> alreadyPresentSectionList;

  final bool addSection;
  final WorkoutSection sectionToEdit;

  @override
  _AddWorkoutSectionState createState() => _AddWorkoutSectionState();
}

class _AddWorkoutSectionState extends State<AddWorkoutSection> {
  TextEditingController nameController;

  final formKey = GlobalKey<FormState>();

  String sectionUuid;
  int minValue;
  int maxValue;

  String originalSectionName;

  @override
  void initState() {
    super.initState();

    sectionUuid = widget.addSection ? Uuid().v4() : widget.sectionToEdit.workoutSectionUuid;
    minValue = widget.addSection ? 1 : widget.sectionToEdit.minValue;
    maxValue = widget.addSection ? 999 : widget.sectionToEdit.maxValue;
    nameController = new TextEditingController();
    nameController.text = widget.addSection ? "" : widget.sectionToEdit.name;
    originalSectionName = widget.addSection ? "" : widget.sectionToEdit.name;
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
      title: widget.addSection ? Text('Add Section') : Text('Edit Section'),
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
              TextField( // Name
                controller: nameController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.title),
                    hintText: 'What should the Section be called?',
                    labelText: 'Section Name'
                ),
                keyboardType: TextInputType.text,
                maxLength: 40,
              ),
              Divider(),
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
              Divider(),
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
              Divider(),
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

                        if (section.name != originalSectionName) {
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
                  RaisedButton(
                    disabledColor: Colors.black26,
                    onPressed: widget.addSection ? null : (() async {
                      if (formKey.currentState.validate()) {
                        WorkoutSection section = WorkoutSection(
                            name: nameController.text,
                            workoutSectionUuid: sectionUuid,
                            minValue: minValue,
                            maxValue: maxValue,
                            workoutUuid: widget.workoutUuid
                        );

                        switch(
                        await CustomAlertDialog.showYesNoAlert('You will loose this Section!\n\nDo you really want to delete it?', context, yesColor: Colors.red)
                        )
                        {
                          case AlertReturnDecide.Yes:
                            await DatabaseHelper.db.deleteWorkoutSection(workoutSectionUuid: section.workoutSectionUuid);
                            Navigator.of(context).pop();
                            break;
                          case AlertReturnDecide.No: // Stay here, do nothing
                            break;
                        }
                      }
                    }),
                    child: Text('Delete Section'),
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
