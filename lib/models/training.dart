import 'package:flutter/material.dart';
import 'package:liftcalculator/models/card.dart';
import 'package:liftcalculator/models/profile.dart';
import 'package:liftcalculator/util/programs.dart';
import 'package:liftcalculator/util/weight.dart';
import 'package:provider/provider.dart';

class Training {
  final int id;   // ID is the Date of the lift as some sort of integer i.e. timeinms or smth()
  final String lift; // lift name

  Training({
    required this.id,
    required this.lift,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lift': lift,
    };
  }

  @override
  String toString() {
    return 'Training{id: $id, lift: $lift';
  }
}

buildTrainingCard() {
  return Consumer<UserProfile>(builder: (context, user, child) {
    LiftDay week = getCurrentWeek(user);
    int excerciseTrainingMax = (user.currentExcercise.current1RM * user.currentTrainingMaxPercentage / 100).round();
    List<LiftNumber> lifts = calculateTrainingNumbers(excerciseTrainingMax, week.coreLifts);
    List<LiftNumber> cycleLift = calculateTrainingNumbers(excerciseTrainingMax, week.cycleLift);

    return TappableCard(
        sectionTitle: 'Todays Training',
        cartContent: HomeCard(
          user.currentExcercise.title,
          Row(
            children: [
              Wrap(
                children: [
                  Column(children: buildAndformatLiftNumbers(lifts)),
                  Column(children: [
                    Padding(padding: EdgeInsets.only(left: 32), child: Text(buildSetOutput(cycleLift[0]) +" "+ WeightReps(cycleLift[0].weight, cycleLift[0].reps).toString()))
                  ]),
                ]
              ),
            ],
          ), 
          'graphics/${user.currentExcercise.abrevation}.png',
          changeable: true),
        route: '/excercise');
  });
}

/// Returns the calculated weights for a given List of Lift Numbers
calculateTrainingNumbers(int trainingMax, List<LiftNumber> program ) => 
program.map((e) => LiftNumber(e.weightPercentage, e.reps, weight: (e.weightPercentage/100 * trainingMax), sets: e.sets, pr: e.pr)).toList();

/// Build training output
buildAndformatLiftNumbers(List<LiftNumber> lifts){
  return lifts.map((e) => Text(WeightReps(e.weight, e.reps).toString())
  ).toList();
}

LiftDay getCurrentWeek(UserProfile user){
  int week = user.cycleWeek;
  if(week == 1) return user.program.week1;
  if(week == 2) return user.program.week2;
  else return user.program.week3;
}


buildSetOutput(LiftNumber lift){
  int sets = lift.sets;
  if(sets > 1){
    return '$sets sets of';
  }
  return '$sets set of';
}