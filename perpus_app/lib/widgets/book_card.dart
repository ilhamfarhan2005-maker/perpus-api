// lib/widgets/book_card.dart
import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getSpineColor(int id) {
    const colors = [
      Color(0xFF2563EB), // Blue
      Color(0xFF7C3AED), // Purple
      Color(0xFF0D9488), // Teal
      Color(0xFFD97706), // Amber
      Color(0xFFE11D48), // Rose
      Color(0xFF0284C7), // Sky
      Color(0xFF059669), // Emerald
    ];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final spineColor = _getSpineColor(book.id);
    final isLowStock = book.stock > 0 && book.stock <= 5;
    final isOutOfStock = book.stock == 0;

    final stockColor = isOutOfStock
        ? const Color(0xFFDC2626)
        : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF059669));
    final stockBg = isOutOfStock
        ? const Color(0xFFFEF2F2)
        : (isLowStock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
    final stockLabel = isOutOfStock
        ? 'Habis'
        : (isLowStock ? 'Sisa ${book.stock}' : 'Stok: ${book.stock}');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stylized Book Spine / Thumbnail
              Container(
                width: 44,
                height: 56,
                decoration: BoxDecoration(
                  color: spineColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: spineColor.withValues(alpha: 0.3), width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 22, color: spineColor),
                    const SizedBox(height: 2),
                    Text(
                      '#${book.id}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: spineColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Book Title & Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Year chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${book.publishedYear}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        // Stock chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: stockBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: stockColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            stockLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: stockColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: const Color(0xFF2563EB),
                    tooltip: 'Edit',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: const Color(0xFFDC2626),
                    tooltip: 'Hapus',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.book_rounded, color: Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                book.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              _detailRow(Icons.person_outline_rounded, 'Penulis', book.author),
              if (book.publisher != null)
                _detailRow(Icons.business_outlined, 'Penerbit', book.publisher!),
              _detailRow(Icons.qr_code_rounded, 'ISBN', book.isbn),
              _detailRow(Icons.calendar_today_outlined, 'Tahun Terbit', '${book.publishedYear}'),
              _detailRow(Icons.inventory_2_outlined, 'Stok Tersedia', '${book.stock} buku'),
              if (book.description != null && book.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    book.description!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
