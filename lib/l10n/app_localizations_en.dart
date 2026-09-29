// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get username => 'Username';

  @override
  String get accountNo => 'Account No.';

  @override
  String get accountAndSecurity => 'Account & Security';

  @override
  String get appLockPin => 'App Lock PIN';

  @override
  String get appLockPinDesc => 'Set or change your 6-digit PIN';

  @override
  String get preferences => 'Preferences';

  @override
  String get currency => 'Currency';

  @override
  String get changeBaseCurrency => 'Change base currency';

  @override
  String get language => 'Language';

  @override
  String get changeAppLanguage => 'Change app language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Perfect for low-light lovers';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get getHelpAndSupport => 'Get help and support';

  @override
  String get termsAndPrivacy => 'Terms & Privacy';

  @override
  String get readOurPolicies => 'Read our policies';

  @override
  String get logout => 'Logout';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get thai => 'Thai';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get invest => 'Invest';

  @override
  String get newGoal => 'New Goal';

  @override
  String get wealth => 'Wealth';

  @override
  String get activity => 'Activity';

  @override
  String get recent => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String errorMsg(String message) {
    return 'Error: $message';
  }

  @override
  String get insight => 'Insight';

  @override
  String get insightError => 'Could not load insight at this time.';

  @override
  String get insightEmpty => 'Not enough data for insights yet.';

  @override
  String get insightPeriodDay => 'Day';

  @override
  String get insightPeriodWeek => 'Week';

  @override
  String get insightPeriodMonth => 'Month';

  @override
  String get insightEmptyDay =>
      'No transactions today yet. Add one to get an insight.';

  @override
  String get insightEmptyWeek =>
      'No transactions this week yet. Add one to get an insight.';

  @override
  String get insightEmptyMonth =>
      'No transactions this month yet. Add one to get an insight.';

  @override
  String get insightIncomeLabel => 'Income';

  @override
  String get insightExpenseLabel => 'Expense';

  @override
  String get insightVsYesterday => 'vs yesterday';

  @override
  String get insightVsLastWeek => 'vs last week';

  @override
  String get insightVsLastMonth => 'vs last month';

  @override
  String get insightRetry => 'Try again';

  @override
  String get insightRefresh => 'Get a new insight';

  @override
  String get aiSuggestionsLabel => 'AI suggestions';

  @override
  String get aiCategoryDisclaimer =>
      'AI can make mistakes. Please check before saving.';

  @override
  String get aiInsightDisclaimer =>
      'AI-generated advice may not always be accurate.';

  @override
  String get targetAmountRequired =>
      'Please enter a target amount greater than 0.';

  @override
  String get noTargetSet => 'No target set — edit the goal to add one';

  @override
  String get recordBuyTitle => 'Record a buy';

  @override
  String get editHoldingTitle => 'Edit holding';

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get avgPricePerUnit => 'Average price per unit';

  @override
  String get marketPriceLabel => 'Market price';

  @override
  String get totalInvested => 'Total invested';

  @override
  String get totalEditHint =>
      'You can also type a total — the quantity is calculated for you';

  @override
  String get useMarketPrice => 'Use market price';

  @override
  String get assetNameLabel => 'Asset name';

  @override
  String get unitsSuffix => 'units';

  @override
  String get addNav => 'Add';

  @override
  String get expenseSubtitle => 'Record money you spent';

  @override
  String get incomeSubtitle => 'Record money you received';

  @override
  String get investSubtitle => 'Buy stocks or crypto from the market';

  @override
  String get newGoalSubtitle => 'Set a savings or investment goal';

  @override
  String get addAssetManually => 'Add an asset manually (not in the market)';

  @override
  String get trendTitle => 'Income & expenses over time';

  @override
  String get summaryTab => 'Summary';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get netLabel => 'Net';

  @override
  String get noTransactionsInPeriod => 'No transactions in this period';

  @override
  String get vsPreviousPeriod => 'vs previous period';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get previousPeriodTooltip => 'Previous period';

  @override
  String get nextPeriodTooltip => 'Next period';

  @override
  String get editTransactionSubtitle => 'Change amount, category or date';

  @override
  String get deleteTransactionSubtitle => 'Remove this transaction permanently';

  @override
  String thisMonthLabel(String month) {
    return 'This month ($month)';
  }

  @override
  String spentOfIncome(String percent) {
    return 'Spent $percent% of income';
  }

  @override
  String get netThisMonth => 'Left this month';

  @override
  String get last7Days => '7 days';

  @override
  String get spendingThisMonth => 'Spending this month';

  @override
  String get noSpendingThisMonth => 'No expenses this month yet';

  @override
  String get othersLabel => 'Others';

  @override
  String get investmentPortfolio => 'Investment portfolio';

  @override
  String get startInvestingHint => 'Track stocks and crypto toward your goals';

  @override
  String get totalPortfolioValue => 'Total portfolio value';

  @override
  String get totalGainLabel => 'total gain';

  @override
  String get totalLossLabel => 'total loss';

  @override
  String get costBasisLabel => 'Cost';

  @override
  String get investAction => 'Invest';

  @override
  String get assetTypeStock => 'Stocks';

  @override
  String get assetTypeCrypto => 'Crypto';

  @override
  String get assetTypeEtf => 'ETF';

  @override
  String get assetTypeFund => 'Funds';

  @override
  String get assetTypeOther => 'Other';

  @override
  String completedGoalsCount(String count) {
    return 'Completed goals ($count)';
  }

  @override
  String get completedBadge => 'Completed';

  @override
  String get restoreGoal => 'Move back to active';

  @override
  String get archiveGoal => 'Mark as completed';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get deleteGoalConfirm =>
      'Delete this goal? Its assets are kept and moved to Unassigned.';

  @override
  String get goalAchievedTitle => 'Goal achieved!';

  @override
  String get goalAchievedBody =>
      'You reached 100% of this goal. What would you like to do next?';

  @override
  String get keepActive => 'Keep active';

  @override
  String get tapAssetForActions =>
      'Tap an asset to buy more, sell or move it to a goal';

  @override
  String get wealthEmptyTitle => 'Start building your wealth';

  @override
  String get wealthEmptyBody =>
      'Add your first investment, then group investments into goals like a house or retirement.';

  @override
  String get startInvesting => 'Start investing';

  @override
  String goalsCount(String count) {
    return 'Goals ($count)';
  }

  @override
  String get buyMoreAction => 'Buy more';

  @override
  String get buyMoreSubtitle =>
      'Add units at a new price — the average is updated';

  @override
  String get sellAction => 'Sell';

  @override
  String get sellSubtitle => 'Reduce the number of units you hold';

  @override
  String get assignToGoalAction => 'Move to a goal';

  @override
  String get assignToGoalSubtitle => 'Put this asset into one of your goals';

  @override
  String get sellAllTitle => 'Sell all units?';

  @override
  String sellAllBody(String name) {
    return 'You are selling all of $name. The holding will be removed from your portfolio.';
  }

  @override
  String get sellAllConfirm => 'Sell all and remove';

  @override
  String youHoldUnits(String quantity) {
    return 'You hold $quantity units';
  }

  @override
  String get quantityToSell => 'Quantity to sell';

  @override
  String get sellAllButton => 'Sell all';

  @override
  String sellTooMuch(String quantity) {
    return 'You only hold $quantity units';
  }

  @override
  String get estimatedProceeds => 'Estimated value at market price';

  @override
  String remainingUnits(String quantity) {
    return '$quantity units left after selling';
  }

  @override
  String get confirmSell => 'Confirm sell';

  @override
  String get targetLabel => 'Target';

  @override
  String get undoAction => 'Undo';

  @override
  String get deleteAction => 'Delete';

  @override
  String get assetsInThisGoal => 'Assets in this goal';

  @override
  String get totalLabel => 'Total';

  @override
  String get buyNewFromMarket => 'Buy from market';

  @override
  String assetRemovedFromGoal(String name) {
    return '$name moved to Unassigned';
  }

  @override
  String deleteAssetConfirm(String name) {
    return 'Delete \"$name\" permanently? This cannot be undone.';
  }

  @override
  String percentOfTarget(String percent) {
    return '$percent% of target';
  }

  @override
  String get totalNetWorth => 'Total Net Worth';

  @override
  String get assets => 'Assets';

  @override
  String get liabilities => 'Liabilities';

  @override
  String get notAvailable => 'N/A';

  @override
  String get financialGoals => 'Financial Goals';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get noGoalsYet => 'No goals yet. Create one!';

  @override
  String percentCompleted(String percent) {
    return '$percent% Completed';
  }

  @override
  String get assetPortfolio => 'Asset Portfolio';

  @override
  String get noAssetsAddedYet => 'No assets added yet.';

  @override
  String sharesUnits(String quantity) {
    return '$quantity Shares/Units';
  }

  @override
  String get activityDashboard => 'Activity Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get all => 'All';

  @override
  String get expense => 'Expense';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get spendingBreakdown => 'Spending Breakdown';

  @override
  String get noTransactionsMatch => 'No transactions match your criteria';

  @override
  String get today => 'Today';

  @override
  String get openPrice => 'Open';

  @override
  String get totalReturn => 'Total Return';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get target => 'Target:';

  @override
  String get sortBy => 'Sort By';

  @override
  String get category => 'Category';

  @override
  String get enterTargetAmount => 'Enter Target Amount';

  @override
  String get totalValue => 'Total Value';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get passiveIncome => 'Passive Income';

  @override
  String get thaiStocks => 'Thai Stocks';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get noAssetsFound => 'No assets found';

  @override
  String get amount => 'Amount';

  @override
  String get optionalNotes => 'Optional notes about this goal';

  @override
  String get myPortfolio => 'My Portfolio';

  @override
  String get quantity => 'Quantity';

  @override
  String get setTargetAmount => 'Set Target Amount';

  @override
  String get selectCategory => 'Select category';

  @override
  String get volume => 'Vol';

  @override
  String get retireReady => 'Retire Ready';

  @override
  String get allocation => 'Allocation';

  @override
  String get etfs => 'ETFs';

  @override
  String get note => 'Note';

  @override
  String get buyAsset => 'Buy Asset';

  @override
  String get growthStocks => 'Growth Stocks';

  @override
  String get stocks => 'Stocks';

  @override
  String get crypto => 'Crypto';

  @override
  String get defaultSort => 'Default';

  @override
  String get goalName => 'Goal Name';

  @override
  String get keyStats => 'Key Stats';

  @override
  String get priceLowToHigh => 'Price (Low to High)';

  @override
  String get marketDataDelayed => 'Market data is delayed by 15 minutes.';

  @override
  String get buyAction => 'Buy';

  @override
  String get date => 'Date';

  @override
  String get topMovers => 'Top Movers';

  @override
  String get changeHighToLow => 'Change (High to Low)';

  @override
  String get createPortfolio => 'Create Portfolio';

  @override
  String get changeLowToHigh => 'Change (Low to High)';

  @override
  String get prevClose => 'Prev Close';

  @override
  String get priceHighToLow => 'Price (High to Low)';

  @override
  String get highPrice => 'High';

  @override
  String get marketCap => 'Mkt Cap';

  @override
  String get lowPrice => 'Low';

  @override
  String get searchAssets => 'Search assets';

  @override
  String get saveGoal => 'Save';

  @override
  String get mutualFunds => 'Mutual Funds';

  @override
  String get trackedMarket => 'Tracked Market';

  @override
  String get spotlight => 'Spotlight';

  @override
  String length25Characters(String length) {
    return '$length/25 characters';
  }

  @override
  String get submit => 'Submit';

  @override
  String get whatWouldYouLikeToAdd => 'What would you like to add?';

  @override
  String get transaction => 'Transaction';

  @override
  String get asset => 'Asset';

  @override
  String get goal => 'Goal';

  @override
  String get home => 'Home';

  @override
  String get updateGoal => 'Update Goal';

  @override
  String get cashFlowStatement => 'Cash Flow Statement';

  @override
  String get cashInflows => 'CASH INFLOWS';

  @override
  String get cfActiveIncome => 'Active Income';

  @override
  String get cfPassiveIncome => 'Passive Income';

  @override
  String get totalInflows => 'Total Inflows';

  @override
  String get cashOutflows => 'CASH OUTFLOWS';

  @override
  String get cfSaving => 'Saving & Investment';

  @override
  String get cfFixed => 'Fixed Expenses';

  @override
  String get cfInstallment => 'Installments';

  @override
  String get cfVariable => 'Variable Expenses';

  @override
  String get totalOutflows => 'Total Outflows';

  @override
  String get netCashFlow => 'Net Cash Flow';

  @override
  String get protectYourData => 'Protect Your Data';

  @override
  String get pinSetupDescription =>
      'Set up a 6-digit PIN to secure your financial data';

  @override
  String get setPinNow => 'Set PIN Now';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get pinSavedSuccessfully => 'PIN saved successfully';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get appLockDisabled => 'App lock disabled';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPin => 'Enter new PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get enterPinToDisable => 'Enter PIN to disable';

  @override
  String get disableAppLock => 'Disable App Lock';

  @override
  String get unassignedAssets => 'Unassigned Assets';

  @override
  String get longPressToAssign => 'Long-press an asset to assign it to a goal';

  @override
  String get noUnassignedAssets => 'No unassigned assets';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get suggestingAi => 'Suggesting...';

  @override
  String get suggestCategoryAi => 'Suggest category with AI';

  @override
  String get whenDidItHappen => 'When did it happen?';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get selectAssets => 'Select Assets';

  @override
  String get chooseAssetsForGoal =>
      'Choose unassigned assets to add to this goal';

  @override
  String get addOptionalNote => 'Add an optional note...';

  @override
  String get assignAssets => 'Assign Assets';

  @override
  String get addExistingOrNewAsset =>
      'Add existing unassigned assets, or create a new one from the market.';

  @override
  String get selectExistingAssets => 'Select Existing Assets';

  @override
  String get browseMarketCreateNew => 'Browse Market & Create New';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get browseMarketAddNew => 'Browse market and add a new asset';

  @override
  String get chooseOneOrMoreAssets =>
      'Choose one or more assets to add to this goal';

  @override
  String get thisPortfolioEmpty => 'This portfolio is currently empty';

  @override
  String get editAction => 'Edit';

  @override
  String get removeFromGoal => 'Remove from this goal';

  @override
  String get removeFromGoalSubtitle =>
      'Asset is NOT deleted — moves to Unassigned Assets';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get deletePermanentlySubtitle =>
      'Removes this asset and all its data forever';

  @override
  String get cancel => 'Cancel';

  @override
  String get addAssetBtn => 'Add Asset';

  @override
  String get changeQtyBuyPrice => 'Change quantity or buy price';

  @override
  String get whatIsItFor => 'What is this for?';

  @override
  String get symbolHint => 'e.g. AAPL';

  @override
  String get quantityHint => 'e.g. 1.5';

  @override
  String get saveAsset => 'Save Asset';

  @override
  String get addAssetTitle => 'Add Asset';

  @override
  String get categoryLabel => 'Category';

  @override
  String get amountLabel => 'Amount';

  @override
  String get symbolLabel => 'Symbol';

  @override
  String get dateLabel => 'Date';

  @override
  String get pleaseFillAllFields => 'Please fill all fields correctly';

  @override
  String get noteLunchSalary => 'e.g. Lunch, Salary...';
}
