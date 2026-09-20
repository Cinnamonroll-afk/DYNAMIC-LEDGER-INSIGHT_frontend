import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── CurrencyState unit tests (pure, no async) ──────────────────────────────

  group('CurrencyState — symbol getter', () {
    test('symbol is dollar sign for USD', () {
      final state = CurrencyState(selectedCurrency: 'USD', usdToThbRate: 35.0);
      expect(state.symbol, '\$');
    });

    test('symbol is baht sign for THB', () {
      final state = CurrencyState(selectedCurrency: 'THB', usdToThbRate: 35.0);
      expect(state.symbol, '฿');
    });
  });

  group('CurrencyState — copyWith', () {
    test('copyWith updates selectedCurrency', () {
      final s = CurrencyState(selectedCurrency: 'USD', usdToThbRate: 35.0);
      final updated = s.copyWith(selectedCurrency: 'THB');
      expect(updated.selectedCurrency, 'THB');
      expect(updated.usdToThbRate, 35.0);
    });

    test('copyWith updates usdToThbRate', () {
      final s = CurrencyState(selectedCurrency: 'USD', usdToThbRate: 35.0);
      final updated = s.copyWith(usdToThbRate: 38.0);
      expect(updated.usdToThbRate, 38.0);
      expect(updated.selectedCurrency, 'USD');
    });

    test('copyWith updates isLoadingRate', () {
      final s = CurrencyState(selectedCurrency: 'USD', usdToThbRate: 35.0);
      final updated = s.copyWith(isLoadingRate: true);
      expect(updated.isLoadingRate, isTrue);
    });
  });

  // ── CurrencyCubit tests ─────────────────────────────────────────────────────

  group('CurrencyCubit — initial state', () {
    test('selectedCurrency is USD by default', () {
      final cubit = CurrencyCubit();
      expect(cubit.state.selectedCurrency, 'USD');
      cubit.close();
    });

    test('usdToThbRate defaults to 35.0', () {
      final cubit = CurrencyCubit();
      expect(cubit.state.usdToThbRate, 35.0);
      cubit.close();
    });
  });

  group('CurrencyCubit — setCurrency', () {
    test('setCurrency THB changes state to THB', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('THB');
      expect(cubit.state.selectedCurrency, 'THB');
      await cubit.close();
    });

    test('setCurrency USD keeps state as USD', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('USD');
      expect(cubit.state.selectedCurrency, 'USD');
      await cubit.close();
    });

    test('setCurrency with invalid value does not change currency', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('EUR');
      expect(cubit.state.selectedCurrency, 'USD');
      await cubit.close();
    });

    test('setCurrency with empty string does not change currency', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('');
      expect(cubit.state.selectedCurrency, 'USD');
      await cubit.close();
    });

    test('setCurrency persists to SharedPreferences', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('THB');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_currency'), 'THB');
      await cubit.close();
    });
  });

  group('CurrencyCubit — toggleCurrency', () {
    test('toggleCurrency switches USD to THB', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.selectedCurrency, 'USD');
      cubit.toggleCurrency();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.selectedCurrency, 'THB');
      await cubit.close();
    });

    test('toggleCurrency switches THB to USD', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.setCurrency('THB');
      cubit.toggleCurrency();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.selectedCurrency, 'USD');
      await cubit.close();
    });

    test('double toggle returns to original currency', () async {
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      cubit.toggleCurrency();
      await Future.delayed(const Duration(milliseconds: 50));
      cubit.toggleCurrency();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.selectedCurrency, 'USD');
      await cubit.close();
    });
  });

  group('CurrencyCubit — convert', () {
    late CurrencyCubit cubit;

    setUp(() async {
      cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() => cubit.close());

    test('convert same currency (USD→USD) returns unchanged amount', () {
      expect(cubit.convert(100.0, fromCurrency: 'USD'), 100.0);
    });

    test('convert USD to THB multiplies by rate', () {
      final rate = cubit.state.usdToThbRate;
      expect(cubit.convert(100.0, fromCurrency: 'USD'), closeTo(100.0 * rate, 0.001));
    });

    test('convert 0 USD to THB is 0', () {
      expect(cubit.convert(0.0, fromCurrency: 'USD'), 0.0);
    });

    test('convert with default fromCurrency is USD', () {
      final resultExplicit = cubit.convert(50.0, fromCurrency: 'USD');
      final resultDefault = cubit.convert(50.0);
      expect(resultDefault, resultExplicit);
    });

    test('convert THB to USD when selected is THB: same currency unchanged', () async {
      await cubit.setCurrency('THB');
      expect(cubit.convert(3500.0, fromCurrency: 'THB'), 3500.0);
    });

    test('convert THB to USD when selected is USD: divides by rate', () {
      final rate = cubit.state.usdToThbRate;
      expect(cubit.convert(3500.0, fromCurrency: 'THB'), closeTo(3500.0 / rate, 0.001));
    });

    test('roundtrip USD→THB→USD returns approximately original amount', () async {
      final rate = cubit.state.usdToThbRate;
      final inThb = cubit.convert(100.0, fromCurrency: 'USD'); // USD selected → multiply by rate
      await cubit.setCurrency('THB');
      final backToUsd = cubit.convert(inThb, fromCurrency: 'THB'); // THB selected → divide by rate
      expect(backToUsd, closeTo(100.0, 0.001));
    });
  });

  // ── CurrencyCubit — _fetchLiveRate / init behaviour ───────────────────────
  // _fetchLiveRate is called from _init() inside the constructor.
  // In a test environment the HTTP request fails (no network / empty env),
  // so the catch block runs and emits isLoadingRate: false.

  group('CurrencyCubit — fetchLiveRate / init (URS-04-01)', () {
    test('isLoadingRate is false by default on initial state', () {
      final cubit = CurrencyCubit();
      expect(cubit.state.isLoadingRate, isFalse);
      cubit.close();
    });

    test('isLoadingRate eventually returns to false after init (network fails in test)', () async {
      final cubit = CurrencyCubit();
      // Wait long enough for _init + _fetchLiveRate to complete (or fail)
      await Future.delayed(const Duration(milliseconds: 500));
      expect(cubit.state.isLoadingRate, isFalse);
      await cubit.close();
    });

    test('cached rate from SharedPreferences is loaded on init', () async {
      SharedPreferences.setMockInitialValues({
        'cached_usd_to_thb_rate': 36.5,
        'selected_currency': 'USD',
      });
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 100));
      // After _init runs, it emits the cached rate
      expect(cubit.state.usdToThbRate, closeTo(36.5, 0.001));
      await cubit.close();
    });

    test('cached currency from SharedPreferences is loaded on init', () async {
      SharedPreferences.setMockInitialValues({'selected_currency': 'THB'});
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.selectedCurrency, 'THB');
      await cubit.close();
    });

    test('when network fetch fails, rate stays at cached or default 35.0', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 500));
      // Network fails in test → rate stays at default 35.0
      expect(cubit.state.usdToThbRate, closeTo(35.0, 0.001));
      await cubit.close();
    });

    test('when fetch fails, currency selection is unchanged', () async {
      SharedPreferences.setMockInitialValues({'selected_currency': 'THB'});
      final cubit = CurrencyCubit();
      await Future.delayed(const Duration(milliseconds: 500));
      expect(cubit.state.selectedCurrency, 'THB');
      await cubit.close();
    });
  });
}
