class LiftNumber {
  final double weight;
  final int weightPercentage;
  final int reps;
  final int sets;
  LiftNumber(this.weightPercentage, this.reps, {this.sets = 1, this.weight = 0});
}

class LiftProgram{
  final String name;
  final LiftDay week1;
  final LiftDay week2;
  final LiftDay week3;

  LiftProgram(this.name, this.week1, this.week2, this.week3);
}

class LiftDay {
  final List<LiftNumber> coreLifts;
  final LiftNumber cycleLift;
  LiftDay({required this.coreLifts, required this.cycleLift});
}

final weekOne = LiftDay(
  coreLifts: [LiftNumber(70, 5), LiftNumber(80, 5), LiftNumber(90, 5)],
  cycleLift: LiftNumber(60, 10, sets: 5),
);

// List of supported programs:

final boringButBig = LiftProgram('Boring But Big', weekOne, weekOne, weekOne);
final firstSetLast = LiftProgram('First Set Last', weekOne, weekOne, weekOne);