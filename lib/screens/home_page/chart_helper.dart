import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/screens/home_page/chart_widgets.dart';

class ChartWidget extends StatefulWidget {
  final Random rand = Random(123);
  @override
  State<StatefulWidget> createState() {
    return ChartWidgetState();
  }
}

class ChartWidgetState extends State<ChartWidget> {
  List<Entry> data = new List<Entry>();

  Future<void> _updateData() async {
    DatabaseHelper db = DatabaseHelper.instance;
      data = await db.queryAllRows();
    setState(() {});
    return;
  }

  Future<void> _insertRandomData(Random rand) async {
    DatabaseHelper db = DatabaseHelper.instance;
    int newYears = 1546300800;
    int newTime = newYears + await db.queryRowCount() * 604800;
    Entry e = new Entry(
        time: newTime,
        temp: rand.nextInt(100),
        hum: rand.nextInt(100));
    await db.insert(e);
    await  _updateData();
    return;
  }
  
  Future<void> _clearData() async {
    DatabaseHelper db = DatabaseHelper.instance;
    await db.clear();
    await _updateData();
    return;
  }

  @override
  void initState() {
    _updateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: TempHumChart(data),
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              child: Text('INSERT'),
              onPressed: () => _insertRandomData(widget.rand),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            RaisedButton(
              child: Text('CLEAR'),
              onPressed: _clearData,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ],
    );
  }
}
