import 'dart:ui';
import 'package:fincontrol/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_state.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fincontrol/core/services/gemini_service.dart';
import 'package:fincontrol/features/auth/data/repositories/auth_repository.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/transaction_row.dart';
import 'package:fincontrol/core/constants/app_categories.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/home/logic/insight_summary.dart';
import 'package:fincontrol/features/home/data/insight_cache.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onSeeAllActivity;
  final VoidCallback? onGoToWealth;
  
  const HomePage({super.key, this.onSeeAllActivity, this.onGoToWealth});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Using a solid, opaque slate-grey color inspired by the example screenshot.
    // This creates strong contrast against the background without using any transparency.
    final cardColor = isDarkMode 
        ? const Color(0xFF272732) // Solid dark slate/purple-grey (like the 'Smart TV' card)
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent, // Ensures the global animated background gradient shows through
      body: SafeArea(
        child: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            return ListView(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 120),
              children: [
                _buildHeader(context, textColor, primaryColor, cardColor),
                const SizedBox(height: 22),
                _buildBalanceCard(context, textColor, mutedTextColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 14),
                _buildPrimaryActions(context),
                const SizedBox(height: 22),
                _buildAiInsightCard(context, textColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 22),
                _buildSpendingBreakdown(context, textColor, mutedTextColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 16),
                _buildWealthSnapshot(context, textColor, mutedTextColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 22),
                _buildRecentTransactions(context, textColor, mutedTextColor, primaryColor, cardColor, currencyState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color? textColor, Color primaryColor, Color cardColor) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    String greeting = l10n.goodMorning;
    if (hour >= 12 && hour < 17) {
      greeting = l10n.goodAfternoon;
    } else if (hour >= 17) {
      greeting = l10n.goodEvening;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: AuthRepository().getUser(),
            builder: (context, snapshot) {
              String finalName = 'User';
              String? photoUrl;
              
              if (snapshot.hasData && snapshot.data != null) {
                finalName = snapshot.data!['name'] ?? 'User';
                photoUrl = snapshot.data!['photo_url'];
                if (photoUrl != null && !photoUrl.startsWith('http')) {
                  photoUrl = '${AuthRepository().baseUrl}$photoUrl';
                }
              }
              
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    radius: 24,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? Icon(Icons.person, color: primaryColor) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.6))),
                        Text(finalName, style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
        ),
        Row(
          children: [
            _buildIconButton(context, Icons.notifications_none, textColor, cardColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, Color? iconColor, Color bgColor, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDarkMode 
        ? const Color(0x99192134) 
        : const Color(0xCCFFFFFF);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: glassColor,
            ),
            child: IconButton(
              icon: Icon(icon, color: iconColor),
              onPressed: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, Color cardColor, CurrencyState currencyState) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        double currentMonthIncome = 0;
        double currentMonthExpense = 0;
        double totalBalance = 0; 
        List<FlSpot> sparklineSpots = const [
          FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 6), FlSpot(4, 5), FlSpot(5, 8), FlSpot(6, 7),
        ];
        double minSpotY = 0;
        double maxSpotY = 10;

        if (state is TransactionLoaded) {
          final now = DateTime.now();
          for (var t in state.transactions) {
            final typeStr = t.type.toLowerCase();
            final amt = t.amount.abs();
            if (typeStr == 'income') totalBalance += amt;
            if (typeStr == 'expense') totalBalance -= amt;

            if (t.date.year == now.year && t.date.month == now.month) {
              if (typeStr == 'income') currentMonthIncome += amt;
              if (typeStr == 'expense') currentMonthExpense += amt;
            }
          }
          
          Map<int, double> dailyNet = {}; 
          for (var t in state.transactions) {
            final diff = now.difference(t.date).inDays;
            if (diff >= 0 && diff < 7) {
              final amt = t.amount.abs();
              dailyNet[diff] = (dailyNet[diff] ?? 0) + (t.type.toLowerCase() == 'income' ? amt : -amt);
            }
          }
          
          List<FlSpot> dynamicSpots = [];
          double runningBalance = totalBalance;
          double currentMin = totalBalance;
          double currentMax = totalBalance;
          
          dynamicSpots.add(FlSpot(6, runningBalance));
          
          for (int i = 0; i < 6; i++) {
            runningBalance -= (dailyNet[i] ?? 0);
            if (runningBalance < currentMin) currentMin = runningBalance;
            if (runningBalance > currentMax) currentMax = runningBalance;
            dynamicSpots.add(FlSpot((5 - i).toDouble(), runningBalance));
          }
          sparklineSpots = dynamicSpots.reversed.toList();
          
          if (currentMin == currentMax) {
            minSpotY = currentMin - 10;
            maxSpotY = currentMax + 10;
          } else {
            final padding = (currentMax - currentMin) * 0.1;
            minSpotY = currentMin - padding;
            maxSpotY = currentMax + padding;
          }
        }

        final l10n = AppLocalizations.of(context)!;
        final lang = Localizations.localeOf(context).languageCode;
        String monthName;
        try {
          monthName = DateFormat('MMMM', lang == 'th' ? 'th' : 'en').format(DateTime.now());
        } catch (_) {
          monthName = DateFormat('MMMM').format(DateTime.now());
        }
        final hasIncome = currentMonthIncome > 0;
        final spendPct = hasIncome ? currentMonthExpense / currentMonthIncome * 100 : 0.0;
        final spendRatio = hasIncome ? (currentMonthExpense / currentMonthIncome).clamp(0.0, 1.0) : 0.0;
        final ratioColor = spendPct >= 100
            ? TransactionColors.expense
            : spendPct >= 80
                ? const Color(0xFFF59E0B)
                : TransactionColors.income;
        final net = currentMonthIncome - currentMonthExpense;
        final netColor = net >= 0 ? TransactionColors.income : TransactionColors.expense;
        String money(double v) => CurrencyFormatter.format(v, currencyState);

        Widget flow(IconData icon, Color color, String label, String value) => Expanded(
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: TextStyle(fontSize: 12, color: mutedTextColor, fontWeight: FontWeight.w600)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total balance + 7-day trend
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.totalBalance, style: TextStyle(fontSize: 14, color: mutedTextColor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(money(totalBalance),
                              style: TextStyle(fontSize: 34, color: textColor, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 38,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: const LineTouchData(enabled: false),
                            minX: 0,
                            maxX: 6,
                            minY: minSpotY,
                            maxY: maxSpotY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: sparklineSpots,
                                isCurved: true,
                                color: primaryColor,
                                barWidth: 2.5,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: true, color: primaryColor.withValues(alpha: 0.12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(l10n.last7Days, style: TextStyle(fontSize: 11, color: mutedTextColor)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.1)),
              const SizedBox(height: 14),
              // This month
              Text(l10n.thisMonthLabel(monthName), style: TextStyle(fontSize: 13, color: mutedTextColor, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  flow(Icons.arrow_upward_rounded, TransactionColors.income, l10n.income, '+${money(currentMonthIncome)}'),
                  const SizedBox(width: 12),
                  flow(Icons.arrow_downward_rounded, TransactionColors.expense, l10n.expenses, '−${money(currentMonthExpense)}'),
                ],
              ),
              if (hasIncome) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.spentOfIncome(spendPct.toStringAsFixed(0)),
                          style: TextStyle(fontSize: 12.5, color: mutedTextColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: spendRatio,
                    minHeight: 8,
                    backgroundColor: (textColor ?? Colors.grey).withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(ratioColor),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(l10n.netThisMonth, style: TextStyle(fontSize: 13, color: mutedTextColor)),
                  const Spacer(),
                  Text('${net >= 0 ? '+' : '−'}${money(net.abs())}',
                      style: TextStyle(fontSize: 15, color: netColor, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiInsightCard(BuildContext context, Color? textColor, Color primaryColor, Color cardColor, CurrencyState currencyState) {
    return AiInsightCard(textColor: textColor, primaryColor: primaryColor, currencyState: currencyState);
  }

  /// "+ Income" / "− Expense" — the most frequent actions in an expense tracker.
  Widget _buildPrimaryActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void open(TransactionType type) => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddTransactionSheet(initialType: type),
        );
    Widget btn(IconData icon, String label, Color color, TransactionType type) => Expanded(
          child: ElevatedButton.icon(
            onPressed: () => open(type),
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
          ),
        );
    return Row(
      children: [
        btn(Icons.add_rounded, l10n.income, const Color(0xFF059669), TransactionType.income),
        const SizedBox(width: 12),
        btn(Icons.remove_rounded, l10n.expenses, const Color(0xFFDC2626), TransactionType.expense),
      ],
    );
  }

  /// Top 3 expense categories this month (+ "Others").
  Widget _buildSpendingBreakdown(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, Color cardColor, CurrencyState currencyState) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final now = DateTime.now();
        final byCat = <String, double>{};
        double total = 0;
        if (state is TransactionLoaded) {
          for (final t in state.transactions) {
            if (t.type.toLowerCase() != 'expense') continue;
            if (t.date.year != now.year || t.date.month != now.month) continue;
            final amt = t.amount.abs();
            byCat[t.category] = (byCat[t.category] ?? 0) + amt;
            total += amt;
          }
        }
        final sorted = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(3).toList();
        final others = sorted.skip(3).fold<double>(0, (s, e) => s + e.value);

        Widget row(IconData icon, String name, double amount) {
          final pct = total > 0 ? amount / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: TransactionColors.expense.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: TransactionColors.expense, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          Text(CurrencyFormatter.format(amount, currencyState),
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: (textColor ?? Colors.grey).withValues(alpha: 0.08),
                                valueColor: const AlwaysStoppedAnimation(TransactionColors.expense),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 38,
                            child: Text('${(pct * 100).toStringAsFixed(0)}%',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: mutedTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onSeeAllActivity,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.spendingThisMonth,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    ),
                    Text(l10n.seeAll, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                if (top.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.noSpendingThisMonth, style: TextStyle(color: mutedTextColor, fontSize: 14)),
                  )
                else ...[
                  for (final e in top)
                    row(transactionCategoryIcon(e.key), AppCategories.localizedLabel(e.key, lang), e.value),
                  if (others > 0) row(Icons.more_horiz, l10n.othersLabel, others),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Small investment snapshot linking Home ↔ Wealth.
  Widget _buildWealthSnapshot(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, Color cardColor, CurrencyState currencyState) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        final assets = state is AssetLoaded ? state.assets : <AssetModel>[];
        double value = 0, cost = 0;
        for (final a in assets) {
          value += AssetMath.marketValue(a, currencyState);
          cost += AssetMath.costBasis(a, currencyState);
        }
        final pct = cost > 0 ? (value - cost) / cost * 100 : null;
        final up = (pct ?? 0) >= 0;
        final empty = assets.isEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onGoToWealth,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Icon(Icons.trending_up_rounded, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(empty ? l10n.startInvesting : l10n.investmentPortfolio,
                          style: TextStyle(color: empty ? primaryColor : mutedTextColor, fontSize: empty ? 15 : 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      if (empty)
                        Text(l10n.startInvestingHint, style: TextStyle(color: mutedTextColor, fontSize: 12.5))
                      else
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                CurrencyFormatter.format(value, currencyState, fromCurrency: currencyState.selectedCurrency),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (pct != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${up ? '▲ +' : '▼ −'}${pct.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: up ? TransactionColors.income : TransactionColors.expense,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: mutedTextColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, Color cardColor, CurrencyState currencyState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.recent, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              TextButton(
                onPressed: onSeeAllActivity,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(AppLocalizations.of(context)!.seeAll, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) return const Center(child: CircularProgressIndicator());
              if (state is TransactionLoaded) {
                var sorted = List.of(state.transactions)..sort((a, b) => b.date.compareTo(a.date));
                var recent = sorted.take(4).toList();
                
                if (recent.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, color: mutedTextColor?.withValues(alpha: 0.3), size: 48),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noTransactionsYet, style: TextStyle(color: mutedTextColor, fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: recent.map((t) {
                    return Builder(
                      builder: (freshContext) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showTransactionOptions(freshContext, t),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: TransactionRow(
                          transaction: t,
                          currencyState: currencyState,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                        ),
                      ),
                    ),
                    );
                  }).toList(),
                );
              }
              if (state is TransactionError) return Center(child: Text(AppLocalizations.of(context)!.errorMsg(state.message), style: const TextStyle(color: Colors.red)));
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, TransactionModel t) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isIncome = t.type.toLowerCase() == 'income';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Text(t.note.isNotEmpty ? t.note : t.category,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            Text(t.category, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5))),
            const SizedBox(height: 24),
            _optionTile(
              color: primaryColor,
              icon: Icons.edit_outlined,
              title: AppLocalizations.of(context)!.editAction,
              subtitle: AppLocalizations.of(context)!.editTransactionSubtitle,
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTransactionSheet(existingTransaction: t),
                );
              },
            ),
            const SizedBox(height: 10),
            _optionTile(
              color: Colors.redAccent,
              icon: Icons.delete_outline,
              title: AppLocalizations.of(context)!.deleteAction,
              subtitle: AppLocalizations.of(context)!.deleteTransactionSubtitle,
              onTap: () {
                context.read<TransactionBloc>().add(DeleteTransaction(t.id));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({required Color color, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12, height: 1.4)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
//  - Day / Week / Month selector (default Week, remembered per account)
//  - Income / expense for the period + expense change vs previous period
//  - AI advice (TH + EN generated together), cached per account & period and
//    regenerated only when the period's data changes or the user taps refresh.
// See FEEDBACK_NOTES.md (Feedback #1).
// ─────────────────────────────────────────────────────────────────────────────
class AiInsightCard extends StatefulWidget {
  final Color? textColor;
  final Color primaryColor;
  final CurrencyState currencyState;

  const AiInsightCard({super.key, this.textColor, required this.primaryColor, required this.currencyState});

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  String? _userId;
  bool _ready = false; // user id + saved period + cache loaded
  InsightPeriod _period = InsightPeriod.week;

  /// Cached insight per period (loaded lazily from local storage).
  final Map<InsightPeriod, CachedInsight?> _cache = {};
  final Set<InsightPeriod> _cacheLoaded = {};

  /// Requests in flight, keyed by "period|fingerprint".
  final Set<String> _inflight = {};

  /// Fingerprint whose request failed (per period) — no auto-retry loop.
  final Map<InsightPeriod, String> _failedFp = {};

  List<TransactionModel> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_id');
    final userId = (uid == null || uid.isEmpty) ? 'anon' : uid;
    final period = await InsightCache.readSelectedPeriod(userId);
    await _loadCache(userId, period);
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _period = period;
      _ready = true;
    });
  }

  Future<void> _loadCache(String userId, InsightPeriod period) async {
    if (_cacheLoaded.contains(period)) return;
    _cache[period] = await InsightCache.read(userId, period);
    _cacheLoaded.add(period);
  }

  InsightSummary _summaryFor(InsightPeriod period) => InsightSummary.compute(
        transactions: _transactions,
        period: period,
        now: DateTime.now(),
        currencyTag: widget.currencyState.selectedCurrency,
      );

  Future<void> _selectPeriod(InsightPeriod period) async {
    if (period == _period || _userId == null) return;
    setState(() => _period = period);
    InsightCache.saveSelectedPeriod(_userId!, period);
    await _loadCache(_userId!, period);
    if (mounted) setState(() {});
  }

  /// Makes sure the current period has an up-to-date insight.
  /// Calls the AI only when needed (or when [force] is true).
  Future<void> _ensureInsight(InsightSummary summary, {bool force = false}) async {
    final userId = _userId;
    final period = summary.period;
    if (!_ready || userId == null || !_cacheLoaded.contains(period)) return;
    if (summary.isEmpty) return; // nothing to analyse → empty state, no AI call

    final fp = summary.fingerprint;
    final key = '${period.key}|$fp';
    if (_inflight.contains(key)) return;
    if (!force) {
      if (_cache[period]?.fingerprint == fp) return; // cached & still valid
      if (_failedFp[period] == fp) return; // failed → wait for "Try again"
    }

    setState(() {
      _inflight.add(key);
      _failedFp.remove(period);
    });

    final facts = summary.toPromptFacts(
      (v) => CurrencyFormatter.format(v, widget.currencyState),
    );
    final result = await GeminiService.generateBilingualInsight(facts);
    if (!mounted) return;

    if (result != null) {
      final insight = CachedInsight(
        fingerprint: fp,
        th: result.th,
        en: result.en,
        generatedAt: DateTime.now(),
      );
      await InsightCache.write(userId, period, insight);
      if (!mounted) return;
      setState(() {
        _inflight.remove(key);
        _cache[period] = insight;
      });
    } else {
      setState(() {
        _inflight.remove(key);
        _failedFp[period] = fp;
      });
    }
  }

  // ── Formatting helpers ────────────────────────────────────────────────────
  String _rangeLabel(InsightSummary s, String lang) {
    final loc = lang == 'th' ? 'th' : 'en';
    String f(String pattern, DateTime d) {
      try {
        return DateFormat(pattern, loc).format(d);
      } catch (_) {
        return DateFormat(pattern).format(d);
      }
    }

    final start = s.range.start;
    final last = s.range.lastDay;
    switch (s.period) {
      case InsightPeriod.day:
        return f('d MMM y', start);
      case InsightPeriod.week:
        if (start.month == last.month) {
          return '${start.day}–${f('d MMM', last)}';
        }
        return '${f('d MMM', start)} – ${f('d MMM', last)}';
      case InsightPeriod.month:
        return f('MMMM y', start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final textColor = widget.textColor;
    final mutedColor = textColor?.withValues(alpha: 0.6);
    final primary = widget.primaryColor;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        // Keep the last loaded list while the bloc reloads (avoids flicker).
        if (state is TransactionLoaded) _transactions = state.transactions;

        final summary = _summaryFor(_period);
        final key = '${_period.key}|${summary.fingerprint}';
        final isLoading = _inflight.contains(key);
        final cached = _cache[_period];
        final String? insightText = (cached != null && cached.fingerprint == summary.fingerprint)
            ? cached.forLanguage(lang)
            : null;
        final failed = _failedFp[_period] == summary.fingerprint;

        if (_ready && state is TransactionLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _ensureInsight(summary);
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon, title, date range, refresh
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.insight, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 2),
                        Text(_rangeLabel(summary, lang), style: TextStyle(fontSize: 12, color: mutedColor)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.insightRefresh,
                    icon: Icon(Icons.refresh_rounded, color: primary, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: (!_ready || summary.isEmpty || isLoading)
                        ? null
                        : () => _ensureInsight(summary, force: true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Period selector
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<InsightPeriod>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: InsightPeriod.day, label: Text(l10n.insightPeriodDay)),
                      ButtonSegment(value: InsightPeriod.week, label: Text(l10n.insightPeriodWeek)),
                      ButtonSegment(value: InsightPeriod.month, label: Text(l10n.insightPeriodMonth)),
                    ],
                    selected: {_period},
                    onSelectionChanged: _ready ? (s) => _selectPeriod(s.first) : null,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.2) : Colors.transparent,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected) ? primary : textColor,
                      ),
                      side: WidgetStateProperty.all(BorderSide(color: primary.withValues(alpha: 0.3))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildBody(
                  context: context,
                  l10n: l10n,
                  lang: lang,
                  summary: summary,
                  loadingTransactions: (state is TransactionInitial || state is TransactionLoading) && _transactions.isEmpty,
                  isLoading: isLoading,
                  insightText: insightText,
                  failed: failed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required String lang,
    required InsightSummary summary,
    required bool loadingTransactions,
    required bool isLoading,
    required String? insightText,
    required bool failed,
  }) {
    final textColor = widget.textColor;
    final primary = widget.primaryColor;

    if (!_ready || loadingTransactions) return _skeleton();

    if (summary.isEmpty) {
      final msg = switch (summary.period) {
        InsightPeriod.day => l10n.insightEmptyDay,
        InsightPeriod.week => l10n.insightEmptyWeek,
        InsightPeriod.month => l10n.insightEmptyMonth,
      };
      return Text(msg, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.8), height: 1.4));
    }

    Widget advice;
    if (isLoading) {
      advice = _skeleton();
    } else if (insightText != null) {
      advice = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insightText, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.85), height: 1.45)),
          const SizedBox(height: 8),
          // AI disclaimer (Feedback #2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 13, color: textColor?.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.aiInsightDisclaimer,
                    style: TextStyle(fontSize: 11, color: textColor?.withValues(alpha: 0.5), height: 1.3)),
              ),
            ],
          ),
        ],
      );
    } else if (failed) {
      advice = Row(
        children: [
          Expanded(
            child: Text(l10n.insightError, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.8))),
          ),
          TextButton(
            onPressed: () => _ensureInsight(summary, force: true),
            child: Text(l10n.insightRetry, style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    } else {
      advice = _skeleton(); // about to request
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStats(l10n, summary),
        const SizedBox(height: 12),
        advice,
      ],
    );
  }

  Widget _buildStats(AppLocalizations l10n, InsightSummary s) {
    final textColor = widget.textColor;
    final mutedColor = textColor?.withValues(alpha: 0.6);
    String money(double v) => CurrencyFormatter.format(v, widget.currencyState);

    Widget stat(String label, String value, Color valueColor, {Widget? extra}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: mutedColor)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
            ),
            if (extra != null) ...[const SizedBox(height: 2), extra],
          ],
        ),
      );
    }

    Widget? change;
    final pct = s.expenseChangePercent;
    if (pct != null) {
      final rounded = pct.round();
      final vs = switch (s.period) {
        InsightPeriod.day => l10n.insightVsYesterday,
        InsightPeriod.week => l10n.insightVsLastWeek,
        InsightPeriod.month => l10n.insightVsLastMonth,
      };
      // Spending more = red, spending less = green.
      final color = rounded > 0
          ? const Color(0xFFEF4444)
          : rounded < 0
              ? const Color(0xFF10B981)
              : (mutedColor ?? Colors.grey);
      final arrow = rounded > 0 ? '▲' : (rounded < 0 ? '▼' : '•');
      change = Text(
        '$arrow ${rounded.abs()}% $vs',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stat(l10n.insightExpenseLabel, money(s.expense), const Color(0xFFEF4444), extra: change),
        const SizedBox(width: 12),
        stat(l10n.insightIncomeLabel, money(s.income), const Color(0xFF10B981)),
      ],
    );
  }

  Widget _skeleton() {
    final c = widget.primaryColor.withValues(alpha: 0.15);
    Widget bar(double widthFactor) => FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 10,
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [bar(1), const SizedBox(height: 8), bar(0.7)],
    );
  }
}
