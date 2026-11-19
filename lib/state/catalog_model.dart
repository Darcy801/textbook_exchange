import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/books.dart';
import '../models/book.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel(this._prefs) {
    _books = <Book>[..._loadMyBooks(), ...seedBooks];
  }

  static const String _storageKey = 'my_books';

  final SharedPreferences _prefs;
  late List<Book> _books;

  List<Book> get books => List<Book>.unmodifiable(_books);

  List<Book> get myBooks => _books.where((book) => book.isMine).toList();

  int get nextId =>
      _books.fold<int>(0, (maxId, book) => book.id > maxId ? book.id : maxId) +
      1;

  void add(Book book) {
    _books = <Book>[book, ..._books];
    _persistMyBooks();
    notifyListeners();
  }

  void reset() {
    _books = List<Book>.of(seedBooks);
    _prefs.remove(_storageKey);
    notifyListeners();
  }

  List<Book> _loadMyBooks() {
    final raw = _prefs.getStringList(_storageKey) ?? const <String>[];
    return raw.map(_decode).whereType<Book>().toList();
  }

  Book? _decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Book(
        id: map['id'] as int,
        title: map['title'] as String,
        titleEn: map['titleEn'] as String,
        isbn: map['isbn'] as String,
        category: BookCategory.values[map['category'] as int],
        condition: BookCondition.values[map['condition'] as int],
        language: BookLanguage.values[map['language'] as int],
        campus: Campus.values[map['campus'] as int],
        priceCny: (map['priceCny'] as num).toDouble(),
        seller: map['seller'] as String,
        contact: map['contact'] as String,
        isMine: true,
        sold: map['sold'] as bool? ?? false,
      );
    } catch (error) {
      debugPrint('Skip broken book record: $error');
      return null;
    }
  }

  String _encode(Book book) {
    return jsonEncode(<String, Object>{
      'id': book.id,
      'title': book.title,
      'titleEn': book.titleEn,
      'isbn': book.isbn,
      'category': book.category.index,
      'condition': book.condition.index,
      'language': book.language.index,
      'campus': book.campus.index,
      'priceCny': book.priceCny,
      'seller': book.seller,
      'contact': book.contact,
      'sold': book.sold,
    });
  }

  void _persistMyBooks() {
    final records = _books.where((book) => book.isMine).map(_encode).toList();
    _prefs.setStringList(_storageKey, records);
  }
}
