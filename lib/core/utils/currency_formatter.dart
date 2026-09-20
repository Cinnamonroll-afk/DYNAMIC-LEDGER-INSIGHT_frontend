import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';

class CurrencyFormatter {
  static double convert(double amount, CurrencyState state, {String fromCurrency = 'USD'}) {
    if (fromCurrency == state.selectedCurrency) return amount;
    if (fromCurrency == 'USD' && state.selectedCurrency == 'THB') return amount * state.usdToThbRate;
    if (fromCurrency == 'THB' && state.selectedCurrency == 'USD') return amount / state.usdToThbRate;
    return amount;
  }

  static String format(
    double amount,
    CurrencyState state, {
    String fromCurrency = 'USD',
    int decimals = 2,
    bool showSignForPositive = false,
  }) {
    // 1. Convert amount based on base currency and selected currency
    double convertedAmount = convert(amount, state, fromCurrency: fromCurrency);

    // 2. Format the sign (useful for portfolio/returns where we show + or -)
    final bool isNegative = convertedAmount < 0;
    final double absValue = convertedAmount.abs();
    
    String sign = '';
    if (isNegative) {
      sign = '-';
    } else if (showSignForPositive && absValue > 0) {
      sign = '+';
    }

    // 3. Construct the final string: e.g. "+$123.45" or "-฿1,200"
    // Using string formatting without intl package for simplicity and to avoid new dependencies,
    // though intl NumberFormat is usually better for commas.
    // For now, we will handle commas with a simple RegExp.
    
    String formattedValue = absValue.toStringAsFixed(decimals);
    
    // Add commas for thousands
    final parts = formattedValue.split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    // ignore: prefer_interpolation_to_compose_strings
    String numberWithCommas = parts[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    if (parts.length > 1 && decimals > 0) {
      numberWithCommas += '.${parts[1]}';
    }

    return '$sign${state.symbol}$numberWithCommas';
  }
}
