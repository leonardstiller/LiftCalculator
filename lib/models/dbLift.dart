import 'dart:async';
import 'package:liftcalculator/util/weight_reps.dart';
import 'package:sqflite/sqflite.dart';

// Base Lift class

class DbLift {
  int id;
  DateTime date;
  int calculated1RM;
  WeightReps weightRep;

  DbLift(this.id, this.date, this.weightRep)
      : calculated1RM =
            ((weightRep.weight + weightRep.reps * 0.0333) + weightRep.reps)
                .round();

  DbLift.fromMap(Map<dynamic, dynamic> map)
      : id = map['id'],
        date = DateTime.fromMillisecondsSinceEpoch(map['date']),
        weightRep = WeightReps(map['weight'], map['reps']),
        calculated1RM = map['calculated1RM'];

  /// Transform a Lift into the DB structure:
  /// Transposes weight rep into separate attributes and transforms date into int
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'weight': weightRep.weight,
      'reps': weightRep.reps,
      'calculated1RM': calculated1RM,
    };
  }

  @override
  String toString() {
    return 'Lift{ id: $id, date: $date, \n calculated1RM: $calculated1RM \n $weightRep }';
  }
}

class LiftHelper {
  Database db;

  LiftHelper(this.db);

  /// Finds the top 3 lifts with the highest 1RM for the corresponding lift type.
  Future<List<DbLift>> getHighest1RMs(int id) async {
    List<Map> lifts = await db.query('Lift',
        where: 'id = ?',
        whereArgs: [id],
        orderBy: 'calculated1RM DESC',
        limit: 3);
    return List.generate(lifts.length, (i) => DbLift.fromMap(lifts[i]));
  }

  /// Gets all performed lifts for this lift type
  Future<List<DbLift>> getAllLifts(int id) async {
    List<Map> lifts = await db.query('Lift', where: 'id = ?', whereArgs: [id]);
    return List.generate(lifts.length, (i) => DbLift.fromMap(lifts[i]));
  }

  /// Gets only the biggest lift per day for a lift type
  getHighestLiftsPerDay(int id) async {
    List<Map> lifts = await db.rawQuery(
        'SELECT a.calculated1RM, a.date, a.id, a.weight, a.reps FROM lift a INNER JOIN(SELECT MAX(calculated1RM) as calculated1RM, date, id FROM lift WHERE ID = $id GROUP BY id, date) b ON a.id = b.id and a.calculated1RM = b.calculated1RM');
    return List.generate(lifts.length, (i) => DbLift.fromMap(lifts[i]));
  }
}