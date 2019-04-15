import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:better_life/workout.dart';
import 'package:better_life/image_helper.dart';
import 'package:better_life/horizontal_number_picker.dart';
import 'package:better_life/database.dart';

class AddNewWorkoutPage extends StatefulWidget {
  AddNewWorkoutPage({this.cards});

  final List<Workout> cards;

  @override
  _AddNewWorkoutPageState createState() => _AddNewWorkoutPageState();
}

class _AddNewWorkoutPageState extends State<AddNewWorkoutPage> {
  final nameController = TextEditingController();
  int setsAmount = 3;
  int repsAmount = 8;
  int weightAmount = 20;
  bool useBodyweight = false;

  final _formKey = GlobalKey<FormState>();

  File _image = new File("");

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
        title: Text('Add new Workout',),
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
                  minValue: 1,
                  maxValue: 20,
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
                  minValue: 1,
                  maxValue: 50,
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
                        minValue: 1,
                        maxValue: 250,
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
          RaisedButton(
            onPressed: (() async {
              if (_formKey.currentState.validate()) {
                Workout w = Workout(nameController.text, setsAmount, repsAmount, useBodyweight ? 0 : weightAmount, useBodyweight, _image == null ? "" : _image.path);
                bool exists = false;

                for (var e in widget.cards) {
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
                  await DatabaseProvider.db.insertWorkout(w);
                  widget.cards.add(w);
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
}
