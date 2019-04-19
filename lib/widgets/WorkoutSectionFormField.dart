import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life/widgets/HorizontalNumberPicker.dart';

class WorkoutSectionFormField extends StatefulWidget {
  WorkoutSectionFormField();

  final formKey = GlobalKey<FormState>();

  final String uuid = Uuid().v4();
  final nameController = new TextEditingController();
  int minValue = 1;
  int maxValue = 999;

  @override
  _WorkoutSectionFormFieldState createState() => _WorkoutSectionFormFieldState();
}

class _WorkoutSectionFormFieldState extends State<WorkoutSectionFormField> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: widget.formKey,
        child: TextFormField( // Name
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
      ),
    );
  }
}
