import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';

import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/goal_actions.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_pick_details.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_actions_sheet.dart';

class CreatedPortfolio extends StatefulWidget {
  final PortfolioModel? portfolio;
  final double? currentAmount;

  const CreatedPortfolio({
    super.key,
    this.portfolio,
    this.currentAmount,
  });

  @override
  State<CreatedPortfolio> createState() => _CreatedPortfolioState();
}

class _CreatedPortfolioState extends State<CreatedPortfolio> {
  /// Assets swiped away, hidden while the Undo snackbar is showing.
  final Set<String> _pendingRemoval = {};

  void _removeFromGoalWithUndo(AssetModel asset) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<AssetBloc>();
    setState(() => _pendingRemoval.add(asset.id));
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(SnackBar(
          content: Text(l10n.assetRemovedFromGoal(asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol : asset.name)),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: l10n.undoAction, onPressed: () {}),
        ))
        .closed
        .then((reason) {
      if (reason == SnackBarClosedReason.action) {
        if (mounted) setState(() => _pendingRemoval.remove(asset.id));
        return;
      }
      if (!bloc.isClosed) moveAssetsToGoal(bloc, [asset], '');
      // keep hidden until the reload arrives; then it's no longer in this goal
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _pendingRemoval.remove(asset.id));
      });
    });
  }




  void _showAddAssetSheet(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Get unassigned assets from global state
    final assetState = context.read<AssetBloc>().state;
    final allAssets = assetState is AssetLoaded ? assetState.assets : <AssetModel>[];
    final unassigned = allAssets.where((a) => a.portfolioId.isEmpty).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.addAssetBtn, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            // Option 1: From existing unassigned assets
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showPickExistingSheet(context, unassigned);
              },
              child: GlassContainer(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: primaryColor.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: primaryColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('From existing assets', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('Pick from unassigned assets (${unassigned.length})',
                          style: TextStyle(color: textColor?.withValues(alpha: 0.5), fontSize: 12)),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios, color: primaryColor, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Option 2: Add new from market
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => InvestPage(portfolioId: widget.portfolio?.id),
                ));
              },
              child: GlassContainer(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: primaryColor.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(Icons.add_chart, color: primaryColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Add new from market', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(AppLocalizations.of(context)!.browseMarketAddNew, style: TextStyle(color: textColor?.withValues(alpha: 0.5), fontSize: 12)),
                      ]),
                    ),
                    Icon(Icons.arrow_forward_ios, color: primaryColor, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickExistingSheet(BuildContext context, List<AssetModel> unassigned) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (unassigned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unassigned assets available')),
      );
      return;
    }

    final tempSelected = <AssetModel>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Select Assets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.chooseOneOrMoreAssets, style: TextStyle(fontSize: 12, color: textColor?.withValues(alpha: 0.5))),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: unassigned.length,
                  itemBuilder: (_, i) {
                    final asset = unassigned[i];
                    final isSelected = tempSelected.any((a) => a.id == asset.id);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (isSelected) {
                            tempSelected.removeWhere((a) => a.id == asset.id);
                          } else {
                            tempSelected.add(asset);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withValues(alpha: 0.12) : textColor?.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Center(child: Text(
                              asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol[0] : asset.name[0],
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                            )),
                          ),
                          const SizedBox(width: 12),
                          AssetPickDetails(asset: asset, textColor: textColor),
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.transparent,
                              border: Border.all(color: isSelected ? primaryColor : (textColor?.withValues(alpha: 0.3) ?? Colors.grey)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: tempSelected.isEmpty ? null : () {
                    moveAssetsToGoal(context.read<AssetBloc>(), tempSelected, widget.portfolio!.id);
                    Navigator.pop(sheetCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    tempSelected.isEmpty ? 'Select Assets' : 'Add ${tempSelected.length} Asset${tempSelected.length > 1 ? "s" : ""}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Goal', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${widget.portfolio?.name}"? Assets in this goal will become unassigned.',
          style: TextStyle(color: textColor?.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              deleteGoalAndRefresh(context, widget.portfolio!.id); // assets → Unassigned
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to wealth page
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // All amounts in the user's currency; .BK tickers are THB, others USD (Feedback #6)
    final cs = context.watch<CurrencyCubit>().state;
    String money(double v, {int decimals = 2}) =>
        CurrencyFormatter.format(v, cs, decimals: decimals, fromCurrency: cs.selectedCurrency);

    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        List<AssetModel> assets = [];
        double totalBalance = 0.0;
        double totalInvested = 0.0;
        
        if (state is AssetLoaded) {
          // Filter locally — don't dispatch LoadAssets(portfolioId) which would pollute the global bloc
          assets = widget.portfolio != null
              ? state.assets
                  .where((a) => a.portfolioId == widget.portfolio!.id && !_pendingRemoval.contains(a.id))
                  .toList()
              : state.assets;
          for (var asset in assets) {
            totalBalance += AssetMath.marketValue(asset, cs);
            totalInvested += AssetMath.costBasis(asset, cs);
          }
        } else {
          totalBalance = widget.currentAmount ?? 0.0;
        }

        final double totalReturn = totalBalance - totalInvested;
        final double returnPercentage = totalInvested > 0 ? (totalReturn / totalInvested) * 100 : 0.0;
        final bool isPositive = totalReturn >= 0;
        final Color returnColor = isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

        // Target is stored in USD → show it in the user's currency
        final double? rawTarget = widget.portfolio?.targetGoal;
        final double? targetGoal = (rawTarget != null && rawTarget > 0)
            ? CurrencyFormatter.convert(rawTarget, cs, fromCurrency: 'USD')
            : null;
        final bool hasGoal = targetGoal != null && targetGoal > 0;
        final double goalProgress = hasGoal
            ? (totalBalance / targetGoal).clamp(0.0, 1.0)
            : 0.0;

        final List<Color> sectionColors = const [
          Colors.blueAccent,
          Colors.orangeAccent,
          Colors.purpleAccent,
          Colors.greenAccent,
          Colors.redAccent,
          Colors.tealAccent,
        ];

        List<PieChartSectionData> pieChartSections = [];
        if (assets.isNotEmpty && totalBalance > 0) {
          for (int i = 0; i < assets.length; i++) {
            final asset = assets[i];
            final double assetValue = AssetMath.marketValue(asset, cs);
            final double percentage = (assetValue / totalBalance) * 100;
            pieChartSections.add(
              PieChartSectionData(
                color: sectionColors[i % sectionColors.length],
                value: percentage,
                title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                radius: 40,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }
        }

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
            widget.portfolio?.name ?? 'My Portfolio',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: widget.portfolio != null ? [
            TextButton.icon(
              icon: Icon(Icons.edit_outlined, color: textColor, size: 18),
              label: Text(AppLocalizations.of(context)!.editAction, style: TextStyle(color: textColor, fontSize: 13)),
              onPressed: () async {
                final updated = await Navigator.push<PortfolioModel>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePortfolioPage(
                      existingPortfolio: widget.portfolio,
                    ),
                  ),
                );
                // Refresh this page with the edited name/target
                if (updated != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => CreatedPortfolio(portfolio: updated)),
                  );
                }
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              onPressed: () => _confirmDelete(context),
            ),
          ] : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Summary Card
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.totalBalance,
                            style: TextStyle(
                              color: mutedTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            money(totalBalance),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (assets.isEmpty ? primaryColor : returnColor).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        assets.isEmpty
                                            ? Icons.info_outline
                                            : (isPositive ? Icons.arrow_upward : Icons.arrow_downward),
                                        size: 14,
                                        color: assets.isEmpty ? primaryColor : returnColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          assets.isNotEmpty
                                              ? '${isPositive ? '+' : '\u2212'}${money(totalReturn.abs())} (${returnPercentage.abs().toStringAsFixed(1)}%)'
                                              : (hasGoal
                                                  ? '${(goalProgress * 100).toStringAsFixed(0)}% of Target'
                                                  : 'No assets yet'),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: assets.isEmpty ? primaryColor : returnColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (assets.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.totalReturn,
                                  style: TextStyle(
                                    color: mutedTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (hasGoal) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.targetLabel}: ${money(targetGoal, decimals: 0)}',
                                  style: TextStyle(
                                    color: mutedTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(goalProgress * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: goalProgress,
                                minHeight: 6,
                                backgroundColor: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (assets.isNotEmpty && totalBalance > 0)
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            centerSpaceRadius: 16,
                            sectionsSpace: 2,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.myPortfolio,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (assets.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showAddAssetSheet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context)!.addAssetBtn),
                      // Filled pill so it stands out from the dark background (Feedback #9)
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: assets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.thisPortfolioEmpty,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 180,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _showAddAssetSheet(context),
                                child: Text(
                                  AppLocalizations.of(context)!.addAssetBtn,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: assets.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final asset = assets[index];
                          IconData iconData = Icons.account_balance_wallet;
                          if (asset.category == 'Stock') iconData = Icons.trending_up;
                          if (asset.category == 'Crypto') iconData = Icons.currency_bitcoin;

                          
                          // Calculate profit/loss for this individual asset
                          final double assetInvested = AssetMath.costBasis(asset, cs);
                          final double assetCurrentValue = AssetMath.marketValue(asset, cs);
                          final double assetProfit = assetCurrentValue - assetInvested;
                          final double assetReturnPct = assetInvested > 0 ? (assetProfit / assetInvested) * 100 : 0.0;
                          final bool assetIsPositive = assetProfit >= 0;
                          final Color assetReturnColor = assetIsPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

                          return Dismissible(
                            key: Key(asset.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.link_off, color: Colors.white),
                            ),
                            // Swipe = remove from this goal (→ Unassigned), with Undo.
                            // Permanent delete only from the menu, with confirmation.
                            onDismissed: (direction) => _removeFromGoalWithUndo(asset),
                            child: GestureDetector(
                              onTap: () => showAssetActionsSheet(context, asset),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/${asset.tickerSymbol}.png',
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Center(
                                              child: Text(
                                                asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol.substring(0, 1) : '?',
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            asset.name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: sectionColors[index % sectionColors.length],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${asset.tickerSymbol} • ${totalBalance > 0 ? ((assetCurrentValue / totalBalance) * 100).toStringAsFixed(1) : 0}%',
                                                style: TextStyle(
                                                  color: mutedTextColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          money(assetCurrentValue),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(context)!.sharesUnits(AssetMath.formatQuantity(asset.totalQuantity)),
                                          style: TextStyle(
                                            color: mutedTextColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${assetIsPositive ? '+' : '\u2212'}${money(assetProfit.abs())} (${assetReturnPct.abs().toStringAsFixed(2)}%)',
                                          style: TextStyle(
                                            color: assetReturnColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}