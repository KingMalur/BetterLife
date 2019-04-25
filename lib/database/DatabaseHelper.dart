import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:better_life/database/models/Workout.dart';
import 'package:better_life/database/models/WorkoutData.dart';
import 'package:better_life/database/models/WorkoutSection.dart';
import 'package:better_life/database/models/DataPoint.dart';
import 'package:better_life/database/models/Tag.dart';

class DatabaseHelper {
  static final String databaseName = 'BetterLife.db';

  static final String workoutTableName = 'Workout';
  static final String workoutDataTableName = 'WorkoutData';
  static final String workoutSectionTableName = 'WorkoutSection';
  static final String dataPointTableName = 'DataPoint';
  static final String tagTableName = 'Tag';

  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    var documentsInDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsInDirectory.path, databaseName);

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await _createTablesIfExist(db);
    },
        onOpen: (Database db) async {
      await _createTablesIfExist(db);
    });
  }

  _createTablesIfExist(Database db) async {
    await db.execute("pragma foreign_keys=ON"); // Needed for "ON DELETE CASCADE"

    await db.execute("CREATE TABLE IF NOT EXISTS " + workoutTableName + " ("
        "workoutUuid VARCHAR(36) NOT NULL PRIMARY KEY, "
        "tagUuid VARCHAR(36), "
        "name VARCHAR(40) NOT NULL, "
        "imageFilePath TEXT NOT NULL"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS " + workoutSectionTableName + " ("
        "workoutSectionUuid VARCHAR(36) NOT NULL PRIMARY KEY, "
        "workoutUuid VARCHAR(36) NOT NULL, "
        "name VARCHAR(40) NOT NULL, "
        "minValue INTEGER NOT NULL, "
        "maxValue INTEGER NOT NULL, "
        "FOREIGN KEY (workoutUuid) REFERENCES Workout(workoutUuid) ON DELETE CASCADE"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS " + workoutDataTableName + " ("
        "workoutDataUuid VARCHAR(36) NOT NULL PRIMARY KEY, "
        "workoutUuid VARCHAR(36) NOT NULL, "
        "dateTimeIso8601 TEXT NOT NULL, "
        "FOREIGN KEY (workoutUuid) REFERENCES Workout(workoutUuid) ON DELETE CASCADE"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS " + dataPointTableName + " ("
        "dataPointUuid VARCHAR(36) NOT NULL PRIMARY KEY, "
        "workoutSectionUuid VARCHAR(36) NOT NULL, "
        "workoutDataUuid VARCHAR(36) NOT NULL, "
        "value INTEGER NOT NULL, "
        "FOREIGN KEY (workoutSectionUuid) REFERENCES WorkoutSection(workoutSectionUuid) ON DELETE CASCADE,"
        "FOREIGN KEY (workoutDataUuid) REFERENCES WorkoutData(workoutDataUuid) ON DELETE CASCADE"
        ")"
    );

    await db.execute("CREATE TABLE IF NOT EXISTS " + tagTableName + " ("
        "tagUuid VARCHAR(36) NOT NULL PRIMARY KEY, "
        "name VARCHAR(40) NOT NULL, "
        "colorA INTEGER NOT NULL, "
        "colorR INTEGER NOT NULL, "
        "colorG INTEGER NOT NULL, "
        "colorB INTEGER NOT NULL "
        ")"
    );
    }

// --------------------------------------------------------------------------------------------------------------------------------- WORKOUT
// WORKOUT GET
  Future<Workout> getWorkout({String workoutUuid}) async {
    final db = await database;

    var res = await db.query(workoutTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]);
    return res.isEmpty ? null : Workout.fromMap(res.first);
  }
  Future<Workout> getWorkoutOfName({String name}) async {
    final db = await database;

    var res = await db.query(workoutTableName, where: "name = ?", whereArgs: [name]);
    return res.isEmpty ? null : Workout.fromMap(res.first);
  }
// WORKOUT GET ALL
  Future<List<Workout>> getWorkoutList() async {
    final db = await database;

    var res = await db.query(workoutTableName); // Future<List<Map<String, dynamic>>>

    List<Workout> list = new List<Workout>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(Workout.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
// WORKOUT INSERT
  insertWorkout({Workout workout}) async {
    final db = await database;

    var res = await db.insert(workoutTableName, workout.toMap());
    return res;
  }
// WORKOUT UPDATE
  updateWorkout({Workout workout}) async {
    final db = await database;

    var res = await db.update(workoutTableName, workout.toMap(), where: "workoutUuid = ?", whereArgs: [workout.workoutUuid]);

    return res;
  }
// WORKOUT UPSERT
  upsertWorkout({Workout workout}) async {
    final db = await database;

    var exists = await getWorkout(workoutUuid: workout.workoutUuid) == null ? false : true;

    var res;
    if (exists) {
      res = await db.update(workoutTableName, workout.toMap(), where: "workoutUuid = ?", whereArgs: [workout.workoutUuid]);
    } else {
      res = await db.insert(workoutTableName, workout.toMap());
    }
    return res;
  }
// WORKOUT DELETE
  deleteWorkout({String workoutUuid}) async {
    final db = await database;

    await db.delete(workoutTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]);
  }
  deleteWorkouts() async {
    final db = await database;

    await db.delete(workoutTableName);
  }
// WORKOUT END

// --------------------------------------------------------------------------------------------------------------------------------- WORKOUT DATA
// WORKOUT DATA GET
  Future<WorkoutData> getWorkoutData({String workoutDataUuid}) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "workoutDataUuid = ?", whereArgs: [workoutDataUuid]);
    return res.isEmpty ? null : WorkoutData.fromMap(res.first);
  }
  Future<WorkoutData> getLatestWorkoutData({String workoutUuid}) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> list = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(WorkoutData.fromMap(e)); // Workout
    }

    list.sort((a, b) => DateTime.parse(a.dateTimeIso8601).compareTo(DateTime.parse(b.dateTimeIso8601))); // Sort ascending

    var latest = list.isEmpty ? null : list.last;

    return latest == null ? null : latest; // Future<List<Workout>> -> For FutureBuilder
  }
// WORKOUT DATA GET ALL
  Future<List<WorkoutData>> getWorkoutDataList() async {
    final db = await database;

    var res = await db.query(workoutDataTableName); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> list = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(WorkoutData.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }

  Future<List<WorkoutData>> getWorkoutDataListOfWorkout({String workoutUuid}) async {
    final db = await database;

    var res = await db.query(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]); // Future<List<Map<String, dynamic>>>

    List<WorkoutData> list = new List<WorkoutData>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(WorkoutData.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
// WORKOUT DATA INSERT
  insertWorkoutData({WorkoutData workoutData}) async {
    final db = await database;

    var res = await db.insert(workoutDataTableName, workoutData.toMap());
    return res;
  }
// WORKOUT DATA UPDATE
  updateWorkoutData({WorkoutData workoutData}) async {
    final db = await database;

    var res = await db.update(workoutDataTableName, workoutData.toMap(), where: "workoutDataUuid = ?", whereArgs: [workoutData.workoutDataUuid]);

    return res;
  }
// WORKOUT DATA UPSERT
  upsertWorkoutData({WorkoutData workoutData}) async {
    final db = await database;

    var exists = await getWorkoutData(workoutDataUuid: workoutData.workoutDataUuid) == null ? false : true;

    var res;
    if (exists) {
      res = await db.update(workoutDataTableName, workoutData.toMap(), where: "workoutDataUuid = ?", whereArgs: [workoutData.workoutDataUuid]);
    } else {
      res = await db.insert(workoutDataTableName, workoutData.toMap());
    }

    return res;
  }
// WORKOUT DATA DELETE
  deleteWorkoutData({String workoutDataUuid}) async {
    final db = await database;

    await db.delete(workoutDataTableName, where: "workoutDataUuid = ?", whereArgs: [workoutDataUuid]);
  }
  deleteWorkoutDataOfWorkout({String workoutUuid}) async {
    final db = await database;

    await db.delete(workoutDataTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]);
  }
// WORKOUT DATA END

// --------------------------------------------------------------------------------------------------------------------------------- WORKOUT SECTION
// WORKOUT SECTION GET
  Future<WorkoutSection> getWorkoutSection({String workoutSectionUuid}) async {
    final db = await database;

    var res = await db.query(workoutSectionTableName, where: "workoutSectionUuid = ?", whereArgs: [workoutSectionUuid]);
    return res.isEmpty ? null : WorkoutSection.fromMap(res.first);
  }
// WORKOUT SECTION GET ALL
  Future<List<WorkoutSection>> getWorkoutSectionList() async {
    final db = await database;

    var res = await db.query(workoutSectionTableName); // Future<List<Map<String, dynamic>>>

    List<WorkoutSection> list = new List<WorkoutSection>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(WorkoutSection.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
  Future<List<WorkoutSection>> getWorkoutSectionListOfWorkout({String workoutUuid}) async {
    final db = await database;

    var res = await db.query(workoutSectionTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]); // Future<List<Map<String, dynamic>>>

    List<WorkoutSection> list = new List<WorkoutSection>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(WorkoutSection.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
// WORKOUT SECTION INSERT
  insertWorkoutSection({WorkoutSection workoutSection}) async {
    final db = await database;

    var res = await db.insert(workoutSectionTableName, workoutSection.toMap());
    return res;
  }
// WORKOUT SECTION UPDATE
  updateWorkoutSection({WorkoutSection workoutSection}) async {
    final db = await database;

    var res = await db.update(workoutSectionTableName, workoutSection.toMap(), where: "workoutSectionUuid = ?", whereArgs: [workoutSection.workoutSectionUuid]);

    return res;
  }
// WORKOUT SECTION UPSERT
  upsertWorkoutSection({WorkoutSection workoutSection}) async {
    final db = await database;

    var exists = await getWorkoutSection(workoutSectionUuid: workoutSection.workoutSectionUuid) == null ? false : true;

    var res;
    if (exists) {
      res = await db.update(workoutSectionTableName, workoutSection.toMap(), where: "workoutSectionUuid = ?", whereArgs: [workoutSection.workoutSectionUuid]);
    } else {
      res = await db.insert(workoutSectionTableName, workoutSection.toMap());
    }

    return res;
  }
// WORKOUT SECTION DELETE
  deleteWorkoutSection({String workoutSectionUuid}) async {
    final db = await database;

    await db.delete(workoutSectionTableName, where: "workoutSectionUuid = ?", whereArgs: [workoutSectionUuid]);
  }
  deleteWorkoutSectionsOfWorkout({String workoutUuid}) async {
    final db = await database;

    await db.delete(workoutSectionTableName, where: "workoutUuid = ?", whereArgs: [workoutUuid]);
  }
// WORKOUT SECTION END

// --------------------------------------------------------------------------------------------------------------------------------- DATA POINT
// DATA POINT GET
  Future<DataPoint> getDataPoint({String dataPointUuid}) async {
    final db = await database;

    var res = await db.query(dataPointTableName, where: "dataPointUuid = ?", whereArgs: [dataPointUuid]);
    return res.isEmpty ? null : DataPoint.fromMap(res.first);
  }
  Future<DataPoint> getDataPointOfWorkoutDataAndWorkoutSection({String workoutDataUuid, String workoutSectionUuid}) async {
    final db = await database;

    var res = await db.query(dataPointTableName, where: "workoutDataUuid = ? AND workoutSectionUuid = ?", whereArgs: [workoutDataUuid, workoutSectionUuid]); // Future<List<Map<String, dynamic>>>

    return res.isEmpty ? null : DataPoint.fromMap(res.first);
  }
// DATA POINT GET ALL
  Future<List<DataPoint>> getDataPointList() async {
    final db = await database;

    var res = await db.query(dataPointTableName); // Future<List<Map<String, dynamic>>>

    List<DataPoint> list = new List<DataPoint>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(DataPoint.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
  Future<List<DataPoint>> getDataPointListOfWorkoutData({String workoutDataUuid}) async {
    final db = await database;

    var res = await db.query(dataPointTableName, where: "workoutDataUuid = ?", whereArgs: [workoutDataUuid]); // Future<List<Map<String, dynamic>>>

    List<DataPoint> list = new List<DataPoint>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(DataPoint.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
  Future<List<DataPoint>> getDataPointListOfWorkoutSection({String workoutSectionUuid}) async {
    final db = await database;

    var res = await db.query(dataPointTableName, where: "workoutSectionUuid = ?", whereArgs: [workoutSectionUuid]); // Future<List<Map<String, dynamic>>>

    List<DataPoint> list = new List<DataPoint>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(DataPoint.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
  Future<List<DataPoint>> getDataPointListOfWorkoutDataAndWorkoutSection({String workoutDataUuid, String workoutSectionUuid}) async {
    final db = await database;

    var res = await db.query(dataPointTableName, where: "workoutDataUuid = ? AND workoutSectionUuid = ?", whereArgs: [workoutDataUuid, workoutSectionUuid]); // Future<List<Map<String, dynamic>>>

    List<DataPoint> list = new List<DataPoint>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(DataPoint.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
// DATA POINT INSERT
  insertDataPoint({DataPoint dataPoint}) async {
    final db = await database;

    var res = await db.insert(dataPointTableName, dataPoint.toMap());
    return res;
  }
// DATA POINT UPDATE
  updateDataPoint({DataPoint dataPoint}) async {
    final db = await database;

    var res = await db.update(dataPointTableName, dataPoint.toMap(), where: "dataPointUuid = ?", whereArgs: [dataPoint.dataPointUuid]);

    return res;
  }
// DATA POINT UPSERT
  upsertDataPoint({DataPoint dataPoint}) async {
    final db = await database;

    var exists = await getDataPoint(dataPointUuid: dataPoint.dataPointUuid) == null ? false : true;

    var res;
    if (exists) {
      res = await db.update(dataPointTableName, dataPoint.toMap(), where: "dataPointUuid = ?", whereArgs: [dataPoint.dataPointUuid]);
    } else {
      res = await db.insert(dataPointTableName, dataPoint.toMap());
    }

    return res;
  }
// DATA POINT DELETE
  deleteDataPoint({String dataPointUuid}) async {
    final db = await database;

    await db.delete(dataPointTableName, where: "dataPointUuid = ?", whereArgs: [dataPointUuid]);
  }
  deleteDataPointsOfWorkoutSection({String workoutSectionUuid}) async {
    final db = await database;

    await db.delete(dataPointTableName, where: "workoutSectionUuid = ?", whereArgs: [workoutSectionUuid]);
  }
  deleteDataPointsOfWorkoutData({String workoutDataUuid}) async {
    final db = await database;

    await db.delete(dataPointTableName, where: "workoutDataUuid = ?", whereArgs: [workoutDataUuid]);
  }
  deleteDataPointsOfWorkoutSectionAndWorkoutData({String workoutDataUuid, String workoutSectionUuid}) async {
    final db = await database;

    await db.delete(dataPointTableName, where: "workoutDataUuid = ? AND workoutSectionUuid = ?", whereArgs: [workoutDataUuid, workoutSectionUuid]);
  }
// DATA POINT END

// --------------------------------------------------------------------------------------------------------------------------------- TAG
// TAG GET
  Future<Tag> getTag({String tagUuid}) async {
    final db = await database;

    var res = await db.query(tagTableName, where: "tagUuid = ?", whereArgs: [tagUuid]);
    return res.isEmpty ? null : Tag.fromMap(res.first);
  }
// TAG GET ALL
  Future<List<Tag>> getTagList() async {
    final db = await database;

    var res = await db.query(tagTableName); // Future<List<Map<String, dynamic>>>

    List<Tag> list = new List<Tag>();

    for (var e in res.toList()) { // For Map<String, dynamic>
      list.add(Tag.fromMap(e)); // Workout
    }

    return list.isEmpty ? null : list; // Future<List<Workout>> -> For FutureBuilder
  }
// TAG INSERT
  insertTag({Tag tag}) async {
    final db = await database;

    var res = await db.insert(tagTableName, tag.toMap());
    return res;
  }
// TAG UPDATE
  updateTag({Tag tag}) async {
    final db = await database;

    var res = await db.update(tagTableName, tag.toMap(), where: "tagUuid = ?", whereArgs: [tag.tagUuid]);

    return res;
  }
// TAG UPSERT
  upsertTag({Tag tag}) async {
    final db = await database;

    var exists = await getTag(tagUuid: tag.tagUuid) == null ? false : true;

    var res;
    if (exists) {
      res = await db.update(tagTableName, tag.toMap(), where: "tagUuid = ?", whereArgs: [tag.tagUuid]);
    } else {
      res = await db.insert(tagTableName, tag.toMap());
    }

    return res;
  }
// TAG DELETE
  deleteTag({String tagUuid}) async {
    final db = await database;

    await db.delete(tagTableName, where: "tagUuid = ?", whereArgs: [tagUuid]);
  }
// TAG END
}

/* EXCLUDE OLDER THAN -> TODO: Needs to be implemented somewhere else
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
*/
