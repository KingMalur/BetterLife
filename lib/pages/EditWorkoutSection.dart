import 'package:flutter/material.dart';

import 'package:better_life/widgets/HorizontalNumberPicker.dart';
import 'package:better_life/database/models/WorkoutSection.dart';
import 'package:better_life/widgets/CustomAlertDialog.dart';
import 'package:better_life/database/DatabaseHelper.dart';

class EditWorkoutSection extends StatefulWidget {
  EditWorkoutSection({this.alreadyPresentSectionList, this.sectionToEdit});

  final List<WorkoutSection> alreadyPresentSectionList;

  final WorkoutSection sectionToEdit;

  @override
  _EditWorkoutSectionState createState() => _EditWorkoutSectionState();
}

class _EditWorkoutSectionState extends State<EditWorkoutSection> {
  final TextEditingController nameController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  int minValue;
  int maxValue;

  @override
  void initState() {
    super.initState();

    minValue = widget.sectionToEdit.minValue;
    maxValue = widget.sectionToEdit.maxValue;
    nameController.text = widget.sectionToEdit.name;
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
      title: Text('Edit Section'),
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
                        bool exists = false;

                        if (widget.sectionToEdit.name != nameController.text) {
                          if (widget.alreadyPresentSectionList != null) {
                            for (var e in widget.alreadyPresentSectionList) {
                              if (e.name == nameController.text) {
                                exists = true;
                                break;
                              }
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
                                  content: Text('A Section of name ' + nameController.text + ' already exists.'),
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
                          //widget.sectionToEdit.workoutUuid; -> Stays the same!
                          //widget.sectionToEdit.workoutSectionUuid; -> Stays the same!
                          widget.sectionToEdit.minValue = minValue;
                          widget.sectionToEdit.maxValue = maxValue;
                          widget.sectionToEdit.name = nameController.text;
                          await DatabaseHelper.db.updateWorkoutSection(workoutSection: widget.sectionToEdit);
                          Navigator.of(context).pop();
                        }
                      }
                    }),
                    child: Text('Save Section'),
                  ),
                  VerticalDivider(),
                  RaisedButton(
                    onPressed: (() async {
                      if (formKey.currentState.validate()) {
                        switch(
                        await CustomAlertDialog.showYesNoAlert('You will loose this Section!\n\nDo you really want to delete it?', context)
                        )
                        {
                          case AlertReturnDecide.Yes:
                            await DatabaseHelper.db.deleteWorkoutSection(workoutSectionUuid: widget.sectionToEdit.workoutSectionUuid);
                            widget.alreadyPresentSectionList.remove(widget.sectionToEdit);
                            Navigator.of(context).pop();
                            break;
                          case AlertReturnDecide.No: // Stay here, do nothing
                            break;
                        }
                      }
                    }),
                    child: Text('Delete Section', style: TextStyle(color: Colors.red),),
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
