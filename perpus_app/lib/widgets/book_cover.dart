// lib/widgets/book_cover.dart
import 'package:flutter/material.dart';

/// Sampul buku dengan inisial judul dan warna dinamis berbasis hash judul.
class BookCover extends StatelessWidget {
  final String title;
  final int? id;
  final double width;
  final double height;
  final double borderRadius;
  final String? heroTag;

  const BookCover({
    super.key,
    required this.title,
    this.id,
    this.width = 46,
    this.height = 62,
    this.borderRadius = 8,
    this.heroTag,
  });

  /// Palet warna elegan bernuansa akademis
  static const List<Color> _palette = [
    Color(0xFF0F766E), // Teal
    Color(0xFF0E7490), // Cyan
    Color(0xFF4338CA), // Indigo
    Color(0xFFB45309), // Amber
    Color(0xFF047857), // Emerald
    Color(0xFFBE123C), // Rose
    Color(0xFF475569), // Slate
    Color(0xFF6D28D9), // Purple
  ];

  Color _resolveColor() {
    if (id != null) {
      return _palette[id! % _palette.length];
    }
    var hash = 0;
    for (var i = 0; i < title.length; i++) {
      hash = title.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return _palette[hash.abs() % _palette.length];
  }

  String _getInitials() {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'B';
    if (words.length == 1) {
      final w = words.first;
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _resolveColor();
    final initials = _getInitials();

    Widget cover = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Aksen pita jilid buku di sisi kiri (spine effect)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: width * 0.14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  bottomLeft: Radius.circular(borderRadius),
                ),
              ),
            ),
          ),
          // Garis lipatan jilid
          Positioned(
            left: width * 0.14,
            top: 0,
            bottom: 0,
            width: 1,
            child: Container(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          // Inisial judul di tengah
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.14),
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(type: MaterialType.transparency, child: cover),
      );
    }
    return cover;
  }
}
