// Shared transaction row used by Home (Recent) and Activity.
// Design (Feedback #3): category icon in a tinted circle, title = note (or
// localized category), subtitle = "category · date", amount green "+" for
// income and red "−" for expense (colour + sign, not colour alone).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fincontrol/core/constants/app_categories.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';

class TransactionColors {
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);
}

IconData transactionCategoryIcon(String label) {
  const map = <String, IconData>{
    // Income
    'Salary': Icons.payments_outlined,
    'Bonus': Icons.card_giftcard_outlined,
    'Savings Interest': Icons.savings_outlined,
    'Fixed Deposit': Icons.account_balance_outlined,
    'Stock Dividend': Icons.show_chart,
    'Fund Dividend': Icons.pie_chart_outline,
    'Other Dividend': Icons.trending_up,
    'Rental Income': Icons.home_work_outlined,
    'Other Income': Icons.attach_money,
    // Expense
    'Investment Saving': Icons.savings_outlined,
    'Fund Saving': Icons.savings_outlined,
    'Social Security': Icons.health_and_safety_outlined,
    'Provident Fund': Icons.account_balance_wallet_outlined,
    'Life Insurance': Icons.favorite_border,
    'Car Insurance': Icons.car_crash_outlined,
    'Home Insurance': Icons.house_outlined,
    'Common Area Fee': Icons.apartment_outlined,
    'Other Fixed': Icons.receipt_long_outlined,
    'Home Loan': Icons.home_outlined,
    'Investment Property': Icons.domain_outlined,
    'Car Loan': Icons.directions_car_outlined,
    'Credit Card': Icons.credit_card,
    'Personal Loan': Icons.request_quote_outlined,
    'Clothing': Icons.checkroom_outlined,
    'Travel & Leisure': Icons.flight_takeoff,
    'Car Maintenance': Icons.build_outlined,
    'Grocery': Icons.shopping_cart_outlined,
    'Food & Dining': Icons.restaurant,
    'Transport & Fuel': Icons.local_gas_station_outlined,
    'Child Care': Icons.child_care_outlined,
    'Parent Care': Icons.elderly_outlined,
    'Income Tax': Icons.receipt_outlined,
    'Other Expense': Icons.more_horiz,
  };
  final exact = map[label];
  if (exact != null) return exact;
  // Fallbacks for older/free-text categories
  final c = label.toLowerCase();
  if (c.contains('food') || c.contains('dining')) return Icons.restaurant;
  if (c.contains('transport')) return Icons.directions_car_outlined;
  if (c.contains('shop')) return Icons.shopping_bag_outlined;
  if (c.contains('entertain')) return Icons.movie_creation_outlined;
  if (c.contains('salary') || c.contains('income') || c.contains('work')) return Icons.payments_outlined;
  return Icons.category_outlined;
}

/// "25 ก.ย." / "Sep 25"; adds the year when it isn't the current year.
String formatTransactionDate(DateTime date, String languageCode) {
  final loc = languageCode == 'th' ? 'th' : 'en';
  final sameYear = date.year == DateTime.now().year;
  final pattern = loc == 'th'
      ? (sameYear ? 'd MMM' : 'd MMM y')
      : (sameYear ? 'MMM d' : 'MMM d, y');
  try {
    return DateFormat(pattern, loc).format(date);
  } catch (_) {
    return DateFormat(pattern).format(date);
  }
}

/// "+฿500.00" (income) or "−฿120.00" (expense).
String formatSignedAmount(TransactionModel t, CurrencyState currencyState) {
  final isIncome = t.type.toLowerCase() == 'income';
  final value = CurrencyFormatter.format(t.amount.abs(), currencyState);
  return '${isIncome ? '+' : '−'}$value';
}

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final CurrencyState currencyState;
  final Color? textColor;
  final Color? mutedTextColor;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.currencyState,
    this.textColor,
    this.mutedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final lang = Localizations.localeOf(context).languageCode;
    final isIncome = t.type.toLowerCase() == 'income';
    final color = isIncome ? TransactionColors.income : TransactionColors.expense;
    final categoryLabel = AppCategories.localizedLabel(t.category, lang);
    final title = t.note.trim().isNotEmpty ? t.note.trim() : categoryLabel;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(transactionCategoryIcon(t.category), color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 3),
              Text(
                '$categoryLabel · ${formatTransactionDate(t.date, lang)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: mutedTextColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatSignedAmount(t, currencyState),
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
