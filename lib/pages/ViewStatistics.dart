import 'package:flutter/material.dart';

class ViewStatistics extends StatefulWidget {
  ViewStatistics();

  @override
  _ViewStatisticsState createState() => _ViewStatisticsState();
}

class _ViewStatisticsState extends State<ViewStatistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('View Statistics'),
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
