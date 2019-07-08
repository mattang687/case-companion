import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// stores the unit set by the user in shared preferences
class SettingsHelper with ChangeNotifier {
  bool inCelsius;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // retrieve the setting when the app starts
  SettingsHelper() {
    getUnitSetting();
  }

  Future<void> getUnitSetting() async {
    final SharedPreferences prefs = await _prefs;
    inCelsius = prefs.getBool('inCelsius') ?? true;
    notifyListeners();
    return;
  }

  Future<void> setUnitSetting(bool value) async {
    final SharedPreferences prefs = await _prefs;
    inCelsius = value;
    prefs.setBool('inCelsius', value).then((bool success) => true);
    notifyListeners();
    return;
  }
}
