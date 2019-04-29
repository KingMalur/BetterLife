import 'package:flutter/material.dart';

import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/widgets/CustomCard.dart';

class CustomGridView extends StatefulWidget {
  CustomGridView({this.list, this.cardCallback});

  final List<Workout> list;
  final Function cardCallback;

  @override
  _CustomGridViewState createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
        childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 12 / 9 : 10 / 9,
      ),
      itemCount: widget.list.length,
      itemBuilder: (BuildContext context, index) {
        if (index >= widget.list.length) {
          return new Container(
            alignment: Alignment.center,
            child: new CircularProgressIndicator(),
          );
        }
        return FutureBuilder(
          future: DatabaseHelper.db.getTag(tagUuid: widget.list[index].tagUuid),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return CustomCard(workout: widget.list[index], cardCallback: widget.cardCallback);
          }
        );
      },
    );
  }
}
