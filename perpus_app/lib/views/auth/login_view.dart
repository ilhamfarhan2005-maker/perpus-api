// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_router.dart';
import '../../viewmodels/auth_vm.dart';
import '../../widgets/auth_scaffold.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) Navigator.pushReplacementNamed(context, AppRoutes.books);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final generalError = auth.fieldErrors.isEmpty ? auth.error : null;

    return AuthScaffold(
      title: 'Perpustakaan',
      subtitle: 'Masuk dengan akun terdaftar untuk mengelola buku',
      error: generalError,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@example.com',
                    prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                    errorText: auth.fieldErrors['email'],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan kata sandi',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    errorText: auth.fieldErrors['password'],
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                LoadingButton(loading: auth.loading, label: 'Masuk Sekarang', onPressed: _submit),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).clearError();
                      Navigator.pushReplacementNamed(context, AppRoutes.register);
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Belum punya akun? ',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Daftar di sini',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
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
        ),
      ],
    );
  }
}
