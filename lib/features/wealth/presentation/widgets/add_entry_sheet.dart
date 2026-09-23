import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';

class AddEntrySheet extends StatefulWidget {
  final AssetModel? asset;
  final String? portfolioId;
  
  const AddEntrySheet({super.key, this.asset, this.portfolioId});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Stock';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _symbolController.text = widget.asset!.tickerSymbol;
      _noteController.text = widget.asset!.name;
      if (widget.asset!.averageBuyPrice > 0) _amountController.text = widget.asset!.averageBuyPrice.toString();
      if (widget.asset!.totalQuantity > 0) _quantityController.text = widget.asset!.totalQuantity.toString();
      String initialCategory = widget.asset!.category;
      if (initialCategory == 'Stocks') initialCategory = 'Stock';
      if (initialCategory == 'ETFs') initialCategory = 'ETF';
      if (!['Stock', 'Crypto', 'ETF', 'Mutual Fund', 'Other'].contains(initialCategory)) {
        initialCategory = 'Other';
      }
      _selectedCategory = initialCategory;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(Color primaryColor) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light().copyWith(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEntry() {
    final name = _noteController.text.trim();
    final symbol = _symbolController.text.trim();
    double quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    
    double buyPrice = amount;
    if (quantity > 0 && amount > 0) {
      // If user provided both, we treat Amount as total investment and find price per unit.
      // But if they just typed it and the auto-calc ran, buyPrice = amount / quantity will be exactly currentPrice.
      buyPrice = amount / quantity;
    } else if (quantity <= 0 && amount > 0 && widget.asset != null && widget.asset!.currentPrice > 0) {
      quantity = amount / widget.asset!.currentPrice;
      buyPrice = widget.asset!.currentPrice;
    }

    if (name.isEmpty || quantity <= 0 || buyPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
      );
      return;
    }

    // Set user to dummy since backend infers it
    bool isNew = widget.asset == null || widget.asset!.id.isEmpty || widget.asset!.id.startsWith('mock_');
    final assetToSave = AssetModel(
      id: isNew ? '' : widget.asset!.id,
      userId: '',
      portfolioId: widget.portfolioId ?? (widget.asset != null && !widget.asset!.id.startsWith('mock_') ? widget.asset!.portfolioId : ''),
      name: name,
      tickerSymbol: symbol.toUpperCase(),
      category: _selectedCategory,
      totalQuantity: quantity,
      averageBuyPrice: buyPrice,
      currentPrice: widget.asset?.currentPrice ?? buyPrice,
    );

    if (isNew) {
      context.read<AssetBloc>().add(AddAsset(assetToSave));
    } else {
      context.read<AssetBloc>().add(UpdateAsset(assetToSave));
    }
    
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final fieldBg = isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return GlassContainer(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 24),
            
            Text(
              AppLocalizations.of(context)!.addAssetTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildLabel(AppLocalizations.of(context)!.categoryLabel, textColor),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              icon: Icon(Icons.keyboard_arrow_down, color: textColor),
              dropdownColor: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: fieldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w600),
              items: ['Stock', 'Crypto', 'ETF', 'Mutual Fund', 'Other']
                  .map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            _buildLabel(AppLocalizations.of(context)!.note, textColor),
            TextField(
              controller: _noteController,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.whatIsItFor,
                hintStyle: TextStyle(color: mutedTextColor),
                prefixIcon: Icon(Icons.notes, color: mutedTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: fieldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildLabel(AppLocalizations.of(context)!.amountLabel, textColor),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) {
                final amount = double.tryParse(val.trim()) ?? 0.0;
                if (amount > 0 && widget.asset != null && widget.asset!.currentPrice > 0) {
                  final qty = amount / widget.asset!.currentPrice;
                  _quantityController.text = qty.toStringAsFixed(6);
                } else if (amount == 0) {
                  _quantityController.text = '';
                }
              },
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: mutedTextColor),
                prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: fieldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(AppLocalizations.of(context)!.symbolLabel, textColor),
                      TextField(
                        controller: _symbolController,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.symbolHint,
                          hintStyle: TextStyle(color: mutedTextColor),
                          prefixIcon: Icon(Icons.tag, color: mutedTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(AppLocalizations.of(context)!.quantity, textColor),
                      TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.quantityHint,
                          hintStyle: TextStyle(color: mutedTextColor),
                          prefixIcon: Icon(Icons.numbers, color: mutedTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildLabel(AppLocalizations.of(context)!.dateLabel, textColor),
            InkWell(
              onTap: () => _pickDate(primaryColor),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.saveAsset,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

