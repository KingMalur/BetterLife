import 'package:flutter/material.dart';

import 'package:better_life/add_new_workout_page.dart';
import 'package:better_life/workout.dart';
import 'package:better_life/workout_card_list.dart';
import 'package:better_life/database.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle;
  final TextEditingController _filter = new TextEditingController();

  String _searchText = "";

  List<Workout> _workouts = new List<Workout>(); // TODO: Load from database
  List<Workout> _filteredWorkouts = new List<Workout>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _addListenerToSearchFilter() {
    widget._filter.addListener(() {
      if (widget._filter.text.isEmpty) {
        setState(() {
          widget._searchText = "";
          widget._filteredWorkouts = widget._workouts;
        });
      } else {
        setState(() {
          widget._searchText = widget._filter.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _addListenerToSearchFilter();
    if (widget._searchIcon.icon == Icons.search) {
      widget._appBarTitle = Text(widget.title);
    }

    return Scaffold(
        appBar: AppBar(
          title: widget._appBarTitle,
          backgroundColor: Colors.black45,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add new workout',
              onPressed: _addPressed,
            ),
            IconButton(
              icon: Icon(Icons.menu),
              tooltip: 'Open menu',
              onPressed: _menuPressed,
            ),
          ],
          leading: IconButton(
            icon: widget._searchIcon,
            tooltip: 'Search for workout',
            onPressed: _searchPressed,
          ),
        ),
        body: Container(
          child: new FutureBuilder(//_buildWorkoutCardList(widget._workouts),
            future: DatabaseProvider.db.getAllWorkouts(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return new Container(
                    padding: EdgeInsets.all(8.0),
                    child: _getWorkoutCardList(snapshot),
                  );
                } else {
                  return new Container(
                    alignment: Alignment.center,
                    child: new CircularProgressIndicator(), // TODO: Change color
                  );
                }
              } else {
                return new Container(
                  alignment: Alignment.center,
                  child: new CircularProgressIndicator(), // TODO: Change color
                );
              }
            },
          ),
        ),
    );
  }

  Widget _getWorkoutCardList(AsyncSnapshot snapshot) {
    widget._workouts = new List<Workout>();
    for (var e in snapshot.data) {
      widget._workouts.add(e);
    }

    if (widget._searchText.isNotEmpty) {
      List<Workout> tempWorkouts = new List<Workout>();
      for (int i = 0; i < widget._workouts.length; i++) {
        if (widget._workouts[i].name.toLowerCase().contains(widget._searchText.toLowerCase())) {
          tempWorkouts.add(widget._workouts[i]);
        }
      }
      widget._filteredWorkouts = tempWorkouts;
    } else {
      widget._filteredWorkouts = widget._workouts;
    }


    WorkoutCardList l = WorkoutCardList(workoutList: widget._filteredWorkouts,);
    l.workoutList.sort((a, b) => a.name.compareTo(b.name)); // Sort by name

    return l;
  }

  void _searchPressed() {
    setState(() {
      if (widget._searchIcon.icon == Icons.search) {
        widget._searchIcon = Icon(Icons.close);
        widget._appBarTitle = TextField(
          controller: widget._filter,
          style: TextStyle(
            color: Colors.white70,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white70,),
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70,),
          ),
        );
      } else {
        widget._searchIcon = Icon(Icons.search);
        widget._appBarTitle = Text(widget.title);
        widget._filteredWorkouts = widget._workouts;
        widget._filter.clear();
      }
    });
  }

  void _addPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewWorkoutPage(cards: widget._workouts,)));
  }

  void _menuPressed() {
    // TODO: Implement some sort of menu (Light-/Dark-Mode, Licenses of used components, Author Information, etc.)
  }
}