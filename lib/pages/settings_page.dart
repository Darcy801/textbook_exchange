import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/catalog_model.dart';
import '../state/favorites_model.dart';
import '../state/settings_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  Future<void> _clearData(BuildContext context) async {
    final l = L10n.read(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.clearData),
        content: Text(l.clearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    context.read<FavoritesModel>().clear();
    context.read<CatalogModel>().reset();
    context.read<SettingsModel>().reset();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.cleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final settings = context.watch<SettingsModel>();
    final catalog = context.watch<CatalogModel>();
    final favorites = context.watch<FavoritesModel>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Section(
            title: l.interfaceLanguage,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<bool>(value: false, label: Text('中文')),
                  ButtonSegment<bool>(value: true, label: Text('English')),
                ],
                selected: <bool>{settings.english},
                onSelectionChanged: (values) {
                  context.read<SettingsModel>().setEnglish(values.first);
                },
              ),
            ),
          ),
          _Section(
            title: l.currency,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<Currency>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<Currency>(
                    value: Currency.cny,
                    label: Text('CNY ¥'),
                  ),
                  ButtonSegment<Currency>(
                    value: Currency.usd,
                    label: Text('USD \$'),
                  ),
                ],
                selected: <Currency>{settings.currency},
                onSelectionChanged: (values) {
                  context.read<SettingsModel>().setCurrency(values.first);
                },
              ),
            ),
          ),
          _Section(
            title: l.localData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.localDataBody,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.save_outlined, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      l.storageStats(catalog.myBooks.length, favorites.count),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: scheme.error),
              title: Text(l.clearData),
              subtitle: Text(l.clearDataHint),
              trailing: TextButton(
                onPressed: () => _clearData(context),
                child: Text(l.clear),
              ),
            ),
          ),
          _Section(
            title: l.about,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.aboutBody,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 10),
                Text(
                  l.version,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
