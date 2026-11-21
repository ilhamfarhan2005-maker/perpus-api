// lib/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_vm.dart';
import '../../widgets/auth_scaffold.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
          _confirmCtrl.text,
        );
    if (ok && mounted) Navigator.pushReplacementNamed(context, AppRoutes.books);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final fe = auth.fieldErrors;

    return AuthScaffold(
      title: 'Daftar Akun Baru',
      subtitle: 'Buat akun untuk mulai mengelola koleksi buku kampus',
      error: fe.isEmpty ? auth.error : null,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'e.g. Mahasiswa / Dosen',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  errorText: fe['name'],
                  counterText: '',
                ),
                textInputAction: TextInputAction.next,
                maxLength: 100,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email Kampus',
                  hintText: 'nama@kampus.ac.id',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                  errorText: fe['email'],
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimal 8 karakter',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  errorText: fe['password'],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    tooltip: _obscure ? 'Lihat password' : 'Sembunyikan password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password',
                  prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                ),
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                  if (v != _passCtrl.text) return 'Konfirmasi password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              LoadingButton(
                loading: auth.loading,
                label: 'Daftar Sekarang',
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).clearError();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk di sini',
                          style: TextStyle(
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
