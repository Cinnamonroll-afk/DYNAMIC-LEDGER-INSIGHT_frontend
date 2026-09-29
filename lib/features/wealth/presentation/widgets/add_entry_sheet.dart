// Record a buy / edit a holding (Feedback #5).
//
// Standard portfolio-tracker pattern (Yahoo Finance, Delta, Sharesight):
//   Quantity + Price per unit (prefilled with the market price) → Total.
// The total can also be typed (e.g. "I bought 1,000 THB of BTC") and the
// quantity is worked out from the price. Prices are in the asset's trading
// currency ($ for US tickers, ฿ for .BK), shown explicitly on every field.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';

class AddEntrySheet extends StatefulWidget {
  final AssetModel? asset;
  final String? portfolioId;

  /// true = record an additional buy of an existing holding (adds to it).
  final bool buyMore;

  const AddEntrySheet({super.key, this.asset, this.portfolioId, this.buyMore = false});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalController = TextEditingController();
  String _selectedCategory = 'Stock';

  static const _categories = ['Stock', 'Crypto', 'ETF', 'Mutual Fund', 'Other'];

  AssetModel? get _asset => widget.asset;

  /// A real saved holding (not a fresh pick from the market list).
  bool get _isRealAsset {
    final a = _asset;
    return a != null && a.id.isNotEmpty && !a.id.startsWith('mock_');
  }

  /// Editing the holding's numbers (vs recording a buy).
  bool get _isEdit => _isRealAsset && !widget.buyMore;

  double get _marketPrice => _asset?.currentPrice ?? 0;

  /// Name/ticker come from the market list; only ask for them if missing.
  bool get _needsIdentityFields =>
      _asset == null || _asset!.name.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final a = _asset;
    if (a != null) {
      _nameController.text = a.name;
      _symbolController.text = a.tickerSymbol;
      var cat = a.category;
      if (cat == 'Stocks') cat = 'Stock';
      if (cat == 'ETFs') cat = 'ETF';
      if (cat == 'Cryptocurrency') cat = 'Crypto';
      _selectedCategory = _categories.contains(cat) ? cat : 'Other';

      if (_isEdit) {
        if (a.totalQuantity > 0) _quantityController.text = AssetMath.formatQuantity(a.totalQuantity);
        if (a.averageBuyPrice > 0) _priceController.text = _num(a.averageBuyPrice);
      } else if (a.currentPrice > 0) {
        _priceController.text = _num(a.currentPrice); // prefill market price
      }
      _recalcTotal();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  static String _num(double v, {int maxDecimals = 2}) {
    var s = v.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  String get _baseCurrency {
    final t = _symbolController.text.trim().toUpperCase();
    return t.endsWith('.BK') ? 'THB' : 'USD';
  }

  String get _baseSymbol => _baseCurrency == 'THB' ? '฿' : '\$';

  double get _qty => _parse(_quantityController);
  double get _price => _parse(_priceController);
  double get _total => _parse(_totalController);

  bool get _canSave =>
      _qty > 0 && _price > 0 && _nameController.text.trim().isNotEmpty;

  void _recalcTotal() {
    final q = _qty, p = _price;
    _totalController.text = (q > 0 && p > 0) ? _num(q * p) : '';
  }

  void _recalcQuantityFromTotal() {
    final t = _total, p = _price;
    if (t > 0 && p > 0) {
      _quantityController.text = AssetMath.formatQuantity(t / p);
    } else if (t == 0) {
      _quantityController.text = '';
    }
  }

  // ── save ──────────────────────────────────────────────────────────────────
  void _save() {
    if (!_canSave) return;
    final quantity = _qty;
    final buyPrice = _price;
    final a = _asset;

    final assetToSave = AssetModel(
      id: _isEdit ? a!.id : '',
      userId: '',
      portfolioId: widget.portfolioId ?? (_isRealAsset ? a!.portfolioId : ''),
      name: _nameController.text.trim(),
      tickerSymbol: _symbolController.text.trim().toUpperCase(),
      category: _selectedCategory,
      totalQuantity: quantity,
      averageBuyPrice: buyPrice,
      currentPrice: _marketPrice > 0 ? _marketPrice : buyPrice,
    );

    final bloc = context.read<AssetBloc>();
    if (_isEdit) {
      bloc.add(UpdateAsset(assetToSave));
    } else {
      // Same ticker already held in the same goal (or unassigned) → add to it
      // with a weighted average price instead of creating a duplicate.
      final st = bloc.state;
      final existing = st is AssetLoaded
          ? AssetMath.findSameHolding(st.assets, assetToSave.tickerSymbol, assetToSave.portfolioId)
          : null;
      if (existing != null) {
        bloc.add(UpdateAsset(AssetMath.mergeBuy(
          existing,
          quantity: quantity,
          buyPrice: buyPrice,
          currentPrice: _marketPrice,
        )));
      } else {
        bloc.add(AddAsset(assetToSave));
      }
    }
    Navigator.pop(context, true);
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final mutedTextColor = theme.textTheme.bodySmall?.color;
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final fieldBg = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    final cs = context.watch<CurrencyCubit>().state;

    InputDecoration deco({String? hint, String? prefix, String? suffix}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: mutedTextColor?.withValues(alpha: 0.6)),
          prefixText: prefix,
          prefixStyle: TextStyle(color: mutedTextColor, fontWeight: FontWeight.w700, fontSize: 16),
          suffixText: suffix,
          suffixStyle: TextStyle(color: mutedTextColor, fontSize: 13),
          filled: true,
          fillColor: fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );

    final numberFormatter = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
    final showUseMarket = !_isEdit && _marketPrice > 0 && (_price - _marketPrice).abs() > 1e-9;

    return GlassContainer(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: mutedTextColor?.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEdit ? l10n.editHoldingTitle : l10n.recordBuyTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 16),

            // Asset identity
            if (!_needsIdentityFields)
              _identityCard(textColor, mutedTextColor, primaryColor, fieldBg, l10n)
            else ...[
              _label(l10n.assetNameLabel, textColor),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: deco(hint: l10n.whatIsItFor),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(l10n.symbolLabel, textColor),
                        TextField(
                          controller: _symbolController,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                          decoration: deco(hint: l10n.symbolHint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(l10n.categoryLabel, textColor),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                          decoration: deco(),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Quantity
            _label(l10n.quantity, textColor),
            TextField(
              controller: _quantityController,
              autofocus: !_isEdit,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: numberFormatter,
              onChanged: (_) => setState(_recalcTotal),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 20),
              decoration: deco(hint: l10n.quantityHint, suffix: l10n.unitsSuffix),
            ),
            const SizedBox(height: 16),

            // Price per unit
            Row(
              children: [
                Expanded(child: _label(_isEdit ? l10n.avgPricePerUnit : l10n.pricePerUnit, textColor)),
                if (showUseMarket)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() {
                        _priceController.text = _num(_marketPrice);
                        _recalcTotal();
                      }),
                      child: Text(
                        l10n.useMarketPrice,
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: numberFormatter,
              onChanged: (_) => setState(_recalcTotal),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 20),
              decoration: deco(hint: '0.00', prefix: '$_baseSymbol '),
            ),
            const SizedBox(height: 16),

            // Total (auto, editable)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.totalInvested, style: TextStyle(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  TextField(
                    controller: _totalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: numberFormatter,
                    onChanged: (_) => setState(_recalcQuantityFromTotal),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 24),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(color: mutedTextColor?.withValues(alpha: 0.5)),
                      prefixText: '$_baseSymbol ',
                      prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 24),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                  Text(
                    (cs.selectedCurrency != _baseCurrency && _total > 0)
                        ? '≈ ${CurrencyFormatter.format(_total, cs, fromCurrency: _baseCurrency)} · ${l10n.totalEditHint}'
                        : l10n.totalEditHint,
                    style: TextStyle(color: mutedTextColor, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _canSave ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.3),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.saveAsset,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _identityCard(Color? textColor, Color? mutedTextColor, Color primaryColor, Color fieldBg, AppLocalizations l10n) {
    final a = _asset!;
    final ticker = a.tickerSymbol.toUpperCase();
    final initials = (ticker.isNotEmpty ? ticker : a.name).substring(0, 1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text(ticker.isNotEmpty ? '$ticker · $_selectedCategory' : _selectedCategory,
                    style: TextStyle(color: mutedTextColor, fontSize: 12.5)),
              ],
            ),
          ),
          if (_marketPrice > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.marketPriceLabel, style: TextStyle(color: mutedTextColor, fontSize: 11)),
                const SizedBox(height: 2),
                Text('$_baseSymbol${_num(_marketPrice)}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _label(String text, Color? textColor) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
      );
}
