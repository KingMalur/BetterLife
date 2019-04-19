import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life/widgets/HorizontalNumberPicker.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/database/models/WorkoutSection.dart';

class AddWorkoutSection extends StatefulWidget {
  AddWorkoutSection({this.workout_uuid});

  final formKey = GlobalKey<FormState>();

  final String section_uuid = Uuid().v4();
  final String workout_uuid;
  final nameController = new TextEditingController();
  int minValue = 1;
  int maxValue = 999;

  @override
  _AddWorkoutSectionState createState() => _AddWorkoutSectionState();
}

class _AddWorkoutSectionState extends State<AddWorkoutSection> {
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
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: widget.formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField( // Name
              controller: widget.nameController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.title),
                  hintText: 'What should the Section be called?',
                  labelText: 'Section Name'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
              },
            ),
            Divider(),
            Text('Minimal Value'),
            HorizontalNumberPicker(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.isTight
                      ? Container() : HorizontalSlider(
                    width: constraints.maxWidth,
                    value: widget.minValue,
                    onChanged: (val) => setState(() => widget.minValue = val),
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
                    value: widget.minValue,
                    onChanged: (val) => setState(() => widget.minValue = val),
                  );
                },
              ),
            ),
            Divider(),
            RaisedButton(
              onPressed: (() async {
                if (widget.formKey.currentState.validate()) {
                  WorkoutSection section = WorkoutSection(
                      name: widget.nameController.text,
                      workoutSectionUuid: widget.section_uuid,
                      minValue: widget.minValue,
                      maxValue: widget.maxValue,
                      workoutUuid: widget.workout_uuid
                  );

                  Navigator.of(context).pop(section);
                }
              }),
              child: Text('Save Section'),
            ),
          ],
        ),
      ),
    );
  }
}
