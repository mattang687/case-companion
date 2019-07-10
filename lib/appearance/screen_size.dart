import 'package:flutter/material.dart';

Size _screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context,
    {double divide = 1, double subtract = 0}) {
  return (_screenSize(context).height - subtract) / divide;
}

double screenHeightNoTopBar(BuildContext context, {double divide = 1}) {
  return screenHeight(
    context,
    divide: divide,
    subtract: kToolbarHeight +
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom,
  );
}

double screenHeightNoBars(BuildContext context, {double divide = 1}) {
  return screenHeight(
    context,
    divide: divide,
    subtract: kToolbarHeight +
        kBottomNavigationBarHeight +
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom,
  );
}
