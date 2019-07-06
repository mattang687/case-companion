import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/screens/home_page/chart_widgets.dart';
import 'package:provider/provider.dart';

class ChartWidget extends StatelessWidget {
  ChartWidget(this.inCelsius);
  final bool inCelsius;

  final Random rand = Random(123);

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: TempHumChart(databaseHelper.data, inCelsius),
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              child: Text('INSERT'),
              onPressed: () => databaseHelper.save(
                temp: rand.nextInt(100),
                hum: rand.nextInt(100)
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            RaisedButton(
              child: Text('CLEAR'),
              onPressed: databaseHelper.clearData,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            RaisedButton(
              child: Text('DELETE LAST'),
              onPressed: databaseHelper.deleteOldest,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ],
    );
  }
}
