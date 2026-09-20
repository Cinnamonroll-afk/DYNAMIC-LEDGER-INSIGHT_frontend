import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _languageKey = 'app_language';

  LanguageCubit() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    emit(Locale(languageCode));
  }
}
