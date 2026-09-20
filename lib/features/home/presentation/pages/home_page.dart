import 'dart:ui';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
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
import 'package:fincontrol/features/settings/bloc/language_cubit.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';

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
                const SizedBox(height: 24),
                _buildBalanceCard(context, textColor, mutedTextColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 24),
                _buildQuickActions(context, textColor, mutedTextColor, primaryColor, cardColor),
                const SizedBox(height: 24),
                _buildAiInsightCard(context, textColor, primaryColor, cardColor, currencyState),
                const SizedBox(height: 32),
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
            _buildIconButton(context, Icons.search, textColor, cardColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InvestPage()));
            }),
            const SizedBox(width: 12),
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

        final double spendRatio = currentMonthIncome > 0 
            ? (currentMonthExpense / currentMonthIncome).clamp(0.0, 1.0) 
            : 0.0;

        return Container(
          width: double.infinity,
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
              Text(AppLocalizations.of(context)!.totalBalance, style: TextStyle(fontSize: 14, color: mutedTextColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CurrencyFormatter.format(totalBalance, currencyState), style: TextStyle(fontSize: 36, color: textColor, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  SizedBox(
                    width: 60,
                    height: 35,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: minSpotY,
                        maxY: maxSpotY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: sparklineSpots,
                            isCurved: true,
                            color: primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_downward, color: Colors.green, size: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.income, style: TextStyle(fontSize: 12, color: mutedTextColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(currentMonthIncome, currencyState), style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: mutedTextColor?.withValues(alpha: 0.2)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_upward, color: Colors.red, size: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.expenses, style: TextStyle(fontSize: 12, color: mutedTextColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(currentMonthExpense, currencyState), style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: spendRatio,
                  minHeight: 6,
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
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

  Widget _buildQuickActions(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, Color cardColor) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildActionBtn(context, Icons.trending_up, l10n.invest, primaryColor, textColor, cardColor, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InvestPage()));
        })),
        const SizedBox(width: 8),
        Expanded(child: _buildActionBtn(context, Icons.flag_outlined, l10n.newGoal, primaryColor, textColor, cardColor, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePortfolioPage()));
        })),
        const SizedBox(width: 8),
        Expanded(child: _buildActionBtn(context, Icons.account_balance_wallet_outlined, l10n.wealth, primaryColor, textColor, cardColor, () {
          onGoToWealth?.call();
        })),
        const SizedBox(width: 8),
        Expanded(child: _buildActionBtn(context, Icons.receipt_long_outlined, l10n.activity, primaryColor, textColor, cardColor, () {
          onSeeAllActivity?.call();
        })),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label, Color primaryColor, Color? textColor, Color cardColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
                    bool isIncome = t.type.toLowerCase() == 'income';
                    final amt = t.amount.abs();
                    return Builder(
                      builder: (freshContext) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showTransactionOptions(freshContext, t),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Icon(_getCategoryIcon(t.category), color: isIncome ? Colors.green : textColor, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.note.isNotEmpty ? t.note : t.category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('MMM dd').format(t.date), style: TextStyle(fontSize: 13, color: mutedTextColor)),
                                ],
                              ),
                            ),
                            Text(CurrencyFormatter.format(amt, currencyState, showSignForPositive: isIncome), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          ],
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
              title: 'Edit',
              subtitle: 'Change amount, category, or date',
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
              title: 'Delete',
              subtitle: 'Remove this transaction permanently',
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

class AiInsightCard extends StatefulWidget {
  final Color? textColor;
  final Color primaryColor;
  final CurrencyState currencyState;
  
  const AiInsightCard({super.key, this.textColor, required this.primaryColor, required this.currencyState});

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  String? _insight;
  bool _isLoading = false;
  int _lastTransactionCount = -1; // track count to detect new transactions
  String? _lastLangCode; // track language to regenerate on language switch

  Future<void> _fetchInsight(List<TransactionModel> transactions) async {
    if (_isLoading) return;
    // Reset and re-fetch when transaction count changes
    final count = transactions.length;
    final langCode = context.read<LanguageCubit>().state.languageCode;
    if (_insight != null && count == _lastTransactionCount && langCode == _lastLangCode) return;
    _lastTransactionCount = count;
    _lastLangCode = langCode;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final recent = List<TransactionModel>.from(transactions)
        ..sort((a, b) => b.date.compareTo(a.date));
      final last10 = recent.take(10).map((t) => '${t.date.toIso8601String().substring(0, 10)}: ${t.type} ${CurrencyFormatter.format(t.amount, widget.currencyState)} for ${t.category} (${t.note})').join('\n');
      
      final insight = await GeminiService.generateFinancialInsight(last10, langCode);
      
      if (mounted) {
        setState(() {
          _insight = insight ?? AppLocalizations.of(context)!.insightError;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _insight = AppLocalizations.of(context)!.insightError;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded && state.transactions.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchInsight(state.transactions);
          });
        }
        
        return Container(
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.primaryColor.withValues(alpha: 0.2), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: widget.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.insight, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.textColor)),
                    const SizedBox(height: 4),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: LinearProgressIndicator(
                          backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
                          color: widget.primaryColor,
                          minHeight: 2,
                        ),
                      )
                    else
                      Text(
                        _insight ?? AppLocalizations.of(context)!.insightEmpty, 
                        style: TextStyle(fontSize: 13, color: widget.textColor?.withValues(alpha: 0.8), height: 1.4),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
