// lib/views/books/books_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_router.dart';
import '../../models/book_model.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';
import '../../widgets/book_card.dart';
import '../../widgets/responsive_layout.dart';
import 'book_form_dialog.dart';

class BooksView extends ConsumerStatefulWidget {
  const BooksView({super.key});

  @override
  ConsumerState<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends ConsumerState<BooksView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  BookNotifier get _vm => ref.read(bookProvider.notifier);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => _vm.load(search: ''));
  }

  @override
  void dispose() {
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

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
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
            Expanded(child: Text(msg)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
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
      _toast(book == null ? 'Buku berhasil ditambahkan' : 'Perubahan disimpan');
    }
  }

  Future<void> _confirmDelete(BookModel book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Buku'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus buku "${book.title}"? Data yang dihapus tidak dapat dipulihkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final err = await _vm.delete(book.id);
    _toast(err ?? 'Buku berhasil dihapus', isError: err != null);
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
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

  Widget _body(BookState state) {
    if (state.loading && state.books.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat koleksi buku…',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (state.error != null && state.books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _vm.load(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () => _vm.load(),
      child: state.books.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.search.isEmpty
                            ? 'Belum ada koleksi buku.'
                            : 'Tidak ada buku untuk "${state.search}".',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.search.isEmpty
                            ? 'Klik tombol "Tambah" di bawah untuk memasukkan buku.'
                            : 'Coba gunakan kata kunci pencarian yang lain.',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: state.books.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                if (i == state.books.length) return _footer(state);
                final book = state.books[i];
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
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }
    if (state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
            label: const Text('Muat Lebih Banyak'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${state.books.length} dari ${state.total} buku',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookProvider);
    ref.listen(bookProvider.select((s) => s.error), (_, next) {
      if (next != null && ref.read(bookProvider).books.isNotEmpty) _toast(next, isError: true);
    });
    final userName = ref.watch(authProvider.select((s) => s.user?.name)) ?? '';

    final appBar = AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_library_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 10),
          const Text('Koleksi Perpustakaan'),
        ],
      ),
      bottom: state.loading && state.books.isNotEmpty
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Muat ulang',
          onPressed: state.loading ? null : () => _vm.load(),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
          onPressed: _confirmLogout,
        ),
      ],
    );

    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari judul buku atau penulis…',
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded, size: 20),
            onPressed: () {
              _searchCtrl.clear();
              _vm.load(search: '');
            },
          ),
        ),
        onSubmitted: (v) => _vm.load(search: v),
      ),
    );

    final fab = FloatingActionButton.extended(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Buku'),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [searchBar, Expanded(child: _body(state))],
    );

    return ResponsiveLayout(
      mobile: Scaffold(appBar: appBar, body: content, floatingActionButton: fab),
      desktop: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.library_books_rounded),
                  label: Text('Koleksi'),
                ),
              ],
              selectedIndex: 0,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        userName.isEmpty ? '?' : userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        userName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Admin', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: content,
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
