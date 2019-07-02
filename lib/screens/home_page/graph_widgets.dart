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
    return new charts.LineChart(
      seriesList, 
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 3),
      ),
      secondaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 3),
      ),
    );
  }

  static List<charts.Series<Entry, int>> _createSampleData() {
    final data = [
      new Entry(
        time: 0,
        temp: 54,
        hum: 1000
      ),
      new Entry(
        time: 1,
        temp: 23,
        hum: 2000
      ),
      new Entry(
        time: 2,
        temp: 82,
        hum: 3000,
      ),
      new Entry(
        time: 3,
        temp: 32,
        hum: 4000,
      ),
    ];

    return [
      new charts.Series<Entry, int>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Entry e, _) => e.time,
        measureFn:  (Entry e, _) => e.temp,
        data: data,
      ),
      new charts.Series<Entry, int>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (Entry e, _) => e.time,
        measureFn: (Entry e, _) => e.hum,
        data: data,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId')
    ];
  }
}