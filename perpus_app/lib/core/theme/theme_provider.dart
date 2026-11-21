// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk mengelola toggle Dark/Light Mode dengan persistensi lokal
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'is_dark_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key);
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, next == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
