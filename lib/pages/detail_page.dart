import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/favorites_model.dart';
import '../state/settings_model.dart';
import '../widgets/book_cards.dart';
import '../widgets/book_cover.dart';

class DetailArgs {
  const DetailArgs({required this.book, required this.heroTag});

  final Book book;
  final String heroTag;
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.args});

  static const routeName = '/detail';

  final DetailArgs args;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 1.2,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.2,
        end: 1,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_bounce);

  bool _offline = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    final favorites = context.read<FavoritesModel>();
    final id = widget.args.book.id;
    final nowSaved = !favorites.contains(id);
    favorites.toggle(id);
    if (nowSaved) {
      _bounce.forward(from: 0);
    }
  }

  Future<void> _contact() async {
    final l = L10n.read(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    if (_offline) {
      setState(() {
        _loading = false;
        _error = l.networkError;
      });
      return;
    }
    setState(() => _loading = false);
    messenger.showSnackBar(
      SnackBar(content: Text('${l.contact}: ${widget.args.book.contact}')),
    );
  }

  Future<void> _offer() async {
    final l = L10n.read(context);
    final settings = context.read<SettingsModel>();
    final controller = TextEditingController();
    final unit = settings.currency == Currency.cny ? 'CNY' : 'USD';
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.offerTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${l.offerHint} ($unit)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: Text(l.send),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || result == null) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.offerSent)));
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final book = widget.args.book;
    final settings = context.watch<SettingsModel>();
    final saved = context.watch<FavoritesModel>().contains(book.id);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.preview),
        actions: [
          IconButton(
            tooltip: l.simulateOffline,
            onPressed: () => setState(() {
              _offline = !_offline;
              _error = null;
            }),
            icon: Icon(
              _offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
              color: _offline ? scheme.error : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: SizedBox(
              width: 168,
              height: 230,
              child: Hero(
                tag: widget.args.heroTag,
                child: BookCover(book: book),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            book.titleEn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                book.priceText(settings.currency),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 18),
              ScaleTransition(
                scale: _scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: saved ? scheme.primary : scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: saved ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
                  child: IconButton(
                    tooltip: saved ? l.favorited : l.favorite,
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: saved ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              InfoPill(text: l.category(book.category)),
              InfoPill(text: l.conditionName(book.condition)),
              InfoPill(text: l.bookLanguage(book.language)),
              InfoPill(text: l.campusName(book.campus)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          _InfoRow(label: l.isbn, value: book.isbn),
          _InfoRow(label: l.seller, value: book.seller),
          _InfoRow(label: l.contact, value: book.contact),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: scheme.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ),
                        TextButton(onPressed: _contact, child: Text(l.retry)),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            _offline ? l.offlineHint : l.onlineHint,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _offer,
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text(l.negotiate),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _contact,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  label: Text(_loading ? l.loading : l.contactSeller),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
