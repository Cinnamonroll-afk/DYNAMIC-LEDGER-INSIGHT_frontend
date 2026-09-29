// One actions menu for a holding, wherever it is shown (goal page or
// Unassigned list) — Feedback #7: buy more, sell, edit, move, delete.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/add_entry_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/goal_actions.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

void showAssetActionsSheet(BuildContext context, AssetModel asset) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color;
  final muted = theme.textTheme.bodySmall?.color;
  final primary = theme.colorScheme.primary;
  final cs = context.read<CurrencyCubit>().state;
  final inGoal = asset.portfolioId.isNotEmpty;
  final gain = AssetMath.gainPercent(asset);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      Widget tile(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                          Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.75), fontSize: 12, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

      return GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
              const SizedBox(height: 16),
              // Header: name, ticker · qty, value, gain
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 2),
                        Text(
                          '${asset.tickerSymbol.toUpperCase()} · ${l10n.sharesUnits(AssetMath.formatQuantity(asset.totalQuantity))}',
                          style: TextStyle(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(AssetMath.marketValue(asset, cs), cs, fromCurrency: cs.selectedCurrency),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                      ),
                      if (gain != null)
                        Text(
                          '${gain >= 0 ? '+' : '−'}${gain.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: gain >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              tile(Icons.add_circle_outline, const Color(0xFF10B981), l10n.buyMoreAction, l10n.buyMoreSubtitle, () {
                Navigator.pop(sheetCtx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddEntrySheet(asset: asset, buyMore: true),
                );
              }),
              tile(Icons.remove_circle_outline, Colors.orangeAccent, l10n.sellAction, l10n.sellSubtitle, () {
                Navigator.pop(sheetCtx);
                _showSellSheet(context, asset);
              }),
              tile(Icons.edit_outlined, primary, l10n.editAction, l10n.changeQtyBuyPrice, () {
                Navigator.pop(sheetCtx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddEntrySheet(asset: asset),
                );
              }),
              if (inGoal)
                tile(Icons.link_off, Colors.blueGrey, l10n.removeFromGoal, l10n.removeFromGoalSubtitle, () {
                  Navigator.pop(sheetCtx);
                  moveAssetsToGoal(context.read<AssetBloc>(), [asset], '');
                })
              else
                tile(Icons.flag_outlined, primary, l10n.assignToGoalAction, l10n.assignToGoalSubtitle, () {
                  Navigator.pop(sheetCtx);
                  _showGoalPicker(context, asset);
                }),
              tile(Icons.delete_outline, Colors.redAccent, l10n.deletePermanently, l10n.deletePermanentlySubtitle, () {
                Navigator.pop(sheetCtx);
                _confirmDelete(context, asset);
              }),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmDelete(BuildContext context, AssetModel asset) async {
  final l10n = AppLocalizations.of(context)!;
  final bloc = context.read<AssetBloc>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (dCtx) => AlertDialog(
      title: Text(l10n.deletePermanently),
      content: Text(l10n.deleteAssetConfirm(asset.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(dCtx, true),
          child: Text(l10n.deleteAction, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  if (ok == true) bloc.add(DeleteAsset(asset.id));
}

void _showGoalPicker(BuildContext context, AssetModel asset) {
  final l10n = AppLocalizations.of(context)!;
  final st = context.read<PortfolioBloc>().state;
  final goals = st is PortfolioLoaded ? st.portfolios : const <PortfolioModel>[];
  final textColor = Theme.of(context).textTheme.bodyLarge?.color;
  final primary = Theme.of(context).colorScheme.primary;
  final bloc = context.read<AssetBloc>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.assignToGoalAction, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 8),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(l10n.noGoalsYet, style: TextStyle(color: textColor?.withValues(alpha: 0.6))),
            )
          else
            ...goals.map((g) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(IconData(g.icon, fontFamily: 'MaterialIcons'), color: primary),
                  title: Text(g.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    moveAssetsToGoal(bloc, [asset], g.id);
                  },
                )),
        ],
      ),
    ),
  );
}

void _showSellSheet(BuildContext context, AssetModel asset) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SellSheet(asset: asset),
  );
}

class _SellSheet extends StatefulWidget {
  final AssetModel asset;
  const _SellSheet({required this.asset});

  @override
  State<_SellSheet> createState() => _SellSheetState();
}

class _SellSheetState extends State<_SellSheet> {
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyController.text.replaceAll(',', '').trim()) ?? 0;
  double get _held => widget.asset.totalQuantity;
  bool get _valid => _qty > 0 && _qty <= _held + 1e-9;
  bool get _sellsAll => _valid && (_held - _qty).abs() < 1e-9;

  Future<void> _submit() async {
    if (!_valid) return;
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<AssetBloc>();
    if (_sellsAll) {
      // Selling everything → ask whether to remove the holding
      final remove = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: Text(l10n.sellAllTitle),
          content: Text(l10n.sellAllBody(widget.asset.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(dCtx, true),
              child: Text(l10n.sellAllConfirm, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (remove != true) return;
      bloc.add(DeleteAsset(widget.asset.id));
    } else {
      // Partial sell: quantity goes down, average buy price stays the same
      bloc.add(UpdateAsset(widget.asset.copyWith(totalQuantity: _held - _qty)));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final isDark = theme.brightness == Brightness.dark;
    final fieldBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    final cs = context.watch<CurrencyCubit>().state;
    final a = widget.asset;
    final proceeds = AssetMath.marketValue(a.copyWith(totalQuantity: _valid ? _qty : 0), cs);
    final tooMuch = _qty > _held + 1e-9;

    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('${l10n.sellAction} ${a.tickerSymbol.toUpperCase()}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 4),
          Text(l10n.youHoldUnits(AssetMath.formatQuantity(_held)), style: TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text(l10n.quantityToSell, style: TextStyle(color: textColor, fontWeight: FontWeight.w700))),
              TextButton(
                onPressed: () => setState(() => _qtyController.text = AssetMath.formatQuantity(_held)),
                child: Text(l10n.sellAllButton),
              ),
            ],
          ),
          TextField(
            controller: _qtyController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 20),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: l10n.unitsSuffix,
              errorText: tooMuch ? l10n.sellTooMuch(AssetMath.formatQuantity(_held)) : null,
              filled: true,
              fillColor: fieldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.estimatedProceeds, style: TextStyle(color: muted, fontSize: 13)),
              const Spacer(),
              Text(
                CurrencyFormatter.format(proceeds, cs, fromCurrency: cs.selectedCurrency),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          if (_valid && !_sellsAll) ...[
            const SizedBox(height: 4),
            Text(l10n.remainingUnits(AssetMath.formatQuantity(_held - _qty)), style: TextStyle(color: muted, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _valid ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.orangeAccent.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(l10n.confirmSell, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
