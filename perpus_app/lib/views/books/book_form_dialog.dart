// lib/views/books/book_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';

typedef BookSubmit = Future<ApiException?> Function(Map<String, dynamic> payload);

/// Form tambah/edit buku dengan validasi inline & styling Kampus Modern.
/// Dialog tetap terbuka jika backend menolak (mis. ISBN duplikat) dan menampilkan pesan error.
/// Return `true` saat berhasil disimpan.
class BookFormDialog extends StatefulWidget {
  final BookModel? book; // null = create
  final BookSubmit onSubmit;

  const BookFormDialog({super.key, this.book, required this.onSubmit});

  @override
  State<BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;

  bool _saving = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? '');
    _yearCtrl = TextEditingController(text: b?.publishedYear.toString() ?? '');
    _stockCtrl = TextEditingController(text: b?.stock.toString() ?? '0');
    _descCtrl = TextEditingController(text: b?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _authorCtrl, _publisherCtrl, _isbnCtrl, _yearCtrl, _stockCtrl, _descCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
      _fieldErrors = const {};
    });

    final err = await widget.onSubmit({
      'title': _titleCtrl.text.trim(),
      'author': _authorCtrl.text.trim(),
      'publisher': _nullIfEmpty(_publisherCtrl.text),
      'isbn': _isbnCtrl.text.trim(),
      'published_year': int.parse(_yearCtrl.text.trim()),
      'stock': int.parse(_stockCtrl.text.trim()),
      'description': _nullIfEmpty(_descCtrl.text),
    });

    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _fieldErrors = err.fieldErrors;
        _error = err.fieldErrors.isEmpty ? err.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.book != null;
    final maxYear = DateTime.now().year;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEdit
                  ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                  : (isDark ? const Color(0xFF042F2E) : AppColors.primaryLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEdit ? Icons.edit_note_rounded : Icons.library_add_rounded,
              color: isEdit
                  ? (isDark ? const Color(0xFFFBBF24) : AppColors.accent)
                  : (isDark ? AppColors.darkPrimary : AppColors.primary),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Rincian Buku' : 'Tambah Buku Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isEdit ? 'Perbarui informasi katalog buku' : 'Masukkan informasi buku ke sistem',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF450A0A) : AppColors.stockZeroBg,
                      border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: isDark ? const Color(0xFFF87171) : AppColors.stockZero, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _field(_titleCtrl, 'Judul', 'title', icon: Icons.title_rounded, required: true, maxLength: 255),
                _field(_authorCtrl, 'Penulis', 'author', icon: Icons.person_outline_rounded, required: true, maxLength: 255),
                _field(_publisherCtrl, 'Penerbit', 'publisher', icon: Icons.business_outlined, maxLength: 255),
                _field(_isbnCtrl, 'ISBN', 'isbn', icon: Icons.qr_code_2_rounded, required: true, maxLength: 20),
                _field(
                  _yearCtrl,
                  'Tahun Terbit',
                  'published_year',
                  icon: Icons.calendar_today_outlined,
                  required: true,
                  digitsOnly: true,
                  validator: (v) {
                    final y = int.tryParse(v);
                    if (y == null || y < 1000 || y > maxYear) {
                      return 'Tahun harus antara 1000 dan $maxYear';
                    }
                    return null;
                  },
                ),
                _field(
                  _stockCtrl,
                  'Stok',
                  'stock',
                  icon: Icons.inventory_2_outlined,
                  required: true,
                  digitsOnly: true,
                  validator: (v) => int.tryParse(v) == null ? 'Stok harus angka ≥ 0' : null,
                ),
                _field(_descCtrl, 'Deskripsi', 'description', icon: Icons.notes_rounded, maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(110, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : Text(
                  isEdit ? 'Simpan' : 'Tambah',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String apiField, {
    IconData? icon,
    bool required = false,
    bool digitsOnly = false,
    int maxLines = 1,
    int? maxLength,
    String? Function(String value)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: !_saving,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          errorText: _fieldErrors[apiField],
          counterText: '',
        ),
        keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: (v) {
          final value = v?.trim() ?? '';
          if (required && value.isEmpty) return '$label wajib diisi';
          if (value.isNotEmpty && validator != null) return validator(value);
          return null;
        },
      ),
    );
  }
}
