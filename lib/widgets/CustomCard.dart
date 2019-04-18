import 'package:flutter/material.dart';
import 'dart:io';
import 'package:better_life/widgets/ImageHelper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_life/database/models/Workout.dart';

class CustomCard extends StatefulWidget {
  final Workout workout;

  CustomCard({this.workout});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              widget.workout.name,
              style: TextStyle(
                fontSize: 25.0,
              ),
              maxLines: 1,
              minFontSize: 15.0,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                workoutImage,
                workoutInformation,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get workoutImage {
    var width = MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 2.75 : MediaQuery.of(context).size.height / 2.75;

    return Container( // First Object: Image of Workout
      height: width,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.black26,
        borderRadius: BorderRadiusDirectional.circular(5.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: ImageHelper.getImageProvider(File(widget.workout.imageFilePath)),//FileImage(File(widget.workout.imagePath)),
        ),
      ),
    );
  }

  Widget get workoutInformation {
    return Container( // Second Object: Four Rows of Information (First Row only one Information)
      height: 175.0,
      width: 125.0,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadiusDirectional.circular(5.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.edit,),
            color: Colors.black45,
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.timeline,),
            color: Colors.black45,
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.add,),
            color: Colors.black45,
            onPressed: null,
          ),
        ],
      ),
    );
  }
}