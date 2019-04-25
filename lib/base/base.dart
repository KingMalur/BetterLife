import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:better_life/pages/Home.dart';

void main() => runApp(BetterLife());

class BetterLife extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: 'Better Life',
          theme: theme,
          home: new Home(title: 'Better Life',),
        );
      },
    );
  }
}
