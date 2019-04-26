import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class Settings extends StatefulWidget {
  Settings();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _darkThemeActive = false;

  @override
  void initState() {
    super.initState();

    _darkThemeActive = DynamicTheme.of(context).brightness == Brightness.dark ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Settings'),
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
            SwitchListTile(
              title: Text('Use Dark-Mode'),
              value: _darkThemeActive,
              onChanged: ((value) {
                _darkThemeActive = value;
                DynamicTheme.of(context).setBrightness(_darkThemeActive ? Brightness.dark : Brightness.light);
                setState(() {});
              }),
            ),
            Divider(),
            ListTile(
              title: Text('Add & Edit Tags (NOT IMPLEMENTED)'),
              onTap: (() async {

              }),
            ),
            Divider(),
            ListTile( // Filler ListTile
              title: Text(''),
              onTap: null,
            ),
            Divider(),
            ListTile(
              title: Text('About (NOT IMPLEMENTED)'),
              onTap: (() async {

              }),
            ),
            Divider(),
            ListTile(
              title: Text('Licenses (NOT IMPLEMENTED)'),
              onTap: (() async {

              }),
            ),
          ],
        ),
      ),
    );
  }
}
