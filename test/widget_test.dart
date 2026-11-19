import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textbook_exchange/main.dart';
import 'package:textbook_exchange/models/book.dart';
import 'package:textbook_exchange/state/catalog_model.dart';
import 'package:textbook_exchange/state/favorites_model.dart';
import 'package:textbook_exchange/state/settings_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('settings and favorites survive a reload', () async {
    final prefs = await SharedPreferences.getInstance();
    SettingsModel(prefs).setEnglish(true);
    FavoritesModel(prefs).toggle(5);

    expect(SettingsModel(prefs).english, isTrue);
    expect(FavoritesModel(prefs).contains(5), isTrue);
  });

  test('published book survives a reload', () async {
    final prefs = await SharedPreferences.getInstance();
    CatalogModel(prefs).add(
      const Book(
        id: 99,
        title: '测试书',
        titleEn: 'Test Book',
        isbn: '9787000000001',
        category: BookCategory.textbook,
        condition: BookCondition.good,
        language: BookLanguage.chinese,
        campus: Campus.main,
        priceCny: 10,
        seller: '测试',
        contact: '站内消息',
        isMine: true,
      ),
    );

    final reloaded = CatalogModel(prefs);
    expect(reloaded.myBooks.any((book) => book.id == 99), isTrue);
  });

  testWidgets('home page shows the brand title', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(TextbookApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('旧书新知'), findsOneWidget);
  });
}
