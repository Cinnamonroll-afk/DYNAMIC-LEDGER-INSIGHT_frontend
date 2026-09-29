import 'package:flutter/material.dart';
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
