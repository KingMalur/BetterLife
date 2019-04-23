import 'package:flutter/material.dart';

class AddDataPoint extends StatefulWidget {
  AddDataPoint();

  @override
  _AddDataPointState createState() => _AddDataPointState();
}

class _AddDataPointState extends State<AddDataPoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Add Data Point'),
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
