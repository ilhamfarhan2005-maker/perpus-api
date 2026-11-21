// lib/views/books/book_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_exception.dart';
import '../../models/book_model.dart';

typedef BookSubmit = Future<ApiException?> Function(Map<String, dynamic> payload);

/// Form tambah/edit buku. Dialog tetap terbuka jika backend menolak
/// (mis. ISBN duplikat) dan menampilkan pesan error di field terkait.
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
    final isEdit = widget.book != null;
    final maxYear = DateTime.now().year;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEdit ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEdit ? Icons.edit_note_rounded : Icons.library_add_rounded,
              color: isEdit ? const Color(0xFFD97706) : const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(isEdit ? 'Edit Buku' : 'Tambah Buku'),
        ],
      ),
      content: SizedBox(
        width: 440,
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
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                _field(_titleCtrl, 'Judul', 'title', icon: Icons.title_rounded, required: true, maxLength: 255),
                _field(_authorCtrl, 'Penulis', 'author', icon: Icons.person_outline_rounded, required: true, maxLength: 255),
                _field(_publisherCtrl, 'Penerbit', 'publisher', icon: Icons.business_outlined, maxLength: 255),
                _field(_isbnCtrl, 'ISBN', 'isbn', icon: Icons.qr_code_rounded, required: true, maxLength: 20),
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
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 42),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Simpan' : 'Tambah'),
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
