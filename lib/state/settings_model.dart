import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs);

  static const String _englishKey = 'settings.english';
  static const String _currencyKey = 'settings.currency';

  final SharedPreferences _prefs;

  bool get english => _prefs.getBool(_englishKey) ?? false;

  Currency get currency =>
      _prefs.getString(_currencyKey) == 'usd' ? Currency.usd : Currency.cny;

  void setEnglish(bool value) {
    if (english == value) {
      return;
    }
    _prefs.setBool(_englishKey, value);
    notifyListeners();
  }

  void setCurrency(Currency value) {
    if (currency == value) {
      return;
    }
    _prefs.setString(_currencyKey, value == Currency.usd ? 'usd' : 'cny');
    notifyListeners();
  }

  void reset() {
    _prefs.remove(_englishKey);
    _prefs.remove(_currencyKey);
    notifyListeners();
  }
}
