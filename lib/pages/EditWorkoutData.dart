import 'package:flutter/material.dart';

class EditWorkoutData extends StatefulWidget {
  EditWorkoutData();

  @override
  _EditWorkoutDataState createState() => _EditWorkoutDataState();
}

class _EditWorkoutDataState extends State<EditWorkoutData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Edit Workout Data'),
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
            Divider(color: Colors.black45,),
          ],
        ),
      ),
    );
  }
}
