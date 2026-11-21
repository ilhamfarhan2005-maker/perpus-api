import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/splash_view.dart';
import 'views/books/books_view.dart';

void main() {
  runApp(const ProviderScope(child: PerpusApp()));
}

class PerpusApp extends ConsumerWidget {
  const PerpusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Perpustakaan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashView(),
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.register: (_) => const RegisterView(),
        AppRoutes.books: (_) => const BooksView(),
      },
    );
  }
}
