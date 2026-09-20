import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_state.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fincontrol/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/core/constants/app_categories.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _selectedPeriod = 'Month';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                List<TransactionModel> allTransactions = [];
            if (state is TransactionLoaded) {
              allTransactions = state.transactions;
            }

            // Filter by Period
            final now = DateTime.now();
            List<TransactionModel> periodTransactions = allTransactions.where((t) {
              if (_selectedPeriod == 'Month') {
                return t.date.year == now.year && t.date.month == now.month;
              } else if (_selectedPeriod == 'Year') {
                return t.date.year == now.year;
              } else if (_selectedPeriod == 'Week') {
                return now.difference(t.date).inDays <= 7;
              } else {
                return t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
              }
            }).toList();

            // Filter by Search & Filter Chip
            List<TransactionModel> filteredTransactions = periodTransactions.where((t) {
              final matchesSearch = t.note.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                    t.category.toLowerCase().contains(_searchQuery.toLowerCase());
              if (!matchesSearch) return false;

              if (_selectedFilter == 'Income') return t.type == 'Income';
              if (_selectedFilter == 'Expense') return t.type == 'Expense';
              return true;
            }).toList();

            filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

            return ListView(
              padding: const EdgeInsets.only(
                top: 16, 
                left: 16,
                right: 16,
                bottom: 120,
              ),
              children: [
                _buildHeader(context, textColor),
                const SizedBox(height: 24),
                _buildPeriodTabs(textColor, mutedTextColor, primaryColor),
                const SizedBox(height: 24),
                _buildCashFlowChart(periodTransactions, textColor, mutedTextColor, primaryColor),
                const SizedBox(height: 24),
                _buildSpendingBreakdown(periodTransactions, textColor, mutedTextColor, currencyState),
                const SizedBox(height: 24),
                _buildCashFlowStatement(periodTransactions, textColor, mutedTextColor, currencyState),
                const SizedBox(height: 32),
                _buildSearchBar(textColor, mutedTextColor, primaryColor, isDarkMode),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.transactions,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTransactionList(filteredTransactions, textColor, mutedTextColor, currencyState),
              ],
            );
          }
        );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color? textColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDarkMode 
        ? const Color(0x99192134) 
        : const Color(0xCCFFFFFF);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.activityDashboard,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: glassColor,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, color: textColor), 
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
                  }
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(20),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: textColor),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: mutedTextColor),
              hintText: AppLocalizations.of(context)!.searchTransactions,
              hintStyle: TextStyle(color: mutedTextColor),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Income', 'Expense'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? primaryColor : Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.2),
                    child: Center(
                      child: Text(
                        _getFilterText(context, filter),
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodTabs(Color? textColor, Color? mutedTextColor, Color primaryColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: ['Day', 'Week', 'Month', 'Year'].map((String value) {
          final isSelected = _selectedPeriod == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getPeriodText(context, value),
                    style: TextStyle(
                      color: isSelected ? Colors.white : mutedTextColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashFlowChart(List<TransactionModel> transactions, Color? textColor, Color? mutedTextColor, Color primaryColor) {
    double income = 0;
    double expense = 0;
    for (var t in transactions) {
      if (t.type.toLowerCase() == 'income') income += t.amount.abs();
      if (t.type.toLowerCase() == 'expense') expense += t.amount.abs();
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.cashFlow,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: ((income > expense ? income : expense) == 0 ? 100.0 : (income > expense ? income : expense)) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value == 0 ? AppLocalizations.of(context)!.income : AppLocalizations.of(context)!.expense,
                            style: TextStyle(color: mutedTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: Colors.greenAccent,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expense,
                        color: Colors.redAccent,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingBreakdown(List<TransactionModel> transactions, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final langCode = Localizations.localeOf(context).languageCode;
    Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type.toLowerCase() == 'expense') {
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount.abs();
        totalExpense += t.amount.abs();
      }
    }

    if (totalExpense == 0) {
      return const SizedBox.shrink(); 
    }

    final colors = [
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.amberAccent,
      Colors.cyanAccent,
      Colors.pinkAccent,
    ];

    int colorIndex = 0;
    List<PieChartSectionData> sections = [];
    List<Widget> legendItems = [];

    categoryTotals.forEach((category, amount) {
      final color = colors[colorIndex % colors.length];
      final percentage = (amount / totalExpense) * 100;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppCategories.localizedLabel(category, langCode), style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
              Text(CurrencyFormatter.format(amount, currencyState, decimals: 0), style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
            ],
          ),
        )
      );

      colorIndex++;
    });

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.spendingBreakdown,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowStatement(List<TransactionModel> transactions, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final l10n = AppLocalizations.of(context)!;
    // Build label → group lookup
    final Map<String, String> labelToGroup = {};
    for (final c in AppCategories.income) {
      labelToGroup[c.label] = c.group;
    }
    for (final c in AppCategories.expense) {
      labelToGroup[c.label] = c.group;
    }

    // Accumulate totals per group
    final Map<String, double> groupTotals = {};
    final Map<String, List<TransactionModel>> groupTx = {};
    for (final t in transactions) {
      final group = labelToGroup[t.category];
      if (group != null) {
        groupTotals[group] = (groupTotals[group] ?? 0) + t.amount.abs();
        groupTx.putIfAbsent(group, () => []).add(t);
      }
    }

    final double activeIncome   = groupTotals['Active Income']  ?? 0;
    final double passiveIncome  = groupTotals['Passive Income'] ?? 0;
    final double totalInflow    = activeIncome + passiveIncome;

    final double saving         = groupTotals['Saving']      ?? 0;
    final double fixed          = groupTotals['Fixed']       ?? 0;
    final double installment    = groupTotals['Installment'] ?? 0;
    final double variable       = groupTotals['Variable']    ?? 0;
    final double totalOutflow   = saving + fixed + installment + variable;

    final double netCashFlow    = totalInflow - totalOutflow;
    final bool   isPositive     = netCashFlow >= 0;

    String fmt(double v) => CurrencyFormatter.format(v, currencyState, decimals: 0);

    Widget statRow(String label, double amount, {bool isBold = false, Color? color}) {
      final c = color ?? textColor;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isBold ? 14 : 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: c,
                ),
              ),
            ),
            Text(
              fmt(amount),
              style: TextStyle(
                fontSize: isBold ? 14 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      );
    }

    Widget expandableRow(String label, double total, String groupKey, Color accentColor) {
      final txList = groupTx[groupKey] ?? [];
      if (txList.isEmpty) return statRow(label, total);
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 8, bottom: 4),
          iconColor: accentColor,
          collapsedIconColor: (textColor ?? Colors.grey).withValues(alpha: 0.4),
          title: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor))),
              Text(fmt(total), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            ],
          ),
          children: txList.map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(_getCategoryIcon(t.category), size: 14, color: accentColor.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.note.isNotEmpty ? t.note : t.category,
                    style: TextStyle(fontSize: 12, color: mutedTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(fmt(t.amount.abs()), style: TextStyle(fontSize: 12, color: mutedTextColor)),
              ],
            ),
          )).toList(),
        ),
      );
    }

    Widget sectionHeader(String title, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8),
            ),
          ],
        ),
      );
    }

    Widget divider() => Divider(color: (textColor ?? Colors.grey).withValues(alpha: 0.15), height: 16);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.cashFlowStatement,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Cash Inflows ──────────────────────────────────────
          sectionHeader(l10n.cashInflows, Colors.green),
          expandableRow(l10n.cfActiveIncome,  activeIncome,  'Active Income',  Colors.green),
          expandableRow(l10n.cfPassiveIncome, passiveIncome, 'Passive Income', Colors.green),
          divider(),
          statRow(l10n.totalInflows, totalInflow, isBold: true, color: Colors.green),
          const SizedBox(height: 16),

          // ── Cash Outflows ─────────────────────────────────────
          sectionHeader(l10n.cashOutflows, Colors.redAccent),
          expandableRow(l10n.cfSaving,      saving,      'Saving',      Colors.redAccent),
          expandableRow(l10n.cfFixed,       fixed,        'Fixed',       Colors.redAccent),
          expandableRow(l10n.cfInstallment,  installment,  'Installment', Colors.redAccent),
          expandableRow(l10n.cfVariable,    variable,     'Variable',    Colors.redAccent),
          divider(),
          statRow(l10n.totalOutflows, totalOutflow, isBold: true, color: Colors.redAccent),
          const SizedBox(height: 16),

          // ── Net Cash Flow ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.redAccent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isPositive ? Colors.green : Colors.redAccent).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.netCashFlow,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ),
                Text(
                  (isPositive && netCashFlow > 0 ? '+' : '') + fmt(netCashFlow),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isPositive ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final langCode = Localizations.localeOf(context).languageCode;
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(AppLocalizations.of(context)!.noTransactionsMatch, style: TextStyle(color: mutedTextColor, fontWeight: FontWeight.w500)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = transactions[index];
        final isIncome = record.type.toLowerCase() == 'income';
        final amt = record.amount.abs();
        
        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            context.read<TransactionBloc>().add(DeleteTransaction(record.id));
          },
          child: GestureDetector(
            onTap: () => _showTransactionOptions(context, record),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    _getCategoryIcon(record.category),
                    color: isIncome ? Colors.green : textColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.note.isNotEmpty ? record.note : record.category,
                      style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppCategories.localizedLabel(record.category, langCode),
                      style: TextStyle(color: mutedTextColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(amt, currencyState, showSignForPositive: isIncome),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.date.month}/${record.date.day}/${record.date.year}',
                    style: TextStyle(color: mutedTextColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        )));
      },
    );
  }

  void _showTransactionOptions(BuildContext context, TransactionModel record) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isIncome = record.type.toLowerCase() == 'income';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  record.note.isNotEmpty ? record.note : record.category,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            Text(
              record.category,
              style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            // Edit
            _transactionOptionTile(
              color: Theme.of(context).colorScheme.primary,
              icon: Icons.edit_outlined,
              title: 'Edit',
              subtitle: 'Change amount, category, or date',
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTransactionSheet(existingTransaction: record),
                );
              },
            ),
            const SizedBox(height: 10),
            // Delete
            _transactionOptionTile(
              color: Colors.redAccent,
              icon: Icons.delete_outline,
              title: 'Delete',
              subtitle: 'Remove this transaction permanently',
              onTap: () {
                context.read<TransactionBloc>().add(DeleteTransaction(record.id));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionOptionTile({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterText(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case 'All': return l10n.all;
      case 'Income': return l10n.income;
      case 'Expense': return l10n.expense;
      default: return filter;
    }
  }

  String _getPeriodText(BuildContext context, String period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case 'Day': return l10n.day;
      case 'Week': return l10n.week;
      case 'Month': return l10n.month;
      case 'Year': return l10n.year;
      default: return period;
    }
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Food') || category.contains('Dining')) return Icons.restaurant;
    if (category.contains('Transport')) return Icons.directions_car_outlined;
    if (category.contains('Shopping')) return Icons.shopping_bag_outlined;
    if (category.contains('Entertainment')) return Icons.movie_creation_outlined;
    if (category.contains('Work') || category.contains('Salary') || category.contains('Income')) return Icons.payments_outlined;
    
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car_outlined;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Entertainment': return Icons.movie_creation_outlined;
      case 'Work': return Icons.work_outline;
      case 'Salary': return Icons.payments_outlined;
      default: return Icons.category_outlined;
    }
  }
}
