import 'package:flutter/material.dart';

class AddTag extends StatefulWidget {
  AddTag();

  @override
  _AddTagState createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Add Tag'),
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
