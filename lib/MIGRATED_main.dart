import 'package:flutter/material.dart';

import 'package:better_life/home_page.dart';

void main() => runApp(BetterLife());

class BetterLife extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Life',
      //theme: ThemeData.,
      home: new HomePage(title: 'Better Life'),
    );
  }
}
