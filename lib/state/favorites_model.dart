import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  FavoritesModel(this._prefs) {
    final saved = _prefs.getStringList(_storageKey) ?? const <String>[];
    _ids = saved.map(int.tryParse).whereType<int>().toSet();
  }

  static const String _storageKey = 'favorite_ids';

  final SharedPreferences _prefs;
  late Set<int> _ids;

  Set<int> get ids => Set<int>.unmodifiable(_ids);

  int get count => _ids.length;

  bool contains(int id) => _ids.contains(id);

  void toggle(int id) {
    if (!_ids.remove(id)) {
      _ids.add(id);
    }
    _persist();
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    _prefs.remove(_storageKey);
    notifyListeners();
  }

  void _persist() {
    _prefs.setStringList(_storageKey, _ids.map((id) => id.toString()).toList());
  }
}
