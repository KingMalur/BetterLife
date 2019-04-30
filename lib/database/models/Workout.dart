import 'dart:convert';
import 'package:flutter/material.dart';

Workout workoutFromJson(String str) {
  final jsonData = json.decode(str);
  return Workout.fromMap(jsonData);
}

String workoutToJson(Workout data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Workout {
  String workoutUuid;
  String tagUuid;
  String name;
  String imageFilePath;
  bool favorite;

  Workout({
    @required this.workoutUuid,
    @required this.tagUuid,
    @required this.name,
    @required this.imageFilePath,
    @required this.favorite});

  factory Workout.fromMap(Map<String, dynamic> json) {

    Workout w = new Workout(
        workoutUuid: json['workoutUuid'],
        tagUuid: json['tagUuid'],
        name: json['name'],
        imageFilePath: json['imageFilePath'],
        favorite: json['favorite'] == 0 ? false : true
    );
    return w;
  }

  Map<String, dynamic> toMap() => {
    'workoutUuid': workoutUuid,
    'tagUuid': tagUuid,
    'name': name,
    'imageFilePath': imageFilePath,
    'favorite': favorite == false ? 0 : 1,
  };
}
