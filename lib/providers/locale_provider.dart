import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    state = Locale(code);
  }
}