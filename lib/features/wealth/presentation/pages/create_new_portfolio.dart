import 'package:fincontrol/features/wealth/presentation/pages/created_portfolio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/portfolio_repository.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/asset_pick_details.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/goal_actions.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';

class CreatePortfolioPage extends StatefulWidget {
  final PortfolioModel? existingPortfolio;

  const CreatePortfolioPage({super.key, this.existingPortfolio});

  @override
  State<CreatePortfolioPage> createState() => _CreatePortfolioPageState();
}

class _CreatePortfolioPageState extends State<CreatePortfolioPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String? _targetError; // target amount is required (Feedback #4)
  IconData _selectedIcon = Icons.monetization_on;
  List<AssetModel> _selectedAssets = [];
  /// Partial quantity chosen per selected asset (absent = the whole holding).
  final Map<String, double> _moveQty = {};
  Set<String> _originalAssetIds = {}; // edit mode: assets already in the goal
  bool _isSaving = false;

  late List<String> _suggestions;

  @override
  void initState() {
    super.initState();
    if (widget.existingPortfolio != null) {
      _nameController.text = widget.existingPortfolio!.name;
      _noteController.text = widget.existingPortfolio!.note;
      _selectedIcon = IconData(widget.existingPortfolio!.icon as int, fontFamily: 'MaterialIcons');
      // Target is stored in USD → show it in the user's currency
      final t = widget.existingPortfolio!.targetGoal;
      if (t != null && t > 0) {
        _goalController.text = _plain(_usdToDisplay(t, context.read<CurrencyCubit>().state));
      }
      // Show the assets already in this goal (removing one moves it to Unassigned)
      final st = context.read<AssetBloc>().state;
      if (st is AssetLoaded) {
        _selectedAssets = st.assets.where((a) => a.portfolioId == widget.existingPortfolio!.id).toList();
        _originalAssetIds = _selectedAssets.map((a) => a.id).toSet();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  /// Latest version of each selected asset from the bloc (the copies kept in
  /// [_selectedAssets] may be stale, e.g. after a merge added more units).
  List<AssetModel> _latestSelected() {
    final st = context.read<AssetBloc>().state;
    if (st is! AssetLoaded) return _selectedAssets;
    return _selectedAssets.map((sel) {
      for (final a in st.assets) {
        if (a.id == sel.id) return a;
      }
      return sel;
    }).toList();
  }

  /// A selected asset as it will be in the goal (only the chosen quantity).
  AssetModel _inGoal(AssetModel a) {
    final q = _moveQty[a.id];
    return (q != null && q < a.totalQuantity - 1e-9) ? a.copyWith(totalQuantity: q) : a;
  }

  /// Moves the selected assets into the goal — partially where a quantity
  /// was chosen, whole otherwise.
  void _assign(AssetBloc bloc, List<AssetModel> assets, String goalId) {
    final full = <AssetModel>[];
    for (final a in assets) {
      final q = _moveQty[a.id];
      if (q != null && q < a.totalQuantity - 1e-9) {
        moveQuantityToGoal(bloc, a, q, goalId);
      } else {
        full.add(a);
      }
    }
    if (full.isNotEmpty) moveAssetsToGoal(bloc, full, goalId);
  }

  Future<void> _createGoalAndAssignAssets() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseFillAllFields)));
      return;
    }
    final target = double.tryParse(_goalController.text.replaceAll(',', '').trim());
    if (target == null || target <= 0) {
      setState(() => _targetError = l10n.targetAmountRequired);
      return;
    }
    setState(() {
      _targetError = null;
      _isSaving = true;
    });
    try {
      final goal = PortfolioModel(
        id: widget.existingPortfolio?.id ?? '',
        userId: widget.existingPortfolio?.userId ?? '',
        name: _nameController.text.trim(),
        icon: _selectedIcon.codePoint,
        note: _noteController.text,
        targetGoal: _displayToUsd(target, context.read<CurrencyCubit>().state),
        createdAt: widget.existingPortfolio?.createdAt ?? DateTime.now(),
      );
      final assetBloc = context.read<AssetBloc>();
      final toAssign = _latestSelected();

      if (widget.existingPortfolio != null) {
        // Update the goal; add newly selected assets; removed ones → Unassigned
        context.read<PortfolioBloc>().add(UpdatePortfolio(goal));
        final keptIds = toAssign.map((a) => a.id).toSet();
        final st = assetBloc.state;
        final removed = st is AssetLoaded
            ? st.assets.where((a) => _originalAssetIds.contains(a.id) && !keptIds.contains(a.id)).toList()
            : <AssetModel>[];
        if (removed.isNotEmpty) moveAssetsToGoal(assetBloc, removed, '');
        _assign(assetBloc, toAssign, goal.id);
        if (mounted) Navigator.pop(context, goal); // back to where edit was opened
        return;
      } else {
        // Create new goal and get back the ID
        final newId = await PortfolioRepository().addPortfolio(goal);
        if (!mounted) return;
        context.read<PortfolioBloc>().add(const LoadPortfolios(''));
        _assign(assetBloc, toAssign, newId);
        final createdPortfolio = PortfolioModel(
          id: newId,
          userId: goal.userId,
          name: goal.name,
          icon: goal.icon,
          note: goal.note,
          targetGoal: goal.targetGoal,
          createdAt: goal.createdAt,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CreatedPortfolio(portfolio: createdPortfolio)),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// After "Browse Market & Create New" returns, pre-select the asset(s) the
  /// user just bought so they don't have to pick them again (Feedback #4).
  Future<void> _selectNewlyAddedAssets(AssetBloc bloc, Map<String, double> before) async {
    bool isNew(AssetModel a) =>
        a.portfolioId.isEmpty && (!before.containsKey(a.id) || before[a.id] != a.totalQuantity);
    bool hasNew(AssetState s) => s is AssetLoaded && s.assets.any(isNew);

    AssetState state = bloc.state;
    if (!hasNew(state)) {
      try {
        state = await bloc.stream.firstWhere(hasNew).timeout(const Duration(seconds: 8));
      } catch (_) {
        return; // nothing bought, or the server was slow — user can still pick manually
      }
    }
    if (!mounted || state is! AssetLoaded) return;
    final added = state.assets.where(isNew).toList();
    setState(() {
      for (final a in added) {
        _selectedAssets.removeWhere((x) => x.id == a.id);
        _selectedAssets.add(a);
      }
    });
  }

  void _showSelectAssetsSheet(BuildContext context) {
    final assetState = context.read<AssetBloc>().state;
    final allAssets = assetState is AssetLoaded ? assetState.assets : <AssetModel>[];
    final orphans = allAssets.where((a) => a.portfolioId.isEmpty).toList();

    if (orphans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unassigned assets available')),
      );
      return;
    }

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // temp selection state inside sheet
    final tempSelected = List<AssetModel>.from(_selectedAssets);
    final qtyCtrls = <String, TextEditingController>{};
    TextEditingController ctrlFor(AssetModel a) => qtyCtrls.putIfAbsent(
        a.id, () => TextEditingController(text: AssetMath.formatQuantity(_moveQty[a.id] ?? a.totalQuantity)));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final invalid = PickQuantityField.anyInvalid(tempSelected, qtyCtrls);
          return GlassContainer(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.selectAssets,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  AppLocalizations.of(context)!.chooseAssetsForGoal,
                  style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orphans.length,
                    itemBuilder: (_, i) {
                      final asset = orphans[i];
                      final isSelected = tempSelected.any((a) => a.id == asset.id);
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                      GestureDetector(
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
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.15)
                                : textColor?.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    asset.tickerSymbol.isNotEmpty
                                        ? asset.tickerSymbol[0]
                                        : asset.name[0],
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AssetPickDetails(asset: asset, textColor: textColor),
                              if (isSelected)
                                Icon(Icons.check_circle, color: primaryColor, size: 22),
                            ],
                          ),
                        ),
                      ),
                      if (isSelected)
                        PickQuantityField(
                          controller: ctrlFor(asset),
                          held: asset.totalQuantity,
                          onChanged: () => setSheetState(() {}),
                        ),
                      ]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: invalid ? null : () {
                      setState(() {
                        _selectedAssets = List.from(tempSelected);
                        _moveQty.removeWhere((id, _) => !tempSelected.any((a) => a.id == id));
                        for (final a in tempSelected) {
                          final c = qtyCtrls[a.id];
                          if (c == null) continue;
                          final q = PickQuantityField.parse(c, a.totalQuantity);
                          if (q != null && q < a.totalQuantity - 1e-9) {
                            _moveQty[a.id] = q;
                          } else {
                            _moveQty.remove(a.id);
                          }
                        }
                      });
                      Navigator.pop(sheetCtx);
                    },
                    child: Text(
                      'Confirm (${tempSelected.length} selected)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Currency helpers: targets are stored in USD, entered in the user's currency
  double _usdToDisplay(double usd, CurrencyState cs) =>
      CurrencyFormatter.convert(usd, cs, fromCurrency: 'USD');
  double _displayToUsd(double v, CurrencyState cs) =>
      (cs.selectedCurrency == 'THB' && cs.usdToThbRate > 0) ? v / cs.usdToThbRate : v;

  double get _parsedTarget => double.tryParse(_goalController.text.replaceAll(',', '').trim()) ?? 0;

  static String _plain(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final mutedTextColor = theme.textTheme.bodySmall?.color;
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final fieldBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7);
    final cs = context.watch<CurrencyCubit>().state;

    _suggestions = [l10n.passiveIncome, l10n.growthStocks, l10n.retireReady, l10n.saveGoal];

    // Latest data for the selected assets
    final assetState = context.watch<AssetBloc>().state;
    final allAssets = assetState is AssetLoaded ? assetState.assets : <AssetModel>[];
    final selected = _latestSelected();
    final unassignedCount = allAssets
        .where((a) => a.portfolioId.isEmpty && !selected.any((s) => s.id == a.id))
        .length;
    final selectedTotal = selected.fold<double>(0, (s, a) => s + AssetMath.marketValue(_inGoal(a), cs));
    final target = _parsedTarget;
    final progress = target > 0 ? (selectedTotal / target).clamp(0.0, 1.0) : 0.0;

    InputDecoration deco(String hint, {String? prefix}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: mutedTextColor?.withValues(alpha: 0.6), fontWeight: FontWeight.normal),
          prefixText: prefix,
          prefixStyle: TextStyle(color: mutedTextColor, fontWeight: FontWeight.w700, fontSize: 16),
          filled: true,
          fillColor: fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );

    Widget sectionTitle(String text, {String? trailing}) => Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              if (trailing != null) Text(trailing, style: TextStyle(color: mutedTextColor, fontSize: 12.5)),
            ],
          ),
        );

    Widget card({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: (textColor ?? Colors.grey).withValues(alpha: 0.08)),
          ),
          child: child,
        );

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)])
            : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
          title: Text(
            widget.existingPortfolio != null ? l10n.updateGoal : l10n.newGoal,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    // ── 1. Goal: icon + name + suggestions
                    card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showIconPicker(context, textColor, primaryColor),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                                      child: Icon(_selectedIcon, color: primaryColor, size: 28),
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                        child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
                                  decoration: deco(l10n.goalName),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestions
                                .map((sug) => ActionChip(
                                      label: Text(sug, style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      backgroundColor: fieldBg,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      onPressed: () => setState(() => _nameController.text = sug),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 2. Target (required) + note
                    sectionTitle('${l10n.setTargetAmount} *'),
                    TextField(
                      controller: _goalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() => _targetError = null),
                      style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800),
                      decoration: deco(l10n.enterTargetAmount, prefix: '${cs.symbol} ').copyWith(errorText: _targetError),
                    ),
                    const SizedBox(height: 16),
                    sectionTitle(l10n.note),
                    TextField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: deco(l10n.addOptionalNote),
                    ),
                    const SizedBox(height: 24),

                    // ── 3. Assets in this goal
                    sectionTitle(l10n.assetsInThisGoal, trailing: selected.isEmpty ? null : '${selected.length}'),
                    if (selected.isEmpty)
                      card(
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, color: mutedTextColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(l10n.addExistingOrNewAsset,
                                  style: TextStyle(color: mutedTextColor, fontSize: 13, height: 1.4)),
                            ),
                          ],
                        ),
                      )
                    else
                      card(
                        padding: const EdgeInsets.fromLTRB(14, 6, 6, 14),
                        child: Column(
                          children: [
                            for (final a in selected) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                                      child: Text(
                                        (a.tickerSymbol.isNotEmpty ? a.tickerSymbol : a.name).substring(0, 1).toUpperCase(),
                                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    AssetPickDetails(asset: _inGoal(a), textColor: textColor),
                                    IconButton(
                                      tooltip: l10n.removeFromGoal,
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(Icons.close, size: 18, color: mutedTextColor),
                                      onPressed: () => setState(() {
                                        _selectedAssets.removeWhere((x) => x.id == a.id);
                                        _moveQty.remove(a.id);
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Divider(color: (textColor ?? Colors.grey).withValues(alpha: 0.1), height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(l10n.totalLabel, style: TextStyle(color: mutedTextColor, fontSize: 13)),
                                      const Spacer(),
                                      Text(
                                        CurrencyFormatter.format(selectedTotal, cs, fromCurrency: cs.selectedCurrency),
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  if (target > 0) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        backgroundColor: primaryColor.withValues(alpha: 0.12),
                                        valueColor: AlwaysStoppedAnimation(primaryColor),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        l10n.percentOfTarget((progress * 100).toStringAsFixed(0)),
                                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSelectAssetsSheet(context),
                            icon: const Icon(Icons.playlist_add_check, size: 18),
                            label: Text('${l10n.selectExistingAssets} ($unassignedCount)',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _buyNewFromMarket,
                            icon: const Icon(Icons.add_chart, size: 18),
                            label: Text(l10n.buyNewFromMarket, maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Sticky save button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isSaving ? null : _createGoalAndAssignAssets,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.existingPortfolio != null ? l10n.updateGoal : l10n.createGoal,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buy from the market, then come back here with the new asset pre-selected.
  Future<void> _buyNewFromMarket() async {
    final assetBloc = context.read<AssetBloc>();
    final st = assetBloc.state;
    final before = <String, double>{
      if (st is AssetLoaded)
        for (final a in st.assets) a.id: a.totalQuantity,
    };
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestPage()));
    if (!mounted) return;
    await _selectNewlyAddedAssets(assetBloc, before);
  }

  void _showIconPicker(BuildContext context, Color? textColor, Color primaryColor) {
    final icons = [
      Icons.monetization_on, Icons.house, Icons.directions_car, Icons.savings,
      Icons.account_balance, Icons.trending_up, Icons.shopping_bag, Icons.flight,
      Icons.school, Icons.favorite,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.selectIcon,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIcon == icons[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIcon = icons[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : (textColor?.withValues(alpha: 0.1) ?? Colors.grey),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icons[index],
                        color: isSelected ? primaryColor : textColor?.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
