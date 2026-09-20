import 'package:fincontrol/features/wealth/presentation/pages/created_portfolio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/portfolio_repository.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';

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
  bool _setGoal = false;
  IconData _selectedIcon = Icons.monetization_on;
  List<AssetModel> _selectedAssets = [];
  bool _isSaving = false;

  late List<String> _suggestions;

  @override
  void initState() {
    super.initState();
    if (widget.existingPortfolio != null) {
      _nameController.text = widget.existingPortfolio!.name;
      _noteController.text = widget.existingPortfolio!.note;
      _selectedIcon = IconData(widget.existingPortfolio!.icon as int, fontFamily: 'MaterialIcons');
      if (widget.existingPortfolio!.targetGoal != null) {
        _setGoal = true;
        _goalController.text = widget.existingPortfolio!.targetGoal.toString();
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

  Future<void> _createGoalAndAssignAssets() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final goal = PortfolioModel(
        id: widget.existingPortfolio?.id ?? '',
        userId: widget.existingPortfolio?.userId ?? '',
        name: _nameController.text,
        icon: _selectedIcon.codePoint,
        note: _noteController.text,
        targetGoal: double.tryParse(_goalController.text),
        createdAt: widget.existingPortfolio?.createdAt ?? DateTime.now(),
      );

      if (widget.existingPortfolio != null) {
        // Update existing portfolio
        context.read<PortfolioBloc>().add(UpdatePortfolio(goal));
      } else {
        // Create new portfolio and get back the ID
        final newId = await PortfolioRepository().addPortfolio(goal);
        // Reload portfolios
        context.read<PortfolioBloc>().add(const LoadPortfolios(''));
        // Assign selected assets to the new portfolio
        if (_selectedAssets.isNotEmpty) {
          for (final asset in _selectedAssets) {
            context.read<AssetBloc>().add(
              UpdateAsset(asset.copyWith(portfolioId: newId)),
            );
          }
        }
        // Build the full portfolio model with the real ID to pass to detail page
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
            MaterialPageRoute(
              builder: (_) => CreatedPortfolio(portfolio: createdPortfolio),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CreatedPortfolio(portfolio: widget.existingPortfolio)),
        );
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return GlassContainer(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                  'Select Assets',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  'Choose unassigned assets to add to this goal',
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      asset.category,
                                      style: TextStyle(
                                        color: textColor?.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: primaryColor, size: 22),
                            ],
                          ),
                        ),
                      );
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
                    onPressed: () {
                      setState(() => _selectedAssets = List.from(tempSelected));
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

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    _suggestions = [
      AppLocalizations.of(context)!.passiveIncome,
      AppLocalizations.of(context)!.growthStocks,
      AppLocalizations.of(context)!.retireReady,
      AppLocalizations.of(context)!.saveGoal,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingPortfolio != null
              ? AppLocalizations.of(context)!.updateGoal
              : AppLocalizations.of(context)!.newGoal,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => _showIconPicker(context, textColor, primaryColor),
              child: Stack(
                children: [
                  GlassContainer(
                    width: 96,
                    height: 96,
                    borderRadius: BorderRadius.circular(48),
                    color: primaryColor.withValues(alpha: 0.2),
                    child: Center(
                      child: Icon(_selectedIcon, size: 40, color: primaryColor),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildInputField(
                  controller: _nameController,
                  hint: AppLocalizations.of(context)!.goalName,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, bottom: 24),
                  child: Text(
                    AppLocalizations.of(context)!.length25Characters(
                        _nameController.text.length.toString()),
                    style: TextStyle(color: mutedTextColor, fontSize: 12),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _suggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _nameController.text = suggestion),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            borderRadius: BorderRadius.circular(20),
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _setGoal = !_setGoal),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _setGoal ? primaryColor : Colors.transparent,
                          border: Border.all(
                            color: _setGoal ? primaryColor : (mutedTextColor ?? Colors.grey),
                            width: 2,
                          ),
                        ),
                        child: _setGoal
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.setTargetAmount,
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (_setGoal) ...[
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _goalController,
                    hint: AppLocalizations.of(context)!.enterTargetAmount,
                    prefixIcon: Icons.attach_money,
                    isNumber: true,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: mutedTextColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.note,
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  height: 100,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _noteController,
                    style: TextStyle(color: textColor, fontSize: 15),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Add an optional note...',
                      hintStyle: TextStyle(
                        color: mutedTextColor?.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Assign Assets',
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add existing unassigned assets, or create a new one from the market.',
                  style: TextStyle(color: mutedTextColor, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showSelectAssetsSheet(context),
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    color: primaryColor.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedAssets.isEmpty
                              ? 'Select Existing Assets'
                              : '${_selectedAssets.length} asset(s) selected',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: primaryColor, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InvestPage()),
                    );
                  },
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Browse Market & Create New',
                          style: TextStyle(
                            color: mutedTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Icon(Icons.open_in_new, color: mutedTextColor, size: 16),
                      ],
                    ),
                  ),
                ),
                if (_selectedAssets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedAssets.map((asset) {
                      return Chip(
                        label: Text(
                          asset.name,
                          style: TextStyle(color: primaryColor, fontSize: 13),
                        ),
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        deleteIcon: Icon(Icons.close, size: 16, color: primaryColor),
                        onDeleted: () {
                          setState(() => _selectedAssets.removeWhere((a) => a.id == asset.id));
                        },
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _createGoalAndAssignAssets,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.existingPortfolio != null ? 'Update Goal' : 'Create Goal',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    bool isNumber = false,
    required Color? textColor,
    required Color? mutedTextColor,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: mutedTextColor?.withValues(alpha: 0.5),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: mutedTextColor) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
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
                'Select Icon',
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
