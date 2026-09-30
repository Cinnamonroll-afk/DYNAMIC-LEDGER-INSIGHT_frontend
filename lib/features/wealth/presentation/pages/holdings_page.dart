// All holdings (Holdings) — like the holdings list in common brokerage apps.
// The same ticker is combined into one row no matter which goal it sits in,
// with a breakdown of where it is held. Tap a location to buy more / sell /
// move / delete that holding.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_actions_sheet.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

const _green = Color(0xFF10B981);
const _red = Color(0xFFEF4444);

/// One ticker across every goal / unassigned.
class HoldingGroup {
  final String key;
  final List<AssetModel> assets;
  HoldingGroup(this.key, this.assets);

  String get name => assets.first.name;
  String get label {
    final t = assets.first.tickerSymbol.trim().toUpperCase();
    return t.isNotEmpty ? t : assets.first.category;
  }

  double get quantity => assets.fold(0.0, (s, a) => s + a.totalQuantity);
  double value(CurrencyState cs) => assets.fold(0.0, (s, a) => s + AssetMath.marketValue(a, cs));
  double cost(CurrencyState cs) => assets.fold(0.0, (s, a) => s + AssetMath.costBasis(a, cs));

  /// Groups holdings by ticker (or by name when there is no ticker),
  /// largest market value first.
  static List<HoldingGroup> build(List<AssetModel> all, CurrencyState cs) {
    final map = <String, List<AssetModel>>{};
    for (final a in all) {
      final t = a.tickerSymbol.trim().toUpperCase();
      final key = t.isNotEmpty ? 'T:$t' : 'N:${a.name.trim().toLowerCase()}';
      map.putIfAbsent(key, () => []).add(a);
    }
    final groups = map.entries.map((e) => HoldingGroup(e.key, e.value)).toList();
    groups.sort((a, b) => b.value(cs).compareTo(a.value(cs)));
    return groups;
  }
}

class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;

    final cs = context.watch<CurrencyCubit>().state;
    final assetState = context.watch<AssetBloc>().state;
    final goalState = context.watch<PortfolioBloc>().state;

    final assets = assetState is AssetLoaded ? assetState.assets : <AssetModel>[];
    final goalNames = <String, String>{
      if (goalState is PortfolioLoaded)
        for (final g in goalState.portfolios) g.id: g.name,
    };
    final groups = HoldingGroup.build(assets, cs);

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
              ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '${l10n.holdingsTitle} (${groups.length})',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.holdingsEmpty,
                        textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 15)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(l10n.holdingsHint, style: TextStyle(color: muted, fontSize: 12.5)),
                    ),
                    for (final g in groups) ...[
                      _HoldingCard(group: g, goalNames: goalNames),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final HoldingGroup group;
  final Map<String, String> goalNames;

  const _HoldingCard({required this.group, required this.goalNames});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = context.watch<CurrencyCubit>().state;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final primary = Theme.of(context).colorScheme.primary;
    String money(double v) => CurrencyFormatter.format(v, cs, fromCurrency: cs.selectedCurrency);

    final value = group.value(cs);
    final cost = group.cost(cs);
    final pct = cost > 0 ? (value - cost) / cost * 100 : null;
    Color gainColor = muted ?? Colors.grey;
    if (pct != null) {
      gainColor = pct > 0.05 ? _green : (pct < -0.05 ? _red : (muted ?? Colors.grey));
    }
    final qty = l10n.sharesUnits(AssetMath.formatQuantity(group.quantity));

    // Unassigned first, then goals by name.
    final locations = [...group.assets]
      ..sort((a, b) {
        if (a.portfolioId.isEmpty != b.portfolioId.isEmpty) return a.portfolioId.isEmpty ? -1 : 1;
        return (goalNames[a.portfolioId] ?? '').compareTo(goalNames[b.portfolioId] ?? '');
      });

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Text(
                  (group.label.isNotEmpty ? group.label : '?').substring(0, 1).toUpperCase(),
                  style: TextStyle(color: primary, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${group.label} · $qty',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money(value), style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15)),
                    if (pct != null) ...[
                      const SizedBox(height: 2),
                      Text('${pct >= 0 ? '+' : '−'}${pct.abs().toStringAsFixed(1)}%',
                          style: TextStyle(color: gainColor, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.08)),
          for (final a in locations)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showAssetActionsSheet(context, a),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(52, 10, 0, 10),
                child: Row(
                  children: [
                    Icon(a.portfolioId.isEmpty ? Icons.inbox_outlined : Icons.flag_outlined, size: 16, color: muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.portfolioId.isEmpty ? l10n.holdingsUnassigned : (goalNames[a.portfolioId] ?? '—'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontSize: 13),
                      ),
                    ),
                    Text(l10n.sharesUnits(AssetMath.formatQuantity(a.totalQuantity)),
                        style: TextStyle(color: muted, fontSize: 12.5)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: muted, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
