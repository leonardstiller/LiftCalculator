import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liftcalculator/models/appBar.dart';
import 'package:liftcalculator/models/card.dart';
import 'package:liftcalculator/models/databaseLoadIndicator.dart';
import 'package:liftcalculator/models/drawer.dart';
import 'package:liftcalculator/models/dbLift.dart';
import 'package:liftcalculator/models/lift.dart';
import 'package:liftcalculator/util/globals.dart';

class StatsPerDayScreen extends StatefulWidget {
  @override
  _StatsPerDayScreenState createState() => _StatsPerDayScreenState();
}

class _StatsPerDayScreenState extends State<StatsPerDayScreen> {
  DateTime _selectedDate = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Lift Diary"),
      drawer: buildDrawer(context),
      body: ListView(
        children: [
          Center(
              child: ButtonBar(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                onPressed: () => setState(() {
                      _selectedDate = _selectedDate.subtract(Duration(days: 1));
                    }),
                icon: Icon(Icons.arrow_left)),
            TextButton(
              onPressed: selectDate,
              child: Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            IconButton(
                onPressed: () => setState(() {
                      _selectedDate = _selectedDate.add(Duration(days: 1));
                    }),
                icon: Icon(Icons.arrow_right)),
          ])),
          Divider(
            height: 0,
            thickness: 2.5,
          ),
          buildDiary(_selectedDate)
        ],
      ),
    );
  }

  buildDiary(DateTime _selectedDate) {
    return FutureBuilder(
        future: dataFetcher(_selectedDate),
        builder: (BuildContext context, AsyncSnapshot<List<DbLift>> snapshot) {
          Widget output;
          if (snapshot.hasData) {
            List<DbLift> data = snapshot.data!;
            if (data.length == 0)
              output = Text('You have not performed any lifts on this day');
            else {
              // Assume we only perform 1 lift p. selected day
              Lift performedLift = GLOBAL_ALL_LIFTS[data[0].id];
              var stats = data
                  .map((e) => Row(
                        children: [
                          Text(e.weightRep.toString()),
                          Text(' (Calculated 1RM: ${e.calculated1RM})')
                        ],
                      ))
                  .toList();
              print('length ${stats.length}');
              output = NonTappableCard(
                  cartContent: HomeCard(
                      performedLift.title,
                      Column(children: stats),
                      'graphics/${performedLift.abbreviation}.png'),
                  customHeight: 250 + (stats.length * 16));
            }
          } else
            output =
                Center(child: Column(children: [...dataFetchingIndicator()]));
          return output;
        });
  }

  /// Queries the data from the db
  Future<List<DbLift>> dataFetcher(DateTime date) async {
    return await LiftHelper().getLiftsPerDay(date);
  }

  selectDate() async {
    var newDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2021, 1),
        lastDate: DateTime(2022, 7));
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }
}
