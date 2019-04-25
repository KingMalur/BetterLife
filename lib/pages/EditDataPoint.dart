import 'package:flutter/material.dart';

class EditDataPoint extends StatefulWidget {
  EditDataPoint();

  @override
  _EditDataPointState createState() => _EditDataPointState();
}

class _EditDataPointState extends State<EditDataPoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Edit Data Point'),
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
            Divider(),
          ],
        ),
      ),
    );
  }
}
