import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'package:myapp/local_data/database_entry.dart';

class TempHumChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  TempHumChart(this.seriesList, {this.animate});

  factory TempHumChart.withSampleData() {
    return new TempHumChart(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  Widget build (BuildContext context) {
    return new charts.LineChart(seriesList, animate: animate,);
  }

  static List<charts.Series<Entry, int>> _createSampleData() {
    final data = [
      new Entry(
        time: 0,
        temp: 54,
        hum: 36
      ),
      new Entry(
        time: 1,
        temp: 23,
        hum: 67
      ),
      new Entry(
        time: 2,
        temp: 82,
        hum: 45
      ),
      new Entry(
        time: 3,
        temp: 32,
        hum: 54
      ),
    ];

    return [
      new charts.Series<Entry, int>(
        id: 'data',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Entry e, _) => e.time,
        measureFn:  (Entry e, _) => e.temp,
        data: data,
      )
    ];
  }
}