import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';
import 'package:fincontrol/core/constants/app_categories.dart';
import 'package:fincontrol/core/services/gemini_service.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';

enum TransactionType { income, expense }

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? existingTransaction;

  /// Preselected type for a new transaction (Home "+ Income" / "− Expense").
  final TransactionType? initialType;
  const AddTransactionSheet({super.key, this.existingTransaction, this.initialType});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;

  final _noteController   = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate  = DateTime.now();
  String? _selectedCategory;

  List<String> _suggestions = [];
  bool _loadingSuggestions  = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
    if (widget.existingTransaction != null) {
      final t = widget.existingTransaction!;
      // Compare lowercase to avoid localization issues in initState
      _type = t.type.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense;
      _noteController.text = t.note;
      _amountController.text = t.amount.abs().toString();
      _selectedDate = t.date;
      _selectedCategory = t.category;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onSuggest() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    // extract number from note → pre-fill amount if empty, then strip number from note
    final amountMatch = RegExp(r'(\d+\.?\d*)').firstMatch(note);
    if (amountMatch != null && _amountController.text.isEmpty) {
      _amountController.text = amountMatch.group(1)!;
      final cleanedNote = note.replaceFirst(RegExp(r'\s*\d+\.?\d*\s*'), ' ').trim();
      _noteController.text = cleanedNote;
    }

    setState(() {
      _loadingSuggestions = true;
      _selectedCategory   = null;
      _suggestions        = [];
    });

    final results = await GeminiService.suggestCategories(
      note: note,
      isIncome: _type == TransactionType.income,
    );

    setState(() {
      _suggestions        = results;
      _loadingSuggestions = false;
    });
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    final note = _noteController.text.trim();
    final amountText = _amountController.text.trim();
    if (note.isEmpty || amountText.isEmpty || _selectedCategory == null) return;
    
    final amount = double.tryParse(amountText) ?? 0.0;
    
    final t = TransactionModel(
      id: widget.existingTransaction?.id ?? '',
      userId: '',
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      note: note,
      // Always store the English key — the translated label ("รายรับ") made
      // Thai-mode transactions invisible to every total and filter.
      type: _type == TransactionType.income ? 'Income' : 'Expense',
    );
    
    if (widget.existingTransaction == null) {
      context.read<TransactionBloc>().add(AddTransaction(t));
    } else {
      context.read<TransactionBloc>().add(UpdateTransaction(t));
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome    = _type == TransactionType.income;
    final accentColor = isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currencyState) {
        final currencySymbol = currencyState.selectedCurrency == 'THB' ? '฿  ' : '\$  ';
        
        return GlassContainer(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      borderRadius: const BorderRadius.only(
        topLeft:  Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existingTransaction == null ? AppLocalizations.of(context)!.addTransaction : AppLocalizations.of(context)!.editTransaction,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                IconButton(
                  icon: Icon(Icons.close, color: mutedTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Income / Expense toggle
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _TypeTab(
                    label: AppLocalizations.of(context)!.income, selected: isIncome, color: Colors.greenAccent.shade400,
                    onTap: () => setState(() {
                      _type = TransactionType.income;
                      _suggestions = []; _selectedCategory = null;
                    }),
                  ),
                  _TypeTab(
                    label: AppLocalizations.of(context)!.expense, selected: !isIncome, color: Colors.redAccent.shade400,
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _suggestions = []; _selectedCategory = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Note (first)
            _Label(AppLocalizations.of(context)!.note, mutedTextColor),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSuggest(),
              style: TextStyle(color: textColor),
              decoration: _inputDeco(AppLocalizations.of(context)!.noteLunchSalary, primaryColor, fieldBg, mutedTextColor),
            ),
            const SizedBox(height: 10),

            // AI Suggest button
            GestureDetector(
              onTap: _loadingSuggestions ? null : _onSuggest,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: _loadingSuggestions
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: _loadingSuggestions ? Colors.white12 : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _loadingSuggestions
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _loadingSuggestions ? AppLocalizations.of(context)!.suggestingAi : AppLocalizations.of(context)!.suggestCategoryAi,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Suggestion chips
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.aiSuggestionsLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutedTextColor)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _suggestions.map((s) {
                  final sel = _selectedCategory == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? primaryColor : fieldBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? primaryColor : (isDarkMode ? Colors.white24 : Colors.grey.shade300)),
                      ),
                      child: Text(AppCategories.localizedLabel(s, Localizations.localeOf(context).languageCode),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // AI disclaimer (Feedback #2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: mutedTextColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.aiCategoryDisclaimer,
                      style: TextStyle(fontSize: 11, color: mutedTextColor, height: 1.3)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Category dropdown
            _Label(AppLocalizations.of(context)!.category, mutedTextColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  dropdownColor: isDarkMode ? const Color(0xFF1E1B4B) : Colors.white,
                  hint: Text(AppLocalizations.of(context)!.selectCategory,
                    style: TextStyle(color: mutedTextColor, fontSize: 15)),
                  items: AppCategories.forType(isIncome).map((c) {
                    final langCode = Localizations.localeOf(context).languageCode;
                    return DropdownMenuItem(value: c.label, child: Text(AppCategories.localizedLabel(c.label, langCode), style: TextStyle(color: textColor)));}
                  ).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  iconEnabledColor: textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount (after note)
            _Label(AppLocalizations.of(context)!.amount, mutedTextColor),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              decoration: _inputDeco('0.00', primaryColor, fieldBg, mutedTextColor,
                prefix: Text(currencySymbol,
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _Label(AppLocalizations.of(context)!.whenDidItHappen, mutedTextColor),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(primaryColor),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: mutedTextColor),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _submit,
                child: Text(
                  isIncome ? AppLocalizations.of(context)!.saveIncome : AppLocalizations.of(context)!.saveExpense,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  InputDecoration _inputDeco(String hint, Color primaryColor, Color fieldBg, Color? mutedTextColor, {Widget? prefix, Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: mutedTextColor),
    prefix: prefix,
    suffix: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor, width: 1.5)),
    filled: true,
    fillColor: fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _TypeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeTab({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: selected ? color : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color? mutedTextColor;
  const _Label(this.text, this.mutedTextColor);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(
        color: mutedTextColor, fontSize: 14, fontWeight: FontWeight.bold,
      ),
    );
  }
}
