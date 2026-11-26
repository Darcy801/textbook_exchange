import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/online_book.dart';

const String datasetBase =
    'https://myblog.thiswind.work/flutter-book-demos/dataset';
const int onlineTotal = 36;
const int onlinePageSize = 18;

const String _cacheKey = 'online_books_cache';
const String _cacheTimeKey = 'online_books_cache_time';

class ApiException implements Exception {
  const ApiException(this.kind, this.message);

  final String kind;
  final String message;

  @override
  String toString() => message;
}

Future<List<OnlineBook>> fetchBooksPage(int page) async {
  final uri = Uri.parse('$datasetBase/books_page$page.json');
  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw ApiException('http', '服务异常：HTTP ${response.statusCode}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return [
      for (final item in list)
        OnlineBook.fromJson(item as Map<String, dynamic>),
    ];
  } on TimeoutException {
    throw const ApiException('timeout', '请求超时，请稍后再试');
  } on ApiException {
    rethrow;
  } catch (error) {
    final text = error.toString();
    if (text.contains('Socket') ||
        text.contains('Failed to fetch') ||
        text.contains('XMLHttpRequest') ||
        text.contains('ClientException') ||
        text.contains('Network')) {
      throw const ApiException('socket', '网络不可用，请检查网络连接');
    }
    throw const ApiException('parse', '数据解析失败，请稍后再试');
  }
}

Future<List<OnlineBook>> readCachedBooks() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_cacheKey);
  if (raw == null || raw.isEmpty) {
    return const [];
  }
  try {
    final list = jsonDecode(raw) as List;
    return [
      for (final item in list)
        OnlineBook.fromJson(item as Map<String, dynamic>),
    ];
  } catch (_) {
    return const [];
  }
}

Future<DateTime?> readCacheTime() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_cacheTimeKey);
  return raw == null ? null : DateTime.tryParse(raw);
}

Future<void> writeCache(List<OnlineBook> books) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _cacheKey,
    jsonEncode(books.map((book) => book.toJson()).toList()),
  );
  await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
}

Future<void> clearCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_cacheKey);
  await prefs.remove(_cacheTimeKey);
}
