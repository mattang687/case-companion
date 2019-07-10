import 'package:flutter/material.dart';

import 'data_widget.dart';
import 'modal_bottom_sheet.dart';
import 'chart.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Companion"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 30)),
              DataWidget(),
              Padding(padding: EdgeInsets.only(top: 30)),
              TempHumChart(),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return ModalBottomSheet();
            },
          );
        },
      ),
    );
  }
}
