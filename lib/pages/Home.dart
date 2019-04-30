import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/widgets/CustomGridView.dart';
import 'package:better_life/pages/AddWorkout.dart';
import 'package:better_life/pages/Settings.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _filter = new TextEditingController();

  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle;
  String _searchText = "";

  List<Workout> _workouts = new List<Workout>();
  List<Workout> _filteredWorkouts = new List<Workout>();

  void _addListenerToSearchFilter() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredWorkouts = _workouts;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
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
      appBar: _getAppBar(),
      body: _getBody(),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          tooltip: 'Search for Workout',
          onPressed: _searchPressed,
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add new Workout',
          onPressed: () async {
            var workout = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                AddWorkout(alreadyPresentCardList: _workouts)));
            if (workout != null) {
              _workouts.add(workout);
              setState(() {});
            }
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.settings),
        tooltip: 'Open Settings',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
          setState(() {});
        },
      ),
    );
  }

  Widget _getBody() {
    return FutureBuilder(
      future: DatabaseHelper.db.getWorkoutList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return new Container(
              padding: EdgeInsets.all(8.0),
              child: _sortWorkoutList(snapshot),
            );
          } else {
            return new Container(
              alignment: Alignment.center,
              child: new CircularProgressIndicator(),
            );
          }
        } else {
          return new Container(
            alignment: Alignment.center,
            child: new IconButton(
              icon: Icon(Icons.add),
              iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.height / 4,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    AddWorkout(alreadyPresentCardList: _workouts)));
              },
            ),
          );
        }
      },
    );
  }

  Widget _sortWorkoutList(AsyncSnapshot snapshot) {
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

    List<Workout> favoriteWorkouts = new List<Workout>();
    List<Workout> notFavoriteWorkouts = new List<Workout>();

    for (var e in _filteredWorkouts) {
      if (e.favorite) {
        favoriteWorkouts.add(e);
      } else {
        notFavoriteWorkouts.add(e);
      }
    }

    _filteredWorkouts.clear();
    favoriteWorkouts.sort((a, b) => (a.name.compareTo(b.name)));
    notFavoriteWorkouts.sort((a, b) => (a.name.compareTo(b.name)));

    for (var e in favoriteWorkouts) {
      _filteredWorkouts.add(e);
    }
    for (var e in notFavoriteWorkouts) {
      _filteredWorkouts.add(e);
    }

    return CustomGridView(list: _filteredWorkouts, cardCallback: () => setState(() {}),);
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search,),
            hintText: 'Search...',
          ),
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text(widget.title);
        _filteredWorkouts = _workouts;
        _filter.clear();
      }
    });
  }
}
