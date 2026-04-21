// test/presentation/bloc/theme/theme_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  // ── Initial state loaded from prefs ───────────────────────────────────────
  group('initial state', () {
    test('emits ThemeMode.light when prefs has "light"', () {
      when(() => mockPrefs.getString('app_theme')).thenReturn('light');
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.light);
      cubit.close();
    });

    test('emits ThemeMode.dark when prefs has "dark"', () {
      when(() => mockPrefs.getString('app_theme')).thenReturn('dark');
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });

    test('emits ThemeMode.system when prefs has no entry', () {
      when(() => mockPrefs.getString('app_theme')).thenReturn(null);
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.system);
      cubit.close();
    });

    test('emits ThemeMode.system when prefs has unknown value', () {
      when(() => mockPrefs.getString('app_theme')).thenReturn('unknown');
      final cubit = ThemeCubit(mockPrefs);
      expect(cubit.state, ThemeMode.system);
      cubit.close();
    });
  });

  // ── setTheme ───────────────────────────────────────────────────────────────
  group('setTheme()', () {
    blocTest<ThemeCubit, ThemeMode>(
      'sets ThemeMode.light and persists "light" to prefs',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn(null);
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.setTheme(ThemeMode.light),
      expect: () => [ThemeMode.light],
      verify: (_) {
        verify(() => mockPrefs.setString('app_theme', 'light')).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      'sets ThemeMode.dark and persists "dark" to prefs',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn(null);
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.setTheme(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
      verify: (_) {
        verify(() => mockPrefs.setString('app_theme', 'dark')).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      'sets ThemeMode.system and persists "system" to prefs',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn('dark');
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.setTheme(ThemeMode.system),
      expect: () => [ThemeMode.system],
      verify: (_) {
        verify(() => mockPrefs.setString('app_theme', 'system')).called(1);
      },
    );
  });

  // ── cycleTheme ─────────────────────────────────────────────────────────────
  group('cycleTheme()', () {
    blocTest<ThemeCubit, ThemeMode>(
      'cycles system → light',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn(null); // system
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.cycleTheme(),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'cycles light → dark',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn('light');
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.cycleTheme(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'cycles dark → system',
      build: () {
        when(() => mockPrefs.getString('app_theme')).thenReturn('dark');
        return ThemeCubit(mockPrefs);
      },
      act: (c) => c.cycleTheme(),
      expect: () => [ThemeMode.system],
    );
  });
}
