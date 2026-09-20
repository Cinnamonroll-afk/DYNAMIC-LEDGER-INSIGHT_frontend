import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/settings/bloc/language_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageCubit — initial state', () {
    test('initial state is Locale("en")', () {
      final cubit = LanguageCubit();
      expect(cubit.state, const Locale('en'));
      cubit.close();
    });
  });

  group('LanguageCubit — _loadLanguage on construction', () {
    test('loads saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'th'});
      final cubit = LanguageCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, const Locale('th'));
      await cubit.close();
    });

    test('keeps Locale("en") when no language saved', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LanguageCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });
  });

  group('LanguageCubit — changeLanguage', () {
    test('changeLanguage("th") emits Locale("th")', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      expect(cubit.state, const Locale('th'));
      await cubit.close();
    });

    test('changeLanguage("en") emits Locale("en")', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      await cubit.changeLanguage('en');
      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });

    test('changeLanguage persists to SharedPreferences', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'th');
      await cubit.close();
    });

    test('changeLanguage("en") persists "en" to SharedPreferences', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('en');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'en');
      await cubit.close();
    });

    test('language code is accessible via state.languageCode', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      expect(cubit.state.languageCode, 'th');
      await cubit.close();
    });

    test('multiple changeLanguage calls emit correct final state', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      await cubit.changeLanguage('en');
      await cubit.changeLanguage('th');
      expect(cubit.state, const Locale('th'));
      await cubit.close();
    });

    test('state after change is a Locale with correct countryCode null', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('th');
      expect(cubit.state.countryCode, isNull);
      await cubit.close();
    });

    test('new LanguageCubit after save loads saved language', () async {
      final cubit1 = LanguageCubit();
      await cubit1.changeLanguage('th');
      await cubit1.close();

      final cubit2 = LanguageCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit2.state, const Locale('th'));
      await cubit2.close();
    });
  });
}
