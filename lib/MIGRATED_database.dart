import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:better_life/MIGRATED_workout.dart';
import 'package:better_life/workout_data.dart';

class DatabaseProvider {
  final String databaseName = 'BetterLife.db';
  final String workoutTableName = 'Workout';
  final String workoutDataTableName = 'WorkoutData';

  final String databaseNameTest = 'BetterLifeTest.db';

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
      await _createTablesIfExist(db);
    }, onOpen: (Database db) async {
      await _createTablesIfExist(db);
    });
  }

  _createTablesIfExistTEST(Database db) async {
    await db.execute("DROP TABLE Workout");
    await db.execute("DROP TABLE WorkoutSection");
    await db.execute("DROP TABLE WorkoutData");
    await db.execute("DROP TABLE DataPoint");
    await db.execute("DROP TABLE Tag");

    await db.execute("CREATE TABLE IF NOT EXISTS Workout ("
        "workout_uuid TEXT NOT NULL PRIMARY KEY, "
        "name TEXT NOT NULL, "
        "imageFilePath TEXT NOT NULL"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS WorkoutSection ("
        "workout_section_uuid TEXT NOT NULL PRIMARY KEY, "
        "workout_uuid TEXT NOT NULL, "
        "name TEXT NOT NULL, "
        "minValue INTEGER NOT NULL, "
        "maxValue INTEGER NOT NULL, "
            "FOREIGN KEY (workout_uuid) REFERENCES Workout(workout_uuid)"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS WorkoutData ("
        "workout_data_uuid TEXT NOT NULL PRIMARY KEY, "
        "workout_uuid TEXT NOT NULL, "
        "dateTimeIso8601 TEXT NOT NULL, "
            "FOREIGN KEY (workout_uuid) REFERENCES Workout(workout_uuid)"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS DataPoint ("
        "data_point_uuid TEXT NOT NULL PRIMARY KEY, "
        "workout_section_uuid TEXT NOT NULL, "
        "workout_data_uuid TEXT NOT NULL, "
        "value INTEGER NOT NULL, "
            "FOREIGN KEY (workout_section_uuid) REFERENCES WorkoutSection(workout_section_uuid),"
            "FOREIGN KEY (workout_data_uuid) REFERENCES WorkoutData(workout_data_uuid)"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS Tag ("
        "tag_uuid TEXT NOT NULL PRIMARY KEY, "
        "workout_uuid TEXT NOT NULL, "
        "name TEXT NOT NULL, "
        "color_a INTEGER NOT NULL, "
        "color_r INTEGER NOT NULL, "
        "color_g INTEGER NOT NULL, "
        "color_b INTEGER NOT NULL, "
            "FOREIGN KEY (workout_uuid) REFERENCES Workout(workout_uuid),"
        ")"
    );
  }

  _createTablesIfExist(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS " + workoutTableName + " ("
        "uuid TEXT PRIMARY KEY, "
        "name TEXT, "
        "sets INTEGER, "
        "repetitions INTEGER, "
        "weight INTEGER, "
        "useBodyWeight INTEGER, "
        "imageFilePath TEXT"
        ")"
    );
    await db.execute("CREATE TABLE IF NOT EXISTS " + workoutDataTableName + " ("
        "uuid TEXT PRIMARY KEY, "
        "workoutUuid TEXT, "
        "dateTimeIso8601 TEXT, "
        "sets INTEGER, "
        "repetitions INTEGER, "
        "weight INTEGER"
        ")"
    );
  }

  // WORKOUT DATA
  insertWorkoutData(WorkoutData data) async {
    final db = await database;

    var res = await db.insert(workoutDataTableName, data.toMap());
    return res;
  }

  upsertWorkoutData(WorkoutData data) async {
    final db = await database;

    var count = await db.firstIntValue(await db.query(workoutDataTableName, where: "uuid = ?", whereArgs: [data.uuid]));

    var res;
    if (count == 0) {
      res = await db.insert(workoutDataTableName, data.toMap());
    } else {
      res = await db.update(workoutDataTableName, data.toMap(), where: "uuid = ?", whereArgs: [data.uuid]);
    }

    return res;
  }

  updateWorkoutData(WorkoutData data) async {
    final db = await database;

    await db.update(workoutDataTableName, data.toMap(), where: "uuid = ?", whereArgs: [data.uuid]);
  }

  getWorkoutData(String uuid) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "uuid = ?", whereArgs: [uuid]);
    return res.isEmpty ? null : WorkoutData.fromMap(res.first);
  }

  Future<List<WorkoutData>> getAllWorkoutDataPoints() async {
    final db = await database;

    var res = await db.query(workoutDataTableName); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> listOfWorkoutDataPoints = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      listOfWorkoutDataPoints.add(WorkoutData.fromMap(e)); // Workout
    }

    return listOfWorkoutDataPoints; // Future<List<Workout>> -> For FutureBuilder
  }

  Future<List<WorkoutData>> getWorkoutDataPointsOfWorkout(String workoutUuid, {bool sort = true, bool excludeOlderThanTimeSpan = false, double notOlderThanDays = double.infinity}) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> listOfWorkoutDataPoints = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      listOfWorkoutDataPoints.add(WorkoutData.fromMap(e)); // Workout
    }

    List<WorkoutData> listOfNonExcludedWorkoutDataPoints = new List<WorkoutData>();

    DateTime nDaysAgo = DateTime.now().subtract(Duration(days: notOlderThanDays.round()));
    if (excludeOlderThanTimeSpan) {
      for (var e in listOfWorkoutDataPoints) {
        if (notOlderThanDays == 0.0) {
          listOfNonExcludedWorkoutDataPoints.add(e);
        } else {
          if (nDaysAgo.compareTo(DateTime.parse(e.dateTimeIso8601)) <= 0) {
            listOfNonExcludedWorkoutDataPoints.add(e);
          }
        }
      }
    } else {
      listOfNonExcludedWorkoutDataPoints = listOfWorkoutDataPoints;
    }

    if (sort) {
      listOfNonExcludedWorkoutDataPoints.sort((a, b) => DateTime.parse(a.dateTimeIso8601).compareTo(DateTime.parse(b.dateTimeIso8601)));
    }

    return listOfNonExcludedWorkoutDataPoints; // Future<List<Workout>> -> For FutureBuilder
  }

  Future<WorkoutData> getLatestWorkoutDataPointOfWorkout(String workoutUuid) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> listOfWorkoutDataPoints = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      listOfWorkoutDataPoints.add(WorkoutData.fromMap(e)); // Workout
    }

    listOfWorkoutDataPoints.sort((a, b) => DateTime.parse(a.dateTimeIso8601).compareTo(DateTime.parse(b.dateTimeIso8601)));

    var latestWorkoutData = listOfWorkoutDataPoints.isEmpty ? null : listOfWorkoutDataPoints.last;

    return latestWorkoutData; // Future<List<Workout>> -> For FutureBuilder
  }

  deleteSingleWorkoutData(String uuid) async {
    final db = await database;

    await db.delete(workoutDataTableName, where: "uuid = ?", whereArgs: [uuid]);
  }

  deleteWorkoutDataOfWorkout(String workoutUuid) async {
    final db = await database;

    await db.delete(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]);
  }
  // END WORKOUT DATA

  // WORKOUT
  insertWorkout(Workout workout) async {
    final db = await database;

    var res = await db.insert(workoutTableName, workout.toMap());
    return res;
  }

  upsertWorkout(Workout workout) async {
    final db = await database;

    var count = await db.firstIntValue(await db.query(workoutTableName, where: "name = ?", whereArgs: [workout.name]));

    var res;
    if (count == 0) {
      res = await db.insert(workoutTableName, workout.toMap());
    } else {
      res = await db.update(workoutTableName, workout.toMap(), where: "name = ?", whereArgs: [workout.name]);
    }

    return res;
  }

  updateWorkout(Workout workout) async {
    final db = await database;

    await db.update(workoutTableName, workout.toMap(), where: "uuid = ?", whereArgs: [workout.uuid]);
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

  deleteWorkout(Workout workout, {bool deleteWorkoutDataPoints = false}) async {
    final db = await database;

    await db.delete(workoutTableName, where: "uuid = ?", whereArgs: [workout.uuid]);
    if (deleteWorkoutDataPoints) {
      await deleteWorkoutDataOfWorkout(workout.uuid);
    }
  }
  // END WORKOUT
}
