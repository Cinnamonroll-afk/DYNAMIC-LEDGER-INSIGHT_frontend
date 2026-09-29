// Wealth page (Feedback #8) — layout follows common investing apps
// (Dime, Webull, Monarch):
//   portfolio value + total gain (amount & %) + allocation by type + cost
//   → primary actions (Invest / New goal)
//   → goals as a vertical list with progress (completed goals collapsed)
//   → unassigned holdings (tap for buy more / sell / move / delete)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/features/wealth/presentation/pages/created_portfolio.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/goal_actions.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_actions_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_pick_details.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

const _green = Color(0xFF10B981);
const _red = Color(0xFFEF4444);

/// Asset type buckets for the allocation bar.
enum _AssetType { stock, crypto, etf, fund, other }

_AssetType _typeOf(AssetModel a) {
  final c = a.category.toLowerCase();
  if (c.startsWith('stock')) return _AssetType.stock;
  if (c.startsWith('crypto')) return _AssetType.crypto;
  if (c.startsWith('etf')) return _AssetType.etf;
  if (c.contains('fund')) return _AssetType.fund;
  return _AssetType.other;
}

const _typeColors = {
  _AssetType.stock: Color(0xFF6366F1),
  _AssetType.crypto: Color(0xFFF59E0B),
  _AssetType.etf: Color(0xFF06B6D4),
  _AssetType.fund: Color(0xFFEC4899),
  _AssetType.other: Color(0xFF94A3B8),
};

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
    if (mounted) {
      setState(() {
        _archivedGoalIds = ids.toSet();
        _celebratedGoalIds = celebrated.toSet();
      });
    }
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

  // ── Goal maths ────────────────────────────────────────────────────────────
  double _goalValue(PortfolioModel goal, List<AssetModel> assets, CurrencyState cs) => assets
      .where((a) => a.portfolioId == goal.id)
      .fold(0.0, (s, a) => s + AssetMath.marketValue(a, cs));

  /// Target in the user's currency (stored in USD); 0 = no target set.
  double _goalTarget(PortfolioModel goal, CurrencyState cs) {
    final t = goal.targetGoal ?? 0;
    return t > 0 ? CurrencyFormatter.convert(t, cs, fromCurrency: 'USD') : 0;
  }

  void _checkCelebrations(List<PortfolioModel> activeGoals, List<AssetModel> assets, CurrencyState cs) {
    for (final goal in activeGoals) {
      final target = _goalTarget(goal, cs);
      if (target <= 0 || _celebratedGoalIds.contains(goal.id)) continue;
      if (_goalValue(goal, assets, cs) >= target) {
        _celebratedGoalIds.add(goal.id);
        SharedPreferences.getInstance()
            .then((p) => p.setStringList('celebrated_goal_ids', _celebratedGoalIds.toList()));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showGoalCompletionSheet(context, goal);
        });
        break;
      }
    }
  }

  void _openInvest() => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestPage()));
  void _openNewGoal() => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePortfolioPage()));

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CurrencyCubit>().state;
    final assetState = context.watch<AssetBloc>().state;
    final goalState = context.watch<PortfolioBloc>().state;

    final assets = assetState is AssetLoaded ? assetState.assets : <AssetModel>[];
    final goals = goalState is PortfolioLoaded ? goalState.portfolios : <PortfolioModel>[];
    final activeGoals = goals.where((g) => !_archivedGoalIds.contains(g.id)).toList();
    final archivedGoals = goals.where((g) => _archivedGoalIds.contains(g.id)).toList();
    final unassigned = assets.where((a) => a.portfolioId.isEmpty).toList();
    final loading = assetState is AssetLoading || assetState is AssetInitial;

    if (assetState is AssetLoaded) _checkCelebrations(activeGoals, assets, cs);

    final isEmpty = !loading && assets.isEmpty && goals.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AssetBloc>().add(const LoadAssets());
            context.read<PortfolioBloc>().add(const LoadPortfolios(''));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _header(context),
              const SizedBox(height: 20),
              if (loading && assets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (isEmpty)
                _emptyState(context)
              else ...[
                _portfolioCard(context, assets, cs),
                const SizedBox(height: 14),
                _actionButtons(context),
                const SizedBox(height: 28),
                _goalsSection(context, activeGoals, archivedGoals, assets, cs),
                const SizedBox(height: 28),
                _unassignedSection(context, unassigned),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Row(
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.wealth,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: textColor),
          ),
        ),
        IconButton.filledTonal(
          tooltip: AppLocalizations.of(context)!.investAction,
          icon: const Icon(Icons.search),
          onPressed: _openInvest,
        ),
      ],
    );
  }

  Widget _portfolioCard(BuildContext context, List<AssetModel> assets, CurrencyState cs) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    String money(double v) => CurrencyFormatter.format(v, cs, fromCurrency: cs.selectedCurrency);

    double value = 0, cost = 0;
    final byType = <_AssetType, double>{};
    for (final a in assets) {
      final v = AssetMath.marketValue(a, cs);
      value += v;
      cost += AssetMath.costBasis(a, cs);
      byType[_typeOf(a)] = (byType[_typeOf(a)] ?? 0) + v;
    }
    final gain = value - cost;
    final pct = cost > 0 ? gain / cost * 100 : null;
    final up = gain >= 0;
    final gainColor = up ? _green : _red;
    final types = byType.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));

    String typeName(_AssetType t) => switch (t) {
          _AssetType.stock => l10n.assetTypeStock,
          _AssetType.crypto => l10n.assetTypeCrypto,
          _AssetType.etf => l10n.assetTypeEtf,
          _AssetType.fund => l10n.assetTypeFund,
          _AssetType.other => l10n.assetTypeOther,
        };

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.totalPortfolioValue, style: TextStyle(color: muted, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(money(value),
                style: TextStyle(color: textColor, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ),
          if (cost > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: gainColor, size: 24),
                Flexible(
                  child: Text(
                    '${money(gain.abs())}${pct != null ? ' (${up ? '+' : '−'}${pct.abs().toStringAsFixed(1)}%)' : ''}',
                    style: TextStyle(color: gainColor, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 6),
                Text(up ? l10n.totalGainLabel : l10n.totalLossLabel, style: TextStyle(color: muted, fontSize: 13)),
              ],
            ),
          ],
          if (types.isNotEmpty && value > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    for (final e in types)
                      Expanded(
                        flex: (e.value / value * 1000).round().clamp(1, 1000),
                        child: Container(color: _typeColors[e.key]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final e in types)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: _typeColors[e.key], shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${typeName(e.key)} ${(e.value / value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
              ],
            ),
          ],
          if (cost > 0) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.1)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(l10n.costBasisLabel, style: TextStyle(color: muted, fontSize: 13)),
                const Spacer(),
                Text(money(cost), style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openInvest,
            icon: const Icon(Icons.trending_up, size: 20),
            label: Text(l10n.investAction),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: shape,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openNewGoal,
            icon: const Icon(Icons.flag_outlined, size: 20),
            label: Text(l10n.createGoal, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary.withValues(alpha: 0.6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: shape,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text, {Widget? trailing}) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: textColor))),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _goalsSection(BuildContext context, List<PortfolioModel> active, List<PortfolioModel> archived,
      List<AssetModel> assets, CurrencyState cs) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final divider = Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.08));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.goalsCount('${active.length}')),
        if (active.isEmpty)
          GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: muted),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.noGoalsYet, style: TextStyle(color: muted, fontSize: 14))),
                TextButton(onPressed: _openNewGoal, child: Text(l10n.createGoal)),
              ],
            ),
          )
        else
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < active.length; i++) ...[
                  if (i > 0) divider,
                  _goalRow(context, active[i], assets, cs),
                ],
              ],
            ),
          ),
        if (archived.isNotEmpty) ...[
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _completedExpanded = !_completedExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: _green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.completedGoalsCount('${archived.length}'),
                        style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  Icon(_completedExpanded ? Icons.expand_less : Icons.expand_more, color: _green),
                ],
              ),
            ),
          ),
          if (_completedExpanded)
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (int i = 0; i < archived.length; i++) ...[
                    if (i > 0) divider,
                    _archivedRow(context, archived[i], assets, cs),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _goalRow(BuildContext context, PortfolioModel goal, List<AssetModel> assets, CurrencyState cs) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final primary = Theme.of(context).colorScheme.primary;
    String money(double v) => CurrencyFormatter.format(v, cs, decimals: 0, fromCurrency: cs.selectedCurrency);

    final value = _goalValue(goal, assets, cs);
    final target = _goalTarget(goal, cs);
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final done = target > 0 && progress >= 1.0;
    // ignore: non_const_argument_for_const_parameter
    final icon = IconData(goal.icon, fontFamily: 'MaterialIcons');

    return InkWell(
      onTap: () {
        if (done) {
          _showGoalCompletionSheet(context, goal);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreatedPortfolio(portfolio: goal, currentAmount: value)));
        }
      },
      onLongPress: () => _showGoalOptions(context, goal),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(goal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        target > 0 ? '${money(value)} / ${money(target)}' : money(value),
                        style: TextStyle(color: muted, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (target > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: primary.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(done ? _green : primary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      done ? '${l10n.completedBadge} ✓' : l10n.percentCompleted((progress * 100).toStringAsFixed(0)),
                      style: TextStyle(color: done ? _green : primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ] else
                    Text(l10n.noTargetSet, style: TextStyle(color: muted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: muted, size: 20),
              onPressed: () => _showGoalOptions(context, goal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _archivedRow(BuildContext context, PortfolioModel goal, List<AssetModel> assets, CurrencyState cs) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final value = _goalValue(goal, assets, cs);
    return ListTile(
      leading: const Icon(Icons.check_circle, color: _green),
      title: Text(goal.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
      subtitle: Text(CurrencyFormatter.format(value, cs, decimals: 0, fromCurrency: cs.selectedCurrency),
          style: TextStyle(color: muted)),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: muted, size: 20),
        onPressed: () => _showGoalOptions(context, goal, archived: true),
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatedPortfolio(portfolio: goal, currentAmount: value))),
    );
  }

  Widget _unassignedSection(BuildContext context, List<AssetModel> unassigned) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final primary = Theme.of(context).colorScheme.primary;
    final divider = Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.08));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, '${l10n.unassignedAssets} (${unassigned.length})'),
        if (unassigned.isEmpty)
          GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Text(l10n.noUnassignedAssets, style: TextStyle(color: muted, fontSize: 14)),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(l10n.tapAssetForActions, style: TextStyle(color: muted, fontSize: 12.5)),
          ),
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < unassigned.length; i++) ...[
                  if (i > 0) divider,
                  InkWell(
                    onTap: () => showAssetActionsSheet(context, unassigned[i]),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Text(
                              (unassigned[i].tickerSymbol.isNotEmpty ? unassigned[i].tickerSymbol : unassigned[i].name)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(color: primary, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AssetPickDetails(asset: unassigned[i], textColor: textColor),
                          Icon(Icons.chevron_right, color: muted),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final primary = Theme.of(context).colorScheme.primary;
    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.savings_outlined, color: primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(l10n.wealthEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(l10n.wealthEmptyBody,
              textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          _actionButtons(context),
        ],
      ),
    );
  }

  // ── Sheets & dialogs ──────────────────────────────────────────────────────
  void _showGoalCompletionSheet(BuildContext context, PortfolioModel goal) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    // ignore: non_const_argument_for_const_parameter
    final icon = IconData(goal.icon, fontFamily: 'MaterialIcons');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(l10n.goalAchievedTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _green)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: primary, size: 20),
                const SizedBox(width: 8),
                Flexible(child: Text(goal.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor))),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.goalAchievedBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textColor?.withValues(alpha: 0.7), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _archiveGoal(goal.id);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.archive_outlined),
                label: Text(l10n.archiveGoal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmDeleteGoal(context, goal);
                },
                icon: const Icon(Icons.delete_outline, color: _red),
                label: Text(l10n.deleteGoal, style: const TextStyle(color: _red, fontSize: 15, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.keepActive, style: TextStyle(color: textColor?.withValues(alpha: 0.6))),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalOptions(BuildContext context, PortfolioModel goal, {bool archived = false}) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Text(goal.name, style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: primary),
                title: Text(l10n.updateGoal, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePortfolioPage(existingPortfolio: goal)));
                },
              ),
              if (archived)
                ListTile(
                  leading: Icon(Icons.unarchive_outlined, color: primary),
                  title: Text(l10n.restoreGoal, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _unarchiveGoal(goal.id);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.archive_outlined, color: _green),
                  title: Text(l10n.archiveGoal, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _archiveGoal(goal.id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: _red),
                title: Text(l10n.deleteGoal, style: const TextStyle(color: _red, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteGoal(context, goal);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteGoal(BuildContext context, PortfolioModel goal) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteGoalConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(l10n.deleteAction, style: const TextStyle(color: _red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      // ignore: use_build_context_synchronously
      deleteGoalAndRefresh(context, goal.id);
      _archivedGoalIds.remove(goal.id);
    }
  }
}
