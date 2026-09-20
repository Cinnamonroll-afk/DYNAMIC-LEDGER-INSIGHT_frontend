import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyState {
  final String selectedCurrency; // 'USD' or 'THB'
  final double usdToThbRate;
  final bool isLoadingRate;

  CurrencyState({
    required this.selectedCurrency,
    required this.usdToThbRate,
    this.isLoadingRate = false,
  });

  CurrencyState copyWith({
    String? selectedCurrency,
    double? usdToThbRate,
    bool? isLoadingRate,
  }) {
    return CurrencyState(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      usdToThbRate: usdToThbRate ?? this.usdToThbRate,
      isLoadingRate: isLoadingRate ?? this.isLoadingRate,
    );
  }

  String get symbol => selectedCurrency == 'USD' ? '\$' : '฿';
}

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit()
      : super(CurrencyState(
          selectedCurrency: 'USD',
          usdToThbRate: 35.0, // Default fallback
        )) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('selected_currency') ?? 'USD';
    final savedRate = prefs.getDouble('cached_usd_to_thb_rate');

    emit(state.copyWith(
      selectedCurrency: savedCurrency,
      usdToThbRate: savedRate, // Will use 35.0 if null because copyWith handles it? No, if savedRate is null we should keep current.
    ));
    
    if (savedRate != null) {
      emit(state.copyWith(usdToThbRate: savedRate));
    }

    _fetchLiveRate();
  }

  Future<void> _fetchLiveRate() async {
    emit(state.copyWith(isLoadingRate: true));
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final thbRate = (rates['THB'] as num).toDouble();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('cached_usd_to_thb_rate', thbRate);

        emit(state.copyWith(usdToThbRate: thbRate, isLoadingRate: false));
      } else {
        emit(state.copyWith(isLoadingRate: false));
      }
    } catch (e) {
      // Fall back to cached or default
      emit(state.copyWith(isLoadingRate: false));
    }
  }

  Future<void> setCurrency(String currency) async {
    if (currency != 'USD' && currency != 'THB') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currency);
    emit(state.copyWith(selectedCurrency: currency));
  }

  void toggleCurrency() {
    setCurrency(state.selectedCurrency == 'USD' ? 'THB' : 'USD');
  }

  // Helper to convert an amount from its native currency to the display currency
  double convert(double amount, {String fromCurrency = 'USD'}) {
    // If the base currency is the same as the target display currency, return as is.
    if (fromCurrency == state.selectedCurrency) {
      return amount;
    }

    // Convert from USD to THB
    if (fromCurrency == 'USD' && state.selectedCurrency == 'THB') {
      return amount * state.usdToThbRate;
    }

    // Convert from THB to USD
    if (fromCurrency == 'THB' && state.selectedCurrency == 'USD') {
      return amount / state.usdToThbRate;
    }

    return amount;
  }
}
