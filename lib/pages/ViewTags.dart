import 'package:flutter/material.dart';

class ViewTags extends StatefulWidget {
  ViewTags();

  @override
  _ViewTagsState createState() => _ViewTagsState();
}

class _ViewTagsState extends State<ViewTags> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('View Tags'),
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
