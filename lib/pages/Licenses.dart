import 'package:flutter/material.dart';

class Licenses extends StatefulWidget {
  Licenses();

  @override
  _LicensesState createState() => _LicensesState();
}

class _LicensesState extends State<Licenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Licenses'),
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
