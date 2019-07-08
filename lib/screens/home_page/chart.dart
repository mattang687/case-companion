import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';

class TempHumChart extends StatelessWidget {
  // turns list of entries into a graphable Series
  List<charts.Series<Entry, DateTime>> _parseEntries(List<Entry> data, bool inCelsius) {
    return [
      new charts.Series<Entry, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Entry e, _) =>
            new DateTime.fromMillisecondsSinceEpoch(e.time * 1000),
        measureFn: (Entry e, _) {
          if (inCelsius) {
            return e.temp;
          } else {
            return e.temp * 9 / 5 + 32;
          }
        },
        data: data,
      ),
      new charts.Series<Entry, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (Entry e, _) =>
            new DateTime.fromMillisecondsSinceEpoch(e.time * 1000),
        measureFn: (Entry e, _) => e.hum,
        data: data,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId')
    ];
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper db = Provider.of<DatabaseHelper>(context);
    final bool inCelsius = Provider.of<SettingsHelper>(context).inCelsius;
    return SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: charts.TimeSeriesChart(
          _parseEntries(db.data, inCelsius),
          animate: true,
          domainAxis: new charts.DateTimeAxisSpec(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                minute: new charts.TimeFormatterSpec(
                    format: 'hh:mm', transitionFormat: 'hh:mm'),
                day: new charts.TimeFormatterSpec(
                    format: 'M/d/yy', transitionFormat: 'M/d/yy')),
          ),
          primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
          ),
          secondaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
          ),
          behaviors: [new charts.LinePointHighlighter()],
        ));
  }
}
