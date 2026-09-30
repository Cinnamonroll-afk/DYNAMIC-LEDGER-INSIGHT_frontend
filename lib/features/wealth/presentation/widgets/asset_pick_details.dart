import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

/// Name + "TICKER · qty" on the left, market value + gain/loss % on the
/// right. Used in the "Select Assets" sheets so similar holdings can be told
/// apart (Feedback #4). Must be placed inside a Row.
class AssetPickDetails extends StatelessWidget {
  final AssetModel asset;
  final Color? textColor;

  const AssetPickDetails({super.key, required this.asset, this.textColor});

  @override
  Widget build(BuildContext context) {
    final cs = context.read<CurrencyCubit>().state;
    final muted = textColor?.withValues(alpha: 0.55);
    final value = AssetMath.marketValue(asset, cs);
    final gain = AssetMath.gainPercent(asset);
    final ticker = asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol.toUpperCase() : asset.category;
    final qty = AppLocalizations.of(context)!.sharesUnits(AssetMath.formatQuantity(asset.totalQuantity));

    Color gainColor = muted ?? Colors.grey;
    String gainText = '';
    if (gain != null) {
      gainColor = gain > 0.05
          ? const Color(0xFF10B981)
          : gain < -0.05
              ? const Color(0xFFEF4444)
              : (muted ?? Colors.grey);
      gainText = '${gain >= 0 ? '+' : '−'}${gain.abs().toStringAsFixed(1)}%';
    }

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text('$ticker · $qty',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(value, cs, fromCurrency: cs.selectedCurrency),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              if (gainText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(gainText, style: TextStyle(color: gainColor, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

/// "Quantity to move: [ 10 ] units  All" — shown under a selected asset in the
/// "Select Assets" sheets so only part of a holding can be put into a goal.
/// Defaults to the whole holding.
class PickQuantityField extends StatelessWidget {
  final TextEditingController controller;
  final double held;
  final VoidCallback onChanged;

  const PickQuantityField({super.key, required this.controller, required this.held, required this.onChanged});

  /// The quantity typed in, or null when it is 0 / more than held.
  static double? parse(TextEditingController c, double held) {
    final q = double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;
    return (q > 0 && q <= held + 1e-9) ? q : null;
  }

  static bool anyInvalid(List<AssetModel> selected, Map<String, TextEditingController> ctrls) =>
      selected.any((a) => ctrls[a.id] != null && parse(ctrls[a.id]!, a.totalQuantity) == null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final isDark = theme.brightness == Brightness.dark;
    final fieldBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    final invalid = parse(controller, held) == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(l10n.moveQuantityLabel, style: TextStyle(color: muted, fontSize: 12.5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              onChanged: (_) => onChanged(),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                suffixText: l10n.unitsSuffix,
                errorText: invalid ? l10n.sellTooMuch(AssetMath.formatQuantity(held)) : null,
                filled: true,
                fillColor: fieldBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.text = AssetMath.formatQuantity(held);
              onChanged();
            },
            child: Text(l10n.moveAllButton),
          ),
        ],
      ),
    );
  }
}
