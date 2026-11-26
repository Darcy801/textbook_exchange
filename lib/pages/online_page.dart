import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/online_book.dart';
import '../services/book_api.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  static const routeName = '/online';

  @override
  State<OnlinePage> createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  final ScrollController _scroll = ScrollController();

  List<OnlineBook> _books = const [];
  int _page = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _fromCache = false;
  String? _error;
  DateTime? _cacheAt;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _boot();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final cached = await readCachedBooks();
    final cachedAt = await readCacheTime();
    if (!mounted) {
      return;
    }
    if (cached.isNotEmpty) {
      setState(() {
        _books = cached;
        _cacheAt = cachedAt;
        _fromCache = true;
        _loading = false;
        _hasMore = cached.length < onlineTotal;
      });
    }
    await _refresh(showLoading: cached.isEmpty);
  }

  void _onScroll() {
    if (!_scroll.hasClients) {
      return;
    }
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 24) {
      _loadMore();
    }
  }

  Future<void> _refresh({bool showLoading = true}) async {
    if (showLoading && _books.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final first = await fetchBooksPage(1);
      if (!mounted) {
        return;
      }
      if (first.isEmpty) {
        await clearCache();
        if (!mounted) {
          return;
        }
        setState(() {
          _books = const [];
          _page = 0;
          _hasMore = false;
          _loading = false;
          _fromCache = false;
          _cacheAt = null;
          _error = null;
        });
        return;
      }
      setState(() {
        _books = first;
        _page = 1;
        _hasMore = first.length < onlineTotal;
        _loading = false;
        _fromCache = false;
        _cacheAt = DateTime.now();
        _error = null;
      });
      await writeCache(first);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || !_hasMore) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final next = await fetchBooksPage(_page + 1);
      if (!mounted) {
        return;
      }
      setState(() {
        _page += 1;
        _books = [..._books, ...next];
        _hasMore = _books.length < onlineTotal;
        _loadingMore = false;
      });
      await writeCache(_books);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.onlineLibrary),
        actions: [
          IconButton(
            tooltip: l.retry,
            onPressed: _loading
                ? null
                : () => _refresh(showLoading: _books.isEmpty),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _body(l),
    );
  }

  Widget _body(L10n l) {
    if (_loading && _books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(l.loading),
          ],
        ),
      );
    }
    if (_books.isEmpty) {
      if (_error != null) {
        return _ErrorView(message: _error!, onRetry: () => _refresh());
      }
      return _EmptyView(onRetry: () => _refresh());
    }
    return Column(
      children: [
        if (_error != null || _fromCache)
          _CacheBanner(
            cacheAt: _cacheAt,
            onRetry: () => _refresh(showLoading: false),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l.dataSource,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 10.5,
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(showLoading: false),
            child: ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _books.length + 1,
              itemBuilder: (context, index) {
                if (index == _books.length) {
                  return _footer(l);
                }
                final book = _books[index];
                return _OnlineCard(book: book, onTap: () => _showSheet(book));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _footer(L10n l) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          if (_loadingMore)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  l.loadMore,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          else if (!_hasMore)
            Text(
              l.noMore,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
        ],
      ),
    );
  }

  void _showSheet(OnlineBook book) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l = L10n.of(context);
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${book.author} · ${book.month} · ${book.id}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(icon: Icons.category_outlined, text: book.category),
                  _MetaPill(
                    icon: Icons.star_rounded,
                    text: l.rating(book.rating),
                  ),
                  _MetaPill(
                    icon: Icons.local_fire_department_outlined,
                    text: l.popularity(book.borrowCount),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l.onlineBookNote,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.book, required this.onTap});

  final OnlineBook book;
  final VoidCallback onTap;

  static const List<Color> _covers = [
    Color(0xFFDFEEFC),
    Color(0xFFFBE4EE),
    Color(0xFFEDE7FB),
    Color(0xFFE3F3EA),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _covers[book.title.hashCode.abs() % _covers.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  book.title.substring(0, 1),
                  style: TextStyle(
                    color: const Color(0xFF3C5A78),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} · ${book.month}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TinyPill(text: book.category),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 14,
                          color: scheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${book.borrowCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({required this.cacheAt, required this.onRetry});

  final DateTime? cacheAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final time = cacheAt == null
        ? null
        : '${cacheAt!.hour.toString().padLeft(2, '0')}:'
              '${cacheAt!.minute.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.cachedNotice, style: const TextStyle(fontSize: 12)),
                if (time != null)
                  Text(
                    l.cacheAt(time),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 46, color: scheme.outline),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 46, color: scheme.outline),
            const SizedBox(height: 14),
            Text(l.emptyOnline, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}
