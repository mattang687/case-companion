import 'package:flutter/material.dart';
import 'package:myapp/appearance/screen_size.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:provider/provider.dart';

import 'bottom_bar.dart';
import 'data_widget.dart';
import 'chart.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // disconnect if the back button is pressed from the homepage to avoid inability to
      // reconnect on resume
      onWillPop: () {
        InheritedBluetooth inheritedBluetooth =
            Provider.of<InheritedBluetooth>(context);
        return inheritedBluetooth.disconnect();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Case Companion"),
        ),
        body: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeightNoBars(context, divide: 20)),
                ),
                SizedBox(
                    child: DataWidget(),
                    height: screenHeightNoBars(context, divide: 4)),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeightNoBars(context, divide: 20)),
                ),
                SizedBox(
                    child: TempHumChart(),
                    height: screenHeightNoBars(context, divide: 5 / 3)),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeightNoBars(context, divide: 20)),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ),
        ),
        floatingActionButton: FloatingRefreshButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[DeviceInfoWidget(), ButtonWidget()],
            )),
      ),
    );
  }
}
