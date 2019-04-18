import 'package:flutter/material.dart';

import 'package:better_life/pages/Home.dart';

void main() => runApp(BetterLife());

class BetterLife extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Life',
      home: new Home(title: 'Better Life',),
    );
  }
}
