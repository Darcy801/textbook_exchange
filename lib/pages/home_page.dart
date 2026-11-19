import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/catalog_model.dart';
import '../widgets/app_choice_chip.dart';
import '../widgets/book_cards.dart';
import 'detail_page.dart';
import 'list_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _search = TextEditingController();
  BookCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openList() {
    Navigator.of(context).pushNamed(
      ListPage.routeName,
      arguments: ListPageArgs(query: _search.text.trim(), category: _category),
    );
  }

  void _openDetail(Book book) {
    Navigator.of(context).pushNamed(
      DetailPage.routeName,
      arguments: DetailArgs(book: book, heroTag: 'home-book-${book.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final catalog = context.watch<CatalogModel>();
    final onSale = catalog.books.where((book) => !book.sold).toList();
    final filtered = onSale
        .where((book) => _category == null || book.category == _category)
        .toList();
    final recommended = filtered.take(6).toList();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: scheme.primary),
            const SizedBox(width: 8),
            Text(l.appTitle),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.settings,
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsPage.routeName),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFEEFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.heroTitle,
                            style: TextStyle(
                              color: const Color(0xFF2B537E),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.tagline,
                            style: TextStyle(
                              color: const Color(0xFF4A6C92),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.listings(onSale.length),
                            style: TextStyle(
                              color: const Color(0xFF2B537E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9D9E4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFFB45E7C),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _openList(),
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: l.filters,
                    onPressed: _openList,
                    icon: const Icon(Icons.tune),
                  ),
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _categoryChip(l, null, l.all),
                  ...BookCategory.values.map(
                    (value) => _categoryChip(l, value, l.category(value)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    l.recommended,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _openList, child: Text(l.seeAll)),
                ],
              ),
            ),
          ),
          if (recommended.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 42,
                      color: scheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(l.noResult),
                    const SizedBox(height: 4),
                    Text(
                      l.noResultHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = recommended[index];
                  return BookGridCard(
                    book: book,
                    heroTag: 'home-book-${book.id}',
                    onTap: () => _openDetail(book),
                  );
                }, childCount: recommended.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryChip(L10n l, BookCategory? value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppChoiceChip(
        label: label,
        selected: _category == value,
        onTap: () => setState(() => _category = value),
      ),
    );
  }
}
