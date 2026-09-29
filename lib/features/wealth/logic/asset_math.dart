// Holding calculations shared by Wealth screens (Feedback #4).
// Thai tickers (.BK) are priced in THB, everything else in USD.

import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';

class AssetMath {
  static String baseCurrency(AssetModel a) =>
      a.tickerSymbol.toUpperCase().endsWith('.BK') ? 'THB' : 'USD';

  /// Current market value in the user's selected currency.
  static double marketValue(AssetModel a, CurrencyState cs) =>
      CurrencyFormatter.convert(a.totalQuantity * a.currentPrice, cs, fromCurrency: baseCurrency(a));

  /// Total cost (quantity × average buy price) in the user's selected currency.
  static double costBasis(AssetModel a, CurrencyState cs) =>
      CurrencyFormatter.convert(a.totalQuantity * a.averageBuyPrice, cs, fromCurrency: baseCurrency(a));

  /// Unrealised gain/loss in %, or null when the cost is unknown.
  static double? gainPercent(AssetModel a) {
    final cost = a.totalQuantity * a.averageBuyPrice;
    if (cost <= 0) return null;
    return (a.totalQuantity * a.currentPrice - cost) / cost * 100;
  }

  /// Existing holding of the same ticker in the same goal (or unassigned).
  static AssetModel? findSameHolding(List<AssetModel> assets, String ticker, String portfolioId) {
    final t = ticker.trim().toUpperCase();
    if (t.isEmpty) return null;
    for (final a in assets) {
      if (a.tickerSymbol.trim().toUpperCase() == t && a.portfolioId == portfolioId) return a;
    }
    return null;
  }

  /// Adds a new buy to an existing holding: quantities add up and the
  /// average buy price becomes the quantity-weighted average.
  static AssetModel mergeBuy(AssetModel existing, {required double quantity, required double buyPrice, double? currentPrice}) {
    final totalQty = existing.totalQuantity + quantity;
    final avg = totalQty > 0
        ? (existing.totalQuantity * existing.averageBuyPrice + quantity * buyPrice) / totalQty
        : buyPrice;
    return existing.copyWith(
      totalQuantity: totalQty,
      averageBuyPrice: avg,
      currentPrice: (currentPrice != null && currentPrice > 0) ? currentPrice : existing.currentPrice,
    );
  }

  /// Quantity without trailing zeros: 10 → "10", 0.5 → "0.5", 0.123456789 → "0.123457".
  static String formatQuantity(double q) {
    if (q == q.roundToDouble()) return q.toStringAsFixed(0);
    var s = q.toStringAsFixed(6);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }

  /// Plans moving [moving] into goal [targetPortfolioId] ('' = Unassigned).
  /// If the target already holds the same ticker, the moved holding is merged
  /// into it (weighted average price) and the moved record is deleted, so a
  /// goal never shows the same ticker twice. Handles several assets of the
  /// same ticker moved at once. Pure function — caller dispatches the result.
  static ({List<AssetModel> updates, List<String> deletes}) planMove(
    List<AssetModel> all,
    List<AssetModel> moving,
    String targetPortfolioId,
  ) {
    // working copy keyed by id, latest version of every asset
    final working = <String, AssetModel>{for (final a in all) a.id: a};
    for (final m in moving) {
      working.putIfAbsent(m.id, () => m);
    }
    final updated = <String, AssetModel>{};
    final deletes = <String>[];

    for (final m in moving) {
      final cur = working[m.id];
      if (cur == null || cur.portfolioId == targetPortfolioId) continue;
      final t = cur.tickerSymbol.trim().toUpperCase();
      AssetModel? same;
      if (t.isNotEmpty) {
        for (final a in working.values) {
          if (a.id != cur.id &&
              a.portfolioId == targetPortfolioId &&
              a.tickerSymbol.trim().toUpperCase() == t) {
            same = a;
            break;
          }
        }
      }
      if (same != null) {
        final merged = mergeBuy(same, quantity: cur.totalQuantity, buyPrice: cur.averageBuyPrice);
        working[same.id] = merged;
        updated[same.id] = merged;
        working.remove(cur.id);
        updated.remove(cur.id);
        deletes.add(cur.id);
      } else {
        final moved = cur.copyWith(portfolioId: targetPortfolioId);
        working[cur.id] = moved;
        updated[cur.id] = moved;
      }
    }
    return (updates: updated.values.toList(), deletes: deletes);
  }
}
