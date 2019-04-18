import 'package:flutter/material.dart';

import 'package:better_life/add_new_workout_page.dart';
import 'package:better_life/workout.dart';
import 'package:better_life/workout_card_list.dart';
import 'package:better_life/workout_card_grid.dart';
import 'package:better_life/database.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  final TextEditingController _filter = new TextEditingController();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle;
  String _searchText = "";

  List<Workout> _workouts = new List<Workout>();
  List<Workout> _filteredWorkouts = new List<Workout>();

  void _addListenerToSearchFilter() {
    widget._filter.addListener(() {
      if (widget._filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredWorkouts = _workouts;
        });
      } else {
        setState(() {
          _searchText = widget._filter.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _addListenerToSearchFilter();
    if (_searchIcon.icon == Icons.search) {
      _appBarTitle = Text(widget.title);
    }

    return Scaffold(
        appBar: AppBar(
          title: _appBarTitle,
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
            icon: _searchIcon,
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
    _workouts = new List<Workout>();
    for (var e in snapshot.data) {
      _workouts.add(e);
    }

    if (_searchText.isNotEmpty) {
      List<Workout> tempWorkouts = new List<Workout>();
      for (int i = 0; i < _workouts.length; i++) {
        if (_workouts[i].name.toLowerCase().contains(_searchText.toLowerCase())) {
          tempWorkouts.add(_workouts[i]);
        }
      }
      _filteredWorkouts = tempWorkouts;
    } else {
      _filteredWorkouts = _workouts;
    }

    _filteredWorkouts.sort((a, b) => a.name.compareTo(b.name)); // Sort by name

    var w;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      w = WorkoutCardList(workoutList: _filteredWorkouts,);
    } else {
      w = WorkoutCardGrid(workoutList: _filteredWorkouts,);
    }

    return w;
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
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
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text(widget.title);
        _filteredWorkouts = _workouts;
        widget._filter.clear();
      }
    });
  }

  void _addPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewWorkoutPage(cards: _workouts,)));
  }

  void _menuPressed() {
    // TODO: Implement some sort of menu (Light-/Dark-Mode, Licenses of used components, Author Information, etc.)
  }
}