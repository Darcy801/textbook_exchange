enum BookCategory { textbook, notes, stationery }

enum BookCondition { likeNew, good, fair }

enum BookLanguage { chinese, english }

enum Campus { main, east, west }

enum Currency { cny, usd }

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.isbn,
    required this.category,
    required this.condition,
    required this.language,
    required this.campus,
    required this.priceCny,
    required this.seller,
    required this.contact,
    this.isMine = false,
    this.sold = false,
  });

  final int id;
  final String title;
  final String titleEn;
  final String isbn;
  final BookCategory category;
  final BookCondition condition;
  final BookLanguage language;
  final Campus campus;
  final double priceCny;
  final String seller;
  final String contact;
  final bool isMine;
  final bool sold;

  static const double usdRate = 7.2;

  double get priceUsd => priceCny / usdRate;

  String priceText(Currency currency) {
    if (currency == Currency.usd) {
      return '\$ ${priceUsd.toStringAsFixed(2)}';
    }
    return '¥ ${priceCny.toStringAsFixed(2)}';
  }
}
