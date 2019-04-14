import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:better_life/workout.dart';

class DatabaseProvider {
  final String databaseName = 'BetterLife.db';
  final String workoutTableName = 'Workout';

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  static Database _database;

  get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    var documentsInDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsInDirectory.path, databaseName);
    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE " + workoutTableName + " ("
          "uuid TEXT PRIMARY KEY, "
          "name TEXT, "
          "sets INTEGER, "
          "repetitions INTEGER, "
          "weight INTEGER, "
          "useBodyWeight INTEGER, "
          "imageFile BLOB"
          ")"
      );
    });
  }

  insertWorkout(Workout w) async {
    final db = await database;

    var res = await db.insert(workoutTableName, w.toMap());
    return res;
  }

  upsertWorkout(Workout w) async {
    final db = await database;

    var count = await db.firstIntValue(await db.query(workoutTableName, where: "name = ?", whereArgs: [w.name]));

    var res;
    if (count == 0) {
      res = await db.insert(workoutTableName, w.toMap());
    } else {
      res = await db.update(workoutTableName, w.toMap(), where: "name = ?", whereArgs: [w.name]);
    }

    return res;
  }

  updateWorkout(Workout w) async {
    final db = await database;

    await db.update(workoutTableName, w.toMap(), where: "uuid = ?", whereArgs: [w.uuid]);
  }

  getWorkout(String name) async {
    final db = await database;

    var res = await db.query(workoutTableName, where: "name = ?", whereArgs: [name]);
    return res.isEmpty ? null : Workout.fromMap(res.first);
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;

    var res = await db.query(workoutTableName); // Future<List<Map<String, dynamic>>>

    List<Workout> listOfWorkouts = new List<Workout>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      listOfWorkouts.add(Workout.fromMap(e)); // Workout
    }

    return listOfWorkouts; // Future<List<Workout>> -> For FutureBuilder
  }

  deleteWorkout(Workout w) async {
    final db = await database;

    await db.delete(workoutTableName, where: "uuid = ?", whereArgs: [w.uuid]);
  }
}
