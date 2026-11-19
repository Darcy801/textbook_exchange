import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/book.dart';
import '../state/catalog_model.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key, this.onPublished});

  final VoidCallback? onPublished;

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _titleEn = TextEditingController();
  final TextEditingController _isbn = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _seller = TextEditingController();

  BookCategory _category = BookCategory.textbook;
  BookCondition _condition = BookCondition.good;
  BookLanguage _language = BookLanguage.chinese;
  Campus _campus = Campus.main;

  @override
  void dispose() {
    _title.dispose();
    _titleEn.dispose();
    _isbn.dispose();
    _price.dispose();
    _seller.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _title.clear();
    _titleEn.clear();
    _isbn.clear();
    _price.clear();
    _seller.clear();
    setState(() {
      _category = BookCategory.textbook;
      _condition = BookCondition.good;
      _language = BookLanguage.chinese;
      _campus = Campus.main;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final l = L10n.read(context);
    final catalog = context.read<CatalogModel>();
    final title = _title.text.trim();
    final book = Book(
      id: catalog.nextId,
      title: title,
      titleEn: _titleEn.text.trim().isEmpty ? title : _titleEn.text.trim(),
      isbn: _isbn.text.trim(),
      category: _category,
      condition: _condition,
      language: _language,
      campus: _campus,
      priceCny: double.parse(_price.text.trim()),
      seller: _seller.text.trim(),
      contact: '站内消息',
      isMine: true,
    );
    catalog.add(book);
    _resetForm();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.publishSuccess)));
    widget.onPublished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.publish)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.publishIntro,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l.bookTitle,
                hintText: l.fillExample,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l.required : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleEn,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l.bookTitleEn,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _isbn,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: InputDecoration(
                labelText: l.isbn,
                hintText: '9787040396638',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (!RegExp(r'^\d{13}$').hasMatch(text)) {
                  return l.isbnInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: l.priceCnyLabel,
                hintText: '25.00',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(value?.trim() ?? '');
                if (price == null || price <= 0) {
                  return l.priceInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _seller,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l.sellerName,
                hintText: l.profileName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l.required : null,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _dropdown<BookCategory>(
                    label: l.t('分类', 'Category'),
                    value: _category,
                    items: BookCategory.values
                        .map(
                          (value) => DropdownMenuItem<BookCategory>(
                            value: value,
                            child: Text(l.category(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<BookCondition>(
                    label: l.condition,
                    value: _condition,
                    items: BookCondition.values
                        .map(
                          (value) => DropdownMenuItem<BookCondition>(
                            value: value,
                            child: Text(l.conditionName(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _condition = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dropdown<BookLanguage>(
                    label: l.language,
                    value: _language,
                    items: BookLanguage.values
                        .map(
                          (value) => DropdownMenuItem<BookLanguage>(
                            value: value,
                            child: Text(l.bookLanguage(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _language = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<Campus>(
                    label: l.campus,
                    value: _campus,
                    items: Campus.values
                        .map(
                          (value) => DropdownMenuItem<Campus>(
                            value: value,
                            child: Text(l.campusName(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _campus = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.publish),
              label: Text(l.submit),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _resetForm, child: Text(l.reset)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
