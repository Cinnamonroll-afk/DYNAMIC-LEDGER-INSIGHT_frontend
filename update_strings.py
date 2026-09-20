import os

def replace_in_file(filepath, replacements):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    for old, new in replacements:
        content = content.replace(old, new)
        
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
    else:
        print(f"No changes in {filepath}")

# invest_page.dart
replace_in_file('lib/view/wealth/invest_page.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'Invest'", "AppLocalizations.of(context)!.invest"),
    ("hintText: 'Search assets'", "hintText: AppLocalizations.of(context)!.searchAssets"),
    ("'Spotlight'", "AppLocalizations.of(context)!.spotlight"),
    ("'Top Movers'", "AppLocalizations.of(context)!.topMovers"),
    ("'Sort By'", "AppLocalizations.of(context)!.sortBy"),
    ("'No assets found'", "AppLocalizations.of(context)!.noAssetsFound"),
    ("String _selectedSort = 'Default';", "String _selectedSort = 'Default';"), # We'll handle sort state via internal keys, display via localized. 
    # Let's fix the sort sheet text instead
    ("'Default'", "AppLocalizations.of(context)!.defaultSort"),
    ("'Price (High to Low)'", "AppLocalizations.of(context)!.priceHighToLow"),
    ("'Price (Low to High)'", "AppLocalizations.of(context)!.priceLowToHigh"),
    ("'Change (High to Low)'", "AppLocalizations.of(context)!.changeHighToLow"),
    ("'Change (Low to High)'", "AppLocalizations.of(context)!.changeLowToHigh"),
    # Categories
    ("_buildCategoryButton('Stocks'", "_buildCategoryButton('Stocks', AppLocalizations.of(context)!.stocks"),
    ("_buildCategoryButton('Crypto'", "_buildCategoryButton('Crypto', AppLocalizations.of(context)!.crypto"),
    ("_buildCategoryButton('ETFs'", "_buildCategoryButton('ETFs', AppLocalizations.of(context)!.etfs"),
    ("_buildCategoryButton('Mutual Funds'", "_buildCategoryButton('Mutual Funds', AppLocalizations.of(context)!.mutualFunds"),
    ("_buildCategoryButton('Thai Stocks'", "_buildCategoryButton('Thai Stocks', AppLocalizations.of(context)!.thaiStocks"),
    ("Widget _buildCategoryButton(String title, Color primaryColor, Color? textColor, Color? mutedTextColor) {", "Widget _buildCategoryButton(String title, String localizedTitle, Color primaryColor, Color? textColor, Color? mutedTextColor) {"),
    ("Text(\n        title", "Text(\n        localizedTitle"),
    ("Text(title", "Text(localizedTitle"),
])

# create_new_portfolio.dart
replace_in_file('lib/view/wealth/create_new_portfolio.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'New Goal'", "AppLocalizations.of(context)!.newGoal"),
    ("hint: 'Goal Name'", "hint: AppLocalizations.of(context)!.goalName"),
    ("'${_nameController.text.length}/25 characters'", "AppLocalizations.of(context)!.length25Characters(_nameController.text.length.toString())"),
    # Suggestions
    ("'Passive Income'", "AppLocalizations.of(context)!.passiveIncome"),
    ("'Growth Stocks'", "AppLocalizations.of(context)!.growthStocks"),
    ("'Retire Ready'", "AppLocalizations.of(context)!.retireReady"),
    ("'Save'", "AppLocalizations.of(context)!.saveGoal"),
    ("'Set Target Amount'", "AppLocalizations.of(context)!.setTargetAmount"),
    ("hint: 'Enter Target Amount'", "hint: AppLocalizations.of(context)!.enterTargetAmount"),
    ("'Note'", "AppLocalizations.of(context)!.note"),
    ("hintText: 'Optional notes about this goal'", "hintText: AppLocalizations.of(context)!.optionalNotes"),
    ("'Create Portfolio'", "AppLocalizations.of(context)!.createPortfolio"),
])

# created_portfolio.dart
replace_in_file('lib/view/wealth/created_portfolio.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'My Portfolio'", "AppLocalizations.of(context)!.myPortfolio"),
    ("'Total Balance'", "AppLocalizations.of(context)!.totalBalance"),
    ("'Total Return'", "AppLocalizations.of(context)!.totalReturn"),
    ("'Target: ${", "AppLocalizations.of(context)!.target + ' ${"),
    ("'Buy Asset'", "AppLocalizations.of(context)!.buyAsset"),
    ("'Allocation'", "AppLocalizations.of(context)!.allocation"),
    ("'Assets'", "AppLocalizations.of(context)!.assets"),
    ("'No assets yet. Add your first investment!'", "AppLocalizations.of(context)!.noAssetsAddedYet"),
    ("import 'package:fincontrol/l10n/app_localizations.dart';\nimport '../../bloc/asset/asset_bloc.dart';", "import '../../bloc/asset/asset_bloc.dart';"), # remove duplicate just in case
])

# asset_detail_page.dart
replace_in_file('lib/view/wealth/asset_detail_page.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'Tracked Market'", "AppLocalizations.of(context)!.trackedMarket"),
    ("'Today'", "AppLocalizations.of(context)!.today"),
    ("'Key Stats'", "AppLocalizations.of(context)!.keyStats"),
    ("'Open'", "AppLocalizations.of(context)!.openPrice"),
    ("'High'", "AppLocalizations.of(context)!.highPrice"),
    ("'Low'", "AppLocalizations.of(context)!.lowPrice"),
    ("'Prev Close'", "AppLocalizations.of(context)!.prevClose"),
    ("'Vol'", "AppLocalizations.of(context)!.volume"),
    ("'Mkt Cap'", "AppLocalizations.of(context)!.marketCap"),
    ("'Market data is delayed by 15 minutes.'", "AppLocalizations.of(context)!.marketDataDelayed"),
    # Fix shares units formatting if present
])

# add_entry_sheet.dart
replace_in_file('lib/view/wealth/add_entry_sheet.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'Add Entry'", "AppLocalizations.of(context)!.addEntry"),
    ("'Buy'", "AppLocalizations.of(context)!.buyAction"),
    ("'Sell'", "AppLocalizations.of(context)!.sellAction"),
    ("'Date & Time'", "AppLocalizations.of(context)!.dateTime"),
    ("'Quantity'", "AppLocalizations.of(context)!.quantity"),
    ("'Price per unit'", "AppLocalizations.of(context)!.pricePerUnit"),
    ("'Total Value'", "AppLocalizations.of(context)!.totalValue"),
    ("'Submit'", "AppLocalizations.of(context)!.submit"),
])

# add_transaction_sheet.dart
replace_in_file('lib/view/navigationbar/add_transaction_sheet.dart', [
    ("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:fincontrol/l10n/app_localizations.dart';"),
    ("'Add Transaction'", "AppLocalizations.of(context)!.addTransaction"),
    ("'Income'", "AppLocalizations.of(context)!.income"),
    ("'Expense'", "AppLocalizations.of(context)!.expense"),
    ("'Amount'", "AppLocalizations.of(context)!.amount"),
    ("'Category'", "AppLocalizations.of(context)!.category"),
    ("'Date'", "AppLocalizations.of(context)!.date"),
    ("hintText: 'Select category'", "hintText: AppLocalizations.of(context)!.selectCategory"),
    ("'Please enter amount'", "AppLocalizations.of(context)!.pleaseEnterAmount"),
])
