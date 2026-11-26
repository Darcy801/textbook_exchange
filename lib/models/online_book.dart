class OnlineBook {
  const OnlineBook({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.rating,
    required this.borrowCount,
    required this.month,
  });

  final String id;
  final String title;
  final String category;
  final String author;
  final int rating;
  final int borrowCount;
  final String month;

  factory OnlineBook.fromJson(Map<String, dynamic> json) => OnlineBook(
    id: json['id'] as String? ?? 'unknown',
    title: json['title'] as String? ?? '（无书名）',
    category: json['category'] as String? ?? '未分类',
    author: json['author'] as String? ?? '佚名',
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    borrowCount: (json['borrowCount'] as num?)?.toInt() ?? 0,
    month: json['month'] as String? ?? '—',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'author': author,
    'rating': rating,
    'borrowCount': borrowCount,
    'month': month,
  };
}
