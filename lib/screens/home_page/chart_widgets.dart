import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'package:myapp/local_data/database_entry.dart';

class TempHumChart extends StatelessWidget {
  final List<Entry> entryData;

  TempHumChart(this.entryData);

  static List<charts.Series<Entry, DateTime>> _parseEntries(List<Entry> data) {
    return  [
      new charts.Series<Entry, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Entry e, _) => new DateTime.fromMillisecondsSinceEpoch(e.time * 1000),
        measureFn:  (Entry e, _) => e.temp,
        data: data,
      ),
      new charts.Series<Entry, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (Entry e, _) => new DateTime.fromMillisecondsSinceEpoch(e.time * 1000),
        measureFn: (Entry e, _) => e.hum,
        data: data,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId')
    ];
  }

  @override
  Widget build (BuildContext context) {
    return new charts.TimeSeriesChart(
      _parseEntries(entryData), 
      animate: true,
      domainAxis: new charts.DateTimeAxisSpec(
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
          minute: new charts.TimeFormatterSpec(
            format: 'hh:mm', transitionFormat: 'hh:mm'
          ),
          day: new charts.TimeFormatterSpec(
            format: 'M/d/yy', transitionFormat: 'M/d/yy'
          )
        ),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
      ),
      secondaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
      ),
      behaviors: [
        new charts.LinePointHighlighter()
      ],
    );
  }
}