import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/catalog_model.dart';
import '../state/favorites_model.dart';
import '../state/settings_model.dart';
import '../widgets/book_cards.dart';
import 'detail_page.dart';
import 'settings_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final catalog = context.watch<CatalogModel>();
    final favorites = context.watch<FavoritesModel>();
    final myBooks = catalog.myBooks;
    final savedBooks = catalog.books
        .where((book) => favorites.contains(book.id))
        .toList();
    final onSaleCount = myBooks.where((book) => !book.sold).length;
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.mine),
          actions: [
            IconButton(
              tooltip: l.settings,
              onPressed: () =>
                  Navigator.of(context).pushNamed(SettingsPage.routeName),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.primary,
                    child: Text(
                      l.profileName.substring(0, 1),
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.profileName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.profileRole,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _stat(context, '$onSaleCount', l.statOnSale),
                  const SizedBox(width: 16),
                  _stat(context, '${favorites.count}', l.statFavorites),
                ],
              ),
            ),
            TabBar(
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicatorColor: scheme.primary,
              tabs: [
                Tab(text: l.myListings),
                Tab(text: l.myFavorites),
                Tab(text: l.trades),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _bookList(
                    context,
                    myBooks,
                    emptyText: l.emptyListings,
                    heroPrefix: 'mine',
                    showStatus: true,
                  ),
                  _bookList(
                    context,
                    savedBooks,
                    emptyText: l.emptyFavorites,
                    heroPrefix: 'saved',
                    showStatus: false,
                  ),
                  _trades(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _bookList(
    BuildContext context,
    List<Book> books, {
    required String emptyText,
    required String heroPrefix,
    required bool showStatus,
  }) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 44, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              emptyText,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: books.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = books[index];
        final tag = '$heroPrefix-book-${book.id}';
        return BookRow(
          book: book,
          heroTag: tag,
          onTap: () => Navigator.of(context).pushNamed(
            DetailPage.routeName,
            arguments: DetailArgs(book: book, heroTag: tag),
          ),
          trailing: showStatus
              ? InfoPill(text: book.sold ? l.sold : l.onSale)
              : const Icon(Icons.chevron_right),
        );
      },
    );
  }

  Widget _trades(BuildContext context) {
    final l = L10n.of(context);
    final currency = context.watch<SettingsModel>().currency;
    final scheme = Theme.of(context).colorScheme;
    final trades = <_Trade>[
      const _Trade(
        title: '大学英语综合教程 1',
        date: '2026-10-28',
        priceCny: 15,
        incoming: false,
      ),
      const _Trade(
        title: '线性代数（第六版）',
        date: '2026-10-16',
        priceCny: 18,
        incoming: true,
      ),
      const _Trade(
        title: 'Python编程：从入门到实践',
        date: '2026-09-30',
        priceCny: 45,
        incoming: true,
      ),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: trades.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final trade = trades[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: CircleAvatar(
            backgroundColor: scheme.surfaceContainerHighest,
            child: Icon(
              trade.incoming
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              size: 20,
              color: scheme.primary,
            ),
          ),
          title: Text(
            trade.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${trade.date} · ${l.tradeDone}'),
          trailing: Text(
            trade.incoming
                ? '-${_money(currency, trade.priceCny)}'
                : '+${_money(currency, trade.priceCny)}',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }

  String _money(Currency currency, double value) {
    if (currency == Currency.usd) {
      return '\$${(value / Book.usdRate).toStringAsFixed(2)}';
    }
    return '¥${value.toStringAsFixed(2)}';
  }
}

class _Trade {
  const _Trade({
    required this.title,
    required this.date,
    required this.priceCny,
    required this.incoming,
  });

  final String title;
  final String date;
  final double priceCny;
  final bool incoming;
}
