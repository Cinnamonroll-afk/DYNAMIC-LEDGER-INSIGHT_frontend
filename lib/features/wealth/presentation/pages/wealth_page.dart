import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/features/wealth/presentation/pages/created_portfolio.dart';

class WealthPage extends StatefulWidget {
  const WealthPage({super.key});

  @override
  State<WealthPage> createState() => _WealthPageState();
}

class _WealthPageState extends State<WealthPage> {
  Set<String> _celebratedGoalIds = {};
  Set<String> _archivedGoalIds = {};
  bool _completedExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadArchivedGoals();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetBloc>().add(const LoadAssets());
      context.read<PortfolioBloc>().add(const LoadPortfolios(''));
    });
  }

  Future<void> _loadArchivedGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('archived_goal_ids') ?? [];
    final celebrated = prefs.getStringList('celebrated_goal_ids') ?? [];
    if (mounted) setState(() {
      _archivedGoalIds = ids.toSet();
      _celebratedGoalIds = celebrated.toSet();
    });
  }

  Future<void> _archiveGoal(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _archivedGoalIds.add(id));
    await prefs.setStringList('archived_goal_ids', _archivedGoalIds.toList());
  }

  Future<void> _unarchiveGoal(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _archivedGoalIds.remove(id));
    await prefs.setStringList('archived_goal_ids', _archivedGoalIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                _buildHeader(context, textColor),
                const SizedBox(height: 32),
                _buildNetWorthOverview(context, textColor, mutedTextColor, primaryColor, currencyState),
                const SizedBox(height: 32),
                _buildGoalsSection(context, textColor, mutedTextColor, currencyState),
                const SizedBox(height: 32),
                _buildAssetsSection(context, textColor, mutedTextColor, primaryColor, currencyState),
                const SizedBox(height: 100),
              ],
            );
          },
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
          AppLocalizations.of(context)!.wealth,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        Row(
          children: [
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
                      icon: Icon(Icons.search, color: textColor),
                      iconSize: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvestPage(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetWorthOverview(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, CurrencyState currencyState) {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        double totalAssets = 0;
        double totalCost = 0;
        if (state is AssetLoaded) {
          for (var asset in state.assets) {
            String baseCurrency = asset.tickerSymbol.endsWith('.BK') ? 'THB' : 'USD';
            double assetValue = CurrencyFormatter.convert(asset.totalQuantity * asset.currentPrice, currencyState, fromCurrency: baseCurrency);
            double assetCost = CurrencyFormatter.convert(asset.totalQuantity * asset.averageBuyPrice, currencyState, fromCurrency: baseCurrency);
            totalAssets += assetValue;
            totalCost += assetCost;
          }
        }
        
        double pctChange = 0.0;
        if (totalCost > 0) {
            pctChange = ((totalAssets - totalCost) / totalCost) * 100;
        }
        
        final isPositive = pctChange >= 0;
        final sign = isPositive ? '+' : '';
        final badgeColor = isPositive ? Colors.green : Colors.red;
        final badgeIcon = isPositive ? Icons.trending_up : Icons.trending_down;
        final badgeBgColor = isPositive ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2);

        return GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.totalNetWorth,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: mutedTextColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$sign${pctChange.toStringAsFixed(1)}%',
                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(totalAssets, currencyState, fromCurrency: currencyState.selectedCurrency),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.assets, style: TextStyle(color: mutedTextColor, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(totalAssets, currencyState, fromCurrency: currencyState.selectedCurrency), style: TextStyle(color: Colors.greenAccent.shade400, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsSection(BuildContext context, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        List<dynamic> allGoals = [];
        if (state is PortfolioLoaded) allGoals = state.portfolios;

        final activeGoals = allGoals.where((g) => !_archivedGoalIds.contains(g.id)).toList();
        final archivedGoals = allGoals.where((g) => _archivedGoalIds.contains(g.id)).toList();

        // Detect newly completed goals and celebrate once per session
        final assetState = context.read<AssetBloc>().state;
        if (assetState is AssetLoaded) {
          for (final goal in activeGoals) {
            double currentAmount = 0.0;
            for (var asset in assetState.assets) {
              if (asset.portfolioId == goal.id) {
                final base = asset.tickerSymbol.endsWith('.BK') ? 'THB' : 'USD';
                currentAmount += CurrencyFormatter.convert(asset.totalQuantity * asset.currentPrice, currencyState, fromCurrency: base);
              }
            }
            double target = (goal.targetGoal ?? 1.0) == 0 ? 1.0 : (goal.targetGoal ?? 1.0);
            double convertedTarget = CurrencyFormatter.convert(target, currencyState, fromCurrency: 'USD');
            if (currentAmount >= convertedTarget && !_celebratedGoalIds.contains(goal.id)) {
              _celebratedGoalIds.add(goal.id);
              SharedPreferences.getInstance().then((prefs) {
                prefs.setStringList('celebrated_goal_ids', _celebratedGoalIds.toList());
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _showGoalCompletionSheet(context, goal);
              });
              break;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.financialGoals,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePortfolioPage())),
                  child: Text(AppLocalizations.of(context)!.addGoal, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeGoals.isEmpty && archivedGoals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text(AppLocalizations.of(context)!.noGoalsYet, style: TextStyle(color: mutedTextColor))),
              )
            else if (activeGoals.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeGoals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final goal = activeGoals[index];
                    return BlocBuilder<AssetBloc, AssetState>(
                      builder: (context, assetState) {
                        double currentAmount = 0.0;
                        if (assetState is AssetLoaded) {
                          for (var asset in assetState.assets) {
                            if (asset.portfolioId == goal.id) {
                              final base = asset.tickerSymbol.endsWith('.BK') ? 'THB' : 'USD';
                              currentAmount += CurrencyFormatter.convert(asset.totalQuantity * asset.currentPrice, currencyState, fromCurrency: base);
                            }
                          }
                        }
                        double target = (goal.targetGoal ?? 1.0) == 0 ? 1.0 : (goal.targetGoal ?? 1.0);
                        double convertedTarget = CurrencyFormatter.convert(target, currencyState, fromCurrency: 'USD');
                        double progress = (currentAmount / convertedTarget).clamp(0.0, 1.0);
                        return _buildGoalCard(context, goal, currentAmount, convertedTarget, progress, textColor, mutedTextColor, currencyState);
                      },
                    );
                  },
                ),
              ),
            // Completed / archived section
            if (archivedGoals.isNotEmpty) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _completedExpanded = !_completedExpanded),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Completed Goals (${archivedGoals.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                    const Spacer(),
                    Icon(_completedExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.green),
                  ],
                ),
              ),
              if (_completedExpanded) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: archivedGoals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => _buildArchivedGoalCard(context, archivedGoals[index], textColor, mutedTextColor, currencyState),
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }


  Widget _buildGoalCard(BuildContext context, dynamic goal, double currentAmount, double targetAmount, double progress, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final color = Theme.of(context).colorScheme.primary; 
    // ignore: non_const_argument_for_const_parameter
    final iconData = IconData(goal.icon as int, fontFamily: 'MaterialIcons');
    
    return GestureDetector(
        onTap: () {
          if (progress >= 1.0) {
            _showGoalCompletionSheet(context, goal);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreatedPortfolio(
              portfolio: goal,
              currentAmount: currentAmount,
            )));
          }
        },
        onLongPress: () {
          _showGoalOptions(context, goal);
        },
        child: SizedBox(
        width: 240,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(currentAmount, currencyState, decimals: 0, fromCurrency: currencyState.selectedCurrency), // Already converted
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
                    ),
                    Text(
                      CurrencyFormatter.format(targetAmount, currencyState, decimals: 0, fromCurrency: currencyState.selectedCurrency),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: mutedTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: mutedTextColor?.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                progress >= 1.0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Completed ✓',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.percentCompleted((progress * 100).toStringAsFixed(1)),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                      ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildAssetsSection(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, CurrencyState currencyState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unassigned Assets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Long-press an asset to assign it to a goal',
          style: TextStyle(fontSize: 13, color: mutedTextColor),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AssetBloc, AssetState>(
          builder: (context, state) {
            if (state is AssetLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AssetLoaded) {
              final orphanAssets = state.assets.where((a) => a.portfolioId.isEmpty).toList();
              if (orphanAssets.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No unassigned assets',
                      style: TextStyle(color: mutedTextColor, fontSize: 16),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orphanAssets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final asset = orphanAssets[index];
                  return GestureDetector(
                    onTap: () => _showAssetOptionsSheet(context, asset, primaryColor, textColor, mutedTextColor),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/icons/${asset.tickerSymbol}.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.account_balance_wallet, color: primaryColor, size: 24);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol : 'Asset',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.sharesUnits(asset.totalQuantity.toString()),
                                  style: TextStyle(fontSize: 13, color: mutedTextColor),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                  asset.totalQuantity * asset.currentPrice,
                                  currencyState,
                                  fromCurrency: asset.tickerSymbol.endsWith('.BK') ? 'THB' : 'USD'
                                ),
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Icon(Icons.more_horiz, color: mutedTextColor, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _showAssetOptionsSheet(BuildContext context, dynamic asset, Color primaryColor, Color? textColor, Color? mutedTextColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(asset.name.isNotEmpty ? asset.name : asset.tickerSymbol,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            Text(asset.category, style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5))),
            const SizedBox(height: 24),
            // Assign to goal
            _assetOptionTile(
              color: primaryColor,
              icon: Icons.flag_outlined,
              title: 'Assign to a goal',
              subtitle: 'Move this asset into one of your financial goals',
              onTap: () {
                Navigator.pop(sheetCtx);
                _showAssignToGoalSheet(context, asset);
              },
            ),
            const SizedBox(height: 10),
            // Delete permanently
            _assetOptionTile(
              color: Colors.redAccent,
              icon: Icons.delete_outline,
              title: 'Delete permanently',
              subtitle: 'Removes this asset and all its data forever',
              onTap: () {
                context.read<AssetBloc>().add(DeleteAsset(asset.id));
                Navigator.pop(sheetCtx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetOptionTile({required Color color, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
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

  void _showAssignToGoalSheet(BuildContext context, dynamic asset) {
    final portfolioState = context.read<PortfolioBloc>().state;
    final portfolios = portfolioState is PortfolioLoaded ? portfolioState.portfolios : [];
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Assign "${asset.tickerSymbol}" to Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 16),
            if (portfolios.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No goals yet. Create a goal first.', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...portfolios.map((portfolio) {
                final iconData = IconData(portfolio.icon as int, fontFamily: 'MaterialIcons');
                return ListTile(
                  leading: Icon(iconData, color: Theme.of(context).colorScheme.primary),
                  title: Text(portfolio.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  onTap: () {
                    final updated = asset.copyWith(portfolioId: portfolio.id);
                    context.read<AssetBloc>().add(UpdateAsset(updated));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${asset.tickerSymbol} assigned to ${portfolio.name}')),
                    );
                  },
                );
              }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showGoalCompletionSheet(BuildContext context, dynamic goal) {
    final iconData = IconData(goal.icon as int, fontFamily: 'MaterialIcons');
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Goal Achieved!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(goal.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "You've reached 100% of your goal!\nWhat would you like to do next?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textColor?.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _archiveGoal(goal.id);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive this goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<PortfolioBloc>().add(DeletePortfolio(goal.id));
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text('Delete goal', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Keep active', style: TextStyle(color: textColor?.withValues(alpha: 0.5), fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedGoalCard(BuildContext context, dynamic goal, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    const color = Colors.green;
    final iconData = IconData(goal.icon as int, fontFamily: 'MaterialIcons');
    return SizedBox(
      width: 200,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(goal.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(value: 1.0, minHeight: 6, backgroundColor: Color(0x26388E3C), valueColor: AlwaysStoppedAnimation<Color>(color)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Completed ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => context.read<PortfolioBloc>().add(DeletePortfolio(goal.id)),
                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                  label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

    void _showGoalOptions(BuildContext context, dynamic goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text('Update Goal', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePortfolioPage(existingPortfolio: goal)));
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.green),
              title: Text('Archive Goal', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
              subtitle: Text('Move to completed section', style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                _archiveGoal(goal.id);
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Goal', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, goal);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Delete Goal', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this goal? Assets will remain orphaned.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<PortfolioBloc>().add(DeletePortfolio(goal.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}