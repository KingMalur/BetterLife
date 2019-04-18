import 'package:flutter/material.dart';
import 'package:better_life/database/DatabaseHelper.dart';
import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/widgets/CustomGridView.dart';

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
      backgroundColor: Colors.black45,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add new workout',
          onPressed: null,
        ),
        IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Open menu',
          onPressed: null,
        ),
      ],
      leading: IconButton(
        icon: _searchIcon,
        tooltip: 'Search for workout',
        onPressed: _searchPressed,
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
              iconSize: MediaQuery.of(context).size.width / 4,
              onPressed: null,
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

    _filteredWorkouts.sort((a, b) => a.name.compareTo(b.name)); // Sort by name

    return CustomGridView(list: _filteredWorkouts,);
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _filter,
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
        _filter.clear();
      }
    });
  }
}
