import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:myapp/appearance/screen_size.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';

class TempHumChart extends StatelessWidget {
  // turns list of entries into a graphable Series
  List<charts.Series<Entry, DateTime>> _parseEntries(
      List<Entry> data, bool inCelsius, Color tempColor, Color humColor) {
    return [
      new charts.Series<Entry, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => tempColor,
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
        colorFn: (_, __) => humColor,
        domainFn: (Entry e, _) =>
            new DateTime.fromMillisecondsSinceEpoch(e.time * 1000),
        measureFn: (Entry e, _) => e.hum,
        data: data,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId')
    ];
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    int tempRed = theme.highlightColor.red;
    int tempGreen = theme.highlightColor.green;
    int tempBlue = theme.highlightColor.blue;
    Color tempColor = Color(r: tempRed, g: tempGreen, b: tempBlue);

    int humRed = theme.primaryColorDark.red;
    int humGreen = theme.primaryColorDark.green;
    int humBlue = theme.primaryColorDark.blue;
    Color humColor = Color(r: humRed, g: humGreen, b: humBlue);

    DatabaseHelper db = Provider.of<DatabaseHelper>(context);
    final bool inCelsius = Provider.of<SettingsHelper>(context).inCelsius;
    return SizedBox(
      height: screenHeightNoBars(context, divide: 2),
      width: screenWidth(context, subtract: 6),
      child: charts.TimeSeriesChart(
        _parseEntries(db.data, inCelsius, tempColor, humColor),
        animate: true,
        domainAxis: new charts.DateTimeAxisSpec(
          tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              minute: new charts.TimeFormatterSpec(
                  format: 'h:mm', transitionFormat: 'h:mm'),
              hour: new charts.TimeFormatterSpec(
                  format: 'h:mm', transitionFormat: 'h:mm'),
              day: new charts.TimeFormatterSpec(
                  format: 'M/d/yy', transitionFormat: 'M/d/yy')),
          renderSpec: new charts.SmallTickRendererSpec(
            labelStyle: new charts.TextStyleSpec(
              color: charts.MaterialPalette.black,
              fontSize: 12,
            ),
          ),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec: new charts.BasicNumericTickProviderSpec(
              desiredTickCount: 5,
              zeroBound: false,
            ),
            renderSpec: new charts.GridlineRendererSpec(
              labelStyle: new charts.TextStyleSpec(
                color: tempColor,
                fontSize: 12,
              ),
            )),
        secondaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
            desiredTickCount: 5,
            zeroBound: false,
          ),
          renderSpec: new charts.GridlineRendererSpec(
            labelStyle: new charts.TextStyleSpec(
              color: humColor,
              fontSize: 12,
            ),
          ),
        ),
        behaviors: [
          charts.PanAndZoomBehavior(),
          charts.LinePointHighlighter(
              showHorizontalFollowLine:
                  charts.LinePointHighlighterFollowLineType.none,
              showVerticalFollowLine:
                  charts.LinePointHighlighterFollowLineType.nearest),
        ],
      ),
    );
  }
}
