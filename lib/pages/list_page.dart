import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/catalog_model.dart';
import '../state/favorites_model.dart';
import '../state/settings_model.dart';
import '../widgets/app_choice_chip.dart';
import '../widgets/book_cards.dart';
import '../widgets/book_cover.dart';
import 'detail_page.dart';

class ListPageArgs {
  const ListPageArgs({this.query = '', this.category});

  final String query;
  final BookCategory? category;
}

enum PreviewAction { favorite, open }

enum SortMode { newest, priceAsc }

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.args});

  static const routeName = '/list';

  final ListPageArgs args;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  BookLanguage? _language;
  Campus? _campus;
  RangeValues _price = const RangeValues(0, 150);
  SortMode _sort = SortMode.newest;
  bool _showFilters = false;

  List<Book> _result(List<Book> books) {
    final keyword = widget.args.query.toLowerCase();
    final result = books.where((book) {
      if (book.sold) {
        return false;
      }
      if (widget.args.category != null &&
          book.category != widget.args.category) {
        return false;
      }
      if (keyword.isNotEmpty &&
          !book.title.toLowerCase().contains(keyword) &&
          !book.titleEn.toLowerCase().contains(keyword) &&
          !book.isbn.contains(keyword)) {
        return false;
      }
      if (_language != null && book.language != _language) {
        return false;
      }
      if (_campus != null && book.campus != _campus) {
        return false;
      }
      if (book.priceCny < _price.start || book.priceCny > _price.end) {
        return false;
      }
      return true;
    }).toList();
    if (_sort == SortMode.priceAsc) {
      result.sort((a, b) => a.priceCny.compareTo(b.priceCny));
    } else {
      result.sort((a, b) => b.id.compareTo(a.id));
    }
    return result;
  }

  int get _activeFilters {
    var count = 0;
    if (_language != null) {
      count++;
    }
    if (_campus != null) {
      count++;
    }
    if (_price.start != 0 || _price.end != 150) {
      count++;
    }
    return count;
  }

  void _openDetail(Book book) {
    Navigator.of(context).pushNamed(
      DetailPage.routeName,
      arguments: DetailArgs(book: book, heroTag: 'list-book-${book.id}'),
    );
  }

  Future<void> _showPreview(Book book) async {
    final l = L10n.read(context);
    final currency = context.read<SettingsModel>().currency;
    final action = await showModalBottomSheet<PreviewAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        final saved = sheetContext.watch<FavoritesModel>().contains(book.id);
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.preview,
                  style: Theme.of(sheetContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 100,
                      child: BookCover(book: book),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheetContext).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.titleEn,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.priceText(currency),
                            style: Theme.of(sheetContext).textTheme.titleMedium
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    InfoPill(text: l.category(book.category)),
                    InfoPill(text: l.conditionName(book.condition)),
                    InfoPill(text: l.bookLanguage(book.language)),
                    InfoPill(text: l.campusName(book.campus)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pop(sheetContext, PreviewAction.favorite),
                        icon: Icon(
                          saved ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        label: Text(saved ? l.favorited : l.favorite),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.pop(sheetContext, PreviewAction.open),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(l.openDetail),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || action == null) {
      return;
    }
    final favorites = context.read<FavoritesModel>();
    if (action == PreviewAction.favorite) {
      favorites.toggle(book.id);
      final saved = favorites.contains(book.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saved ? l.favorited : l.favoriteRemoved)),
      );
    } else {
      _openDetail(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final settings = context.watch<SettingsModel>();
    final books = context.watch<CatalogModel>().books;
    final items = _result(books);
    final favorites = context.watch<FavoritesModel>();
    final scheme = Theme.of(context).colorScheme;

    final title = widget.args.query.isNotEmpty
        ? '"${widget.args.query}"'
        : widget.args.category == null
        ? l.all
        : l.category(widget.args.category!);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l.filters,
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Badge(
              isLabelVisible: _activeFilters > 0,
              label: Text('$_activeFilters'),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _showFilters
                ? _buildFilterPanel(l, settings)
                : const SizedBox(width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Row(
              children: [
                Text(
                  l.listings(items.length),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  l.swipeTip,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l.noResult,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.noResultHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final book = items[index];
                      final saved = favorites.contains(book.id);
                      return Dismissible(
                        key: ValueKey<String>('book-${book.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.bookmark_add_outlined,
                            color: scheme.primary,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          final model = context.read<FavoritesModel>();
                          model.toggle(book.id);
                          final nowSaved = model.contains(book.id);
                          if (!mounted) {
                            return false;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                nowSaved ? l.favorited : l.favoriteRemoved,
                              ),
                            ),
                          );
                          return false;
                        },
                        child: BookRow(
                          book: book,
                          heroTag: 'list-book-${book.id}',
                          onTap: () => _openDetail(book),
                          onLongPress: () => _showPreview(book),
                          trailing: IconButton(
                            onPressed: () {
                              context.read<FavoritesModel>().toggle(book.id);
                            },
                            icon: Icon(
                              saved ? Icons.bookmark : Icons.bookmark_border,
                              color: saved ? scheme.primary : scheme.outline,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(L10n l, SettingsModel settings) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SortMode>(
            initialValue: _sort,
            decoration: InputDecoration(
              labelText: l.sort,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: SortMode.newest, child: Text(l.newest)),
              DropdownMenuItem(
                value: SortMode.priceAsc,
                child: Text(l.lowestPrice),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sort = value);
              }
            },
          ),
          const SizedBox(height: 12),
          Text(l.language, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _filterChip(l.anyLanguage, _language == null, () {
                setState(() => _language = null);
              }),
              ...BookLanguage.values.map(
                (value) => _filterChip(
                  l.bookLanguage(value),
                  _language == value,
                  () => setState(() => _language = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l.campus, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _filterChip(l.anyCampus, _campus == null, () {
                setState(() => _campus = null);
              }),
              ...Campus.values.map(
                (value) => _filterChip(
                  l.campusName(value),
                  _campus == value,
                  () => setState(() => _campus = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                l.priceRange,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                '${_priceText(settings.currency, _price.start)} - ${_priceText(settings.currency, _price.end)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          RangeSlider(
            values: _price,
            max: 150,
            divisions: 30,
            labels: RangeLabels(
              _priceText(settings.currency, _price.start),
              _priceText(settings.currency, _price.end),
            ),
            onChanged: (values) => setState(() => _price = values),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onSelected) {
    return AppChoiceChip(label: label, selected: selected, onTap: onSelected);
  }

  String _priceText(Currency currency, double value) {
    if (currency == Currency.usd) {
      return '\$${(value / Book.usdRate).toStringAsFixed(0)}';
    }
    return '¥${value.toStringAsFixed(0)}';
  }
}
