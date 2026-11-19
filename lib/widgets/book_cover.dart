import 'package:flutter/material.dart';

import '../models/book.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.radius = 14,
    this.compact = false,
  });

  final Book book;
  final double radius;
  final bool compact;

  Color get _color => switch (book.category) {
    BookCategory.textbook => const Color(0xFFC3DAF2),
    BookCategory.notes => const Color(0xFFF7CBD8),
    BookCategory.stationery => const Color(0xFFD9D3F2),
  };

  Color get _ink => switch (book.category) {
    BookCategory.textbook => const Color(0xFF264A72),
    BookCategory.notes => const Color(0xFF6E3146),
    BookCategory.stationery => const Color(0xFF443A70),
  };

  IconData get _icon => switch (book.category) {
    BookCategory.textbook => Icons.menu_book_rounded,
    BookCategory.notes => Icons.edit_note_rounded,
    BookCategory.stationery => Icons.brush_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _color,
      borderRadius: BorderRadius.circular(radius),
    );
    if (compact) {
      return Container(
        decoration: decoration,
        child: Center(
          child: Icon(_icon, color: _ink.withValues(alpha: 0.8), size: 24),
        ),
      );
    }
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(_icon, size: 72, color: _ink.withValues(alpha: 0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    book.titleEn,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _ink.withValues(alpha: 0.72),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
