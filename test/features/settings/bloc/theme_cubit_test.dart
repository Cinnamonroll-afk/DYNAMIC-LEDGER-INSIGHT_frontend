// Coverage: URS-06-08 (Dark/Light theme toggle)
// ThemeCubit is a simple cubit with no persistence (theme resets to dark on restart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fincontrol/features/settings/bloc/theme_cubit.dart';

void main() {
  group('ThemeCubit — initial state', () {
    test('defaults to ThemeMode.dark (Glassmorphism design)', () {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });
  });

  group('ThemeCubit — toggleTheme', () {
    blocTest<ThemeCubit, ThemeMode>(
      'toggleTheme dark→light emits ThemeMode.light',
      build: () => ThemeCubit(),
      act: (c) => c.toggleTheme(),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'toggleTheme light→dark emits ThemeMode.dark',
      build: () => ThemeCubit(),
      seed: () => ThemeMode.light,
      act: (c) => c.toggleTheme(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'double toggle returns to ThemeMode.dark',
      build: () => ThemeCubit(),
      act: (c) {
        c.toggleTheme();
        c.toggleTheme();
      },
      expect: () => [ThemeMode.light, ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'triple toggle ends on ThemeMode.light',
      build: () => ThemeCubit(),
      act: (c) {
        c.toggleTheme();
        c.toggleTheme();
        c.toggleTheme();
      },
      expect: () => [ThemeMode.light, ThemeMode.dark, ThemeMode.light],
    );
  });

  group('ThemeCubit — no persistence (known limitation)', () {
    test('new cubit always starts as dark regardless of previous toggle', () {
      // ThemeCubit does NOT persist to SharedPreferences — theme resets on restart.
      final cubit1 = ThemeCubit();
      cubit1.toggleTheme(); // switch to light
      expect(cubit1.state, ThemeMode.light);
      cubit1.close();

      // A brand-new cubit starts dark again — no persistence
      final cubit2 = ThemeCubit();
      expect(cubit2.state, ThemeMode.dark);
      cubit2.close();
    });
  });
}
