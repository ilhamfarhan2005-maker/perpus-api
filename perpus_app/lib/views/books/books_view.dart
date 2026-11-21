// lib/views/books/books_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book_model.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/stats_dashboard.dart';
import 'book_form_dialog.dart';

enum StockFilter { all, lowStock, outOfStock }
enum BookSort { titleAsc, titleDesc, stockDesc, yearDesc }

class BooksView extends ConsumerStatefulWidget {
  const BooksView({super.key});

  @override
  ConsumerState<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends ConsumerState<BooksView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  StockFilter _stockFilter = StockFilter.all;
  BookSort _bookSort = BookSort.titleAsc;

  BookNotifier get _vm => ref.read(bookProvider.notifier);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => _vm.load(search: ''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.extentAfter < 300) _loadMore();
  }

  Future<void> _loadMore() async {
    final err = await _vm.loadMore();
    if (err != null) _toast(err, isError: true);
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _vm.load(search: val.trim());
    });
    setState(() {});
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _debounce?.cancel();
    _vm.load(search: '');
    setState(() {});
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError
            ? (isDark ? const Color(0xFF991B1B) : AppColors.stockZero)
            : (isDark ? AppColors.darkSurface : AppColors.textPrimary),
      ));
  }

  Future<void> _openForm([BookModel? book]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookFormDialog(
        book: book,
        onSubmit: (payload) =>
            book == null ? _vm.create(payload) : _vm.update(book.id, payload),
      ),
    );
    if (saved == true) {
      _toast(book == null ? 'Buku berhasil ditambahkan ke katalog' : 'Perubahan buku berhasil disimpan');
    }
  }

  Future<void> _confirmDelete(BookModel book) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450A0A) : AppColors.stockZeroBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? const Color(0xFFF87171) : AppColors.stockZero,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Buku',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${book.title}"? Data yang dihapus tidak dapat dipulihkan kembali.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF991B1B) : AppColors.stockZero,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Sekarang'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final err = await _vm.delete(book.id);
    _toast(err ?? 'Buku "${book.title}" berhasil dihapus', isError: err != null);
  }

  Future<void> _confirmLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
        title: Text(
          'Konfirmasi Keluar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sesi perpustakaan ini?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF991B1B) : AppColors.stockZero,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).logout();
      _vm.reset();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  List<BookModel> _filterAndSort(List<BookModel> original) {
    var result = List<BookModel>.from(original);

    // Filter
    if (_stockFilter == StockFilter.lowStock) {
      result = result.where((b) => b.stock > 0 && b.stock < 10).toList();
    } else if (_stockFilter == StockFilter.outOfStock) {
      result = result.where((b) => b.stock == 0).toList();
    }

    // Sort
    switch (_bookSort) {
      case BookSort.titleAsc:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case BookSort.titleDesc:
        result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case BookSort.stockDesc:
        result.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case BookSort.yearDesc:
        result.sort((a, b) => b.publishedYear.compareTo(a.publishedYear));
        break;
    }
    return result;
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: (v) {
          _debounce?.cancel();
          _vm.load(search: v.trim());
        },
        decoration: InputDecoration(
          hintText: 'Cari judul buku, penulis, atau ISBN…',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  tooltip: 'Hapus pencarian',
                  onPressed: _clearSearch,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterAndSortBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Filter Chips
          _filterChip(
            label: 'Semua',
            selected: _stockFilter == StockFilter.all,
            onSelected: () => setState(() => _stockFilter = StockFilter.all),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Stok Menipis',
            selected: _stockFilter == StockFilter.lowStock,
            icon: Icons.priority_high_rounded,
            onSelected: () => setState(() => _stockFilter = StockFilter.lowStock),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Stok Habis',
            selected: _stockFilter == StockFilter.outOfStock,
            icon: Icons.cancel_outlined,
            onSelected: () => setState(() => _stockFilter = StockFilter.outOfStock),
            isDark: isDark,
          ),
          const SizedBox(width: 14),

          // Divider
          Container(
            height: 24,
            width: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          const SizedBox(width: 14),

          // Sort Popup Menu
          PopupMenuButton<BookSort>(
            tooltip: 'Urutkan buku',
            initialValue: _bookSort,
            onSelected: (sort) => setState(() => _bookSort = sort),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(_bookSort),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: BookSort.titleAsc, child: Text('Judul (A - Z)')),
              PopupMenuItem(value: BookSort.titleDesc, child: Text('Judul (Z - A)')),
              PopupMenuItem(value: BookSort.stockDesc, child: Text('Stok Terbanyak')),
              PopupMenuItem(value: BookSort.yearDesc, child: Text('Tahun Terkini')),
            ],
          ),
        ],
      ),
    );
  }

  String _sortLabel(BookSort sort) {
    switch (sort) {
      case BookSort.titleAsc:
        return 'Judul (A-Z)';
      case BookSort.titleDesc:
        return 'Judul (Z-A)';
      case BookSort.stockDesc:
        return 'Stok Terbanyak';
      case BookSort.yearDesc:
        return 'Tahun Terkini';
    }
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required bool isDark,
    IconData? icon,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: activeColor,
      backgroundColor: isDark ? AppColors.darkInputFill : AppColors.inputFill,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected
            ? Colors.white
            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      ),
      side: BorderSide(
        color: selected
            ? activeColor
            : (isDark ? AppColors.darkBorder : AppColors.border),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildBody(BookState state, {required bool isDesktopGrid}) {
    if (state.loading && state.books.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SkeletonList(count: 6),
      );
    }

    if (state.error != null && state.books.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: () => _vm.load(search: _searchCtrl.text.trim()),
      );
    }

    final displayedBooks = _filterAndSort(state.books);

    if (displayedBooks.isEmpty) {
      if (state.search.isNotEmpty || _stockFilter != StockFilter.all) {
        return EmptyState(
          title: 'Tidak Ada Buku yang Cocok',
          message: 'Coba ubah kata kunci pencarian atau bersihkan filter stok.',
          icon: Icons.search_off_rounded,
          actionLabel: 'Reset Pencarian',
          onAction: () {
            setState(() => _stockFilter = StockFilter.all);
            _clearSearch();
          },
        );
      }
      return EmptyState(
        title: 'Koleksi Masih Kosong',
        message: 'Belum ada buku terdaftar di katalog. Tambahkan buku baru pertama Anda sekarang!',
        icon: Icons.auto_stories_outlined,
        actionLabel: 'Tambah Buku',
        onAction: () => _openForm(),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.primary,
      onRefresh: () => _vm.load(search: _searchCtrl.text.trim()),
      child: isDesktopGrid
          ? CustomScrollView(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: StatsDashboard(
                      books: state.books,
                      totalBooksCount: state.total,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = displayedBooks[index];
                        return BookCard(
                          key: ValueKey(book.id),
                          book: book,
                          onEdit: () => _openForm(book),
                          onDelete: () => _confirmDelete(book),
                        );
                      },
                      childCount: displayedBooks.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _footer(state)),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            )
          : ListView.builder(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: displayedBooks.length + 2, // 1 for stats, 1 for footer
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return StatsDashboard(
                    books: state.books,
                    totalBooksCount: state.total,
                  );
                }
                final bookIndex = i - 1;
                if (bookIndex == displayedBooks.length) {
                  return _footer(state);
                }
                final book = displayedBooks[bookIndex];
                return BookCard(
                  key: ValueKey(book.id),
                  book: book,
                  onEdit: () => _openForm(book),
                  onDelete: () => _confirmDelete(book),
                );
              },
            ),
    );
  }

  Widget _footer(BookState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.loadingMore) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
        ),
      );
    }
    if (state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
            label: const Text('Muat Lebih Banyak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              side: BorderSide(color: isDark ? AppColors.darkPrimary : AppColors.primary),
              minimumSize: const Size(180, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${state.books.length} dari ${state.total} buku ditampilkan',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookProvider);
    final userName = ref.watch(authProvider.select((s) => s.user?.name)) ?? 'Civitas';

    ref.listen(bookProvider.select((s) => s.error), (_, next) {
      if (next != null && ref.read(bookProvider).books.isNotEmpty) {
        _toast(next, isError: true);
      }
    });

    final appBar = AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_library_rounded,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Koleksi Kampus'),
        ],
      ),
      bottom: state.loading && state.books.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2.5),
              child: LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
            )
          : null,
      actions: [
        // Toggle Dark/Light Mode
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? const Color(0xFFFDE047) : AppColors.textPrimary,
          ),
          tooltip: isDark ? 'Beralih ke mode terang' : 'Beralih ke mode gelap',
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Muat ulang data',
          onPressed: state.loading ? null : () => _vm.load(search: _searchCtrl.text.trim()),
        ),
        // Logout
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Keluar akun',
          onPressed: _confirmLogout,
        ),
      ],
    );

    final fab = FloatingActionButton.extended(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Buku', style: TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
    );

    // Mobile Layout (< 600px)
    final mobileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(context),
        _buildFilterAndSortBar(context),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(state, isDesktopGrid: false)),
      ],
    );

    // Tablet & Desktop Content (>= 600px)
    Widget desktopContent(bool isGrid) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(context),
        _buildFilterAndSortBar(context),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(state, isDesktopGrid: isGrid)),
      ],
    );

    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: appBar,
        body: mobileContent,
        floatingActionButton: fab,
      ),
      tablet: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            // Compact NavigationRail
            NavigationRail(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              selectedIndex: 0,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.library_books_rounded),
                  label: Text('Koleksi'),
                ),
              ],
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.15),
                  child: Text(
                    userName.isEmpty ? 'U' : userName[0].toUpperCase(),
                    style: TextStyle(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: desktopContent(false),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: fab,
      ),
      desktop: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            // Extended NavigationRail (>= 1000px)
            NavigationRail(
              extended: true,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              selectedIndex: 0,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.library_books_rounded),
                  label: Text('Katalog Buku'),
                ),
              ],
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.15),
                      child: Text(
                        userName.isEmpty ? 'U' : userName[0].toUpperCase(),
                        style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          'Pustakawan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: desktopContent(true),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: fab,
      ),
    );
  }
}
