import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @accountNo.
  ///
  /// In en, this message translates to:
  /// **'Account No.'**
  String get accountNo;

  /// No description provided for @accountAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountAndSecurity;

  /// No description provided for @appLockPin.
  ///
  /// In en, this message translates to:
  /// **'App Lock PIN'**
  String get appLockPin;

  /// No description provided for @appLockPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Set or change your 6-digit PIN'**
  String get appLockPinDesc;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @changeBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change base currency'**
  String get changeBaseCurrency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect for low-light lovers'**
  String get darkModeDesc;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @getHelpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @readOurPolicies.
  ///
  /// In en, this message translates to:
  /// **'Read our policies'**
  String get readOurPolicies;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @invest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get invest;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @wealth.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get wealth;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @errorMsg.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMsg(String message);

  /// No description provided for @insight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insight;

  /// No description provided for @insightError.
  ///
  /// In en, this message translates to:
  /// **'Could not load insight at this time.'**
  String get insightError;

  /// No description provided for @insightEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for insights yet.'**
  String get insightEmpty;

  /// No description provided for @insightPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get insightPeriodDay;

  /// No description provided for @insightPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightPeriodWeek;

  /// No description provided for @insightPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightPeriodMonth;

  /// No description provided for @insightEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions today yet. Add one to get an insight.'**
  String get insightEmptyDay;

  /// No description provided for @insightEmptyWeek.
  ///
  /// In en, this message translates to:
  /// **'No transactions this week yet. Add one to get an insight.'**
  String get insightEmptyWeek;

  /// No description provided for @insightEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month yet. Add one to get an insight.'**
  String get insightEmptyMonth;

  /// No description provided for @insightIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get insightIncomeLabel;

  /// No description provided for @insightExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get insightExpenseLabel;

  /// No description provided for @insightVsYesterday.
  ///
  /// In en, this message translates to:
  /// **'vs yesterday'**
  String get insightVsYesterday;

  /// No description provided for @insightVsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get insightVsLastWeek;

  /// No description provided for @insightVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get insightVsLastMonth;

  /// No description provided for @insightRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get insightRetry;

  /// No description provided for @insightRefresh.
  ///
  /// In en, this message translates to:
  /// **'Get a new insight'**
  String get insightRefresh;

  /// No description provided for @aiSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions'**
  String get aiSuggestionsLabel;

  /// No description provided for @aiCategoryDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. Please check before saving.'**
  String get aiCategoryDisclaimer;

  /// No description provided for @aiInsightDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI-generated advice may not always be accurate.'**
  String get aiInsightDisclaimer;

  /// No description provided for @targetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a target amount greater than 0.'**
  String get targetAmountRequired;

  /// No description provided for @noTargetSet.
  ///
  /// In en, this message translates to:
  /// **'No target set — edit the goal to add one'**
  String get noTargetSet;

  /// No description provided for @recordBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a buy'**
  String get recordBuyTitle;

  /// No description provided for @editHoldingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit holding'**
  String get editHoldingTitle;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @avgPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Average price per unit'**
  String get avgPricePerUnit;

  /// No description provided for @marketPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Market price'**
  String get marketPriceLabel;

  /// No description provided for @totalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total invested'**
  String get totalInvested;

  /// No description provided for @totalEditHint.
  ///
  /// In en, this message translates to:
  /// **'You can also type a total — the quantity is calculated for you'**
  String get totalEditHint;

  /// No description provided for @useMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Use market price'**
  String get useMarketPrice;

  /// No description provided for @assetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset name'**
  String get assetNameLabel;

  /// No description provided for @unitsSuffix.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitsSuffix;

  /// No description provided for @addNav.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addNav;

  /// No description provided for @expenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record money you spent'**
  String get expenseSubtitle;

  /// No description provided for @incomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record money you received'**
  String get incomeSubtitle;

  /// No description provided for @investSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy stocks or crypto from the market'**
  String get investSubtitle;

  /// No description provided for @newGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a savings or investment goal'**
  String get newGoalSubtitle;

  /// No description provided for @addAssetManually.
  ///
  /// In en, this message translates to:
  /// **'Add an asset manually (not in the market)'**
  String get addAssetManually;

  /// No description provided for @trendTitle.
  ///
  /// In en, this message translates to:
  /// **'Income & expenses over time'**
  String get trendTitle;

  /// No description provided for @summaryTab.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTab;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @noTransactionsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get noTransactionsInPeriod;

  /// No description provided for @vsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs previous period'**
  String get vsPreviousPeriod;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @previousPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriodTooltip;

  /// No description provided for @nextPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriodTooltip;

  /// No description provided for @editTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change amount, category or date'**
  String get editTransactionSubtitle;

  /// No description provided for @deleteTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this transaction permanently'**
  String get deleteTransactionSubtitle;

  /// No description provided for @thisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This month ({month})'**
  String thisMonthLabel(String month);

  /// No description provided for @spentOfIncome.
  ///
  /// In en, this message translates to:
  /// **'Spent {percent}% of income'**
  String spentOfIncome(String percent);

  /// No description provided for @netThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Left this month'**
  String get netThisMonth;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get last7Days;

  /// No description provided for @spendingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spending this month'**
  String get spendingThisMonth;

  /// No description provided for @noSpendingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month yet'**
  String get noSpendingThisMonth;

  /// No description provided for @othersLabel.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get othersLabel;

  /// No description provided for @investmentPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Investment portfolio'**
  String get investmentPortfolio;

  /// No description provided for @startInvestingHint.
  ///
  /// In en, this message translates to:
  /// **'Track stocks and crypto toward your goals'**
  String get startInvestingHint;

  /// No description provided for @totalPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Total portfolio value'**
  String get totalPortfolioValue;

  /// No description provided for @totalGainLabel.
  ///
  /// In en, this message translates to:
  /// **'total gain'**
  String get totalGainLabel;

  /// No description provided for @totalLossLabel.
  ///
  /// In en, this message translates to:
  /// **'total loss'**
  String get totalLossLabel;

  /// No description provided for @costBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costBasisLabel;

  /// No description provided for @investAction.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get investAction;

  /// No description provided for @assetTypeStock.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get assetTypeStock;

  /// No description provided for @assetTypeCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get assetTypeCrypto;

  /// No description provided for @assetTypeEtf.
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get assetTypeEtf;

  /// No description provided for @assetTypeFund.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get assetTypeFund;

  /// No description provided for @assetTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get assetTypeOther;

  /// No description provided for @completedGoalsCount.
  ///
  /// In en, this message translates to:
  /// **'Completed goals ({count})'**
  String completedGoalsCount(String count);

  /// No description provided for @completedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedBadge;

  /// No description provided for @restoreGoal.
  ///
  /// In en, this message translates to:
  /// **'Move back to active'**
  String get restoreGoal;

  /// No description provided for @archiveGoal.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get archiveGoal;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal? Its assets are kept and moved to Unassigned.'**
  String get deleteGoalConfirm;

  /// No description provided for @goalAchievedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get goalAchievedTitle;

  /// No description provided for @goalAchievedBody.
  ///
  /// In en, this message translates to:
  /// **'You reached 100% of this goal. What would you like to do next?'**
  String get goalAchievedBody;

  /// No description provided for @keepActive.
  ///
  /// In en, this message translates to:
  /// **'Keep active'**
  String get keepActive;

  /// No description provided for @tapAssetForActions.
  ///
  /// In en, this message translates to:
  /// **'Tap an asset to buy more, sell or move it to a goal'**
  String get tapAssetForActions;

  /// No description provided for @wealthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your wealth'**
  String get wealthEmptyTitle;

  /// No description provided for @wealthEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first investment, then group investments into goals like a house or retirement.'**
  String get wealthEmptyBody;

  /// No description provided for @startInvesting.
  ///
  /// In en, this message translates to:
  /// **'Start investing'**
  String get startInvesting;

  /// No description provided for @goalsCount.
  ///
  /// In en, this message translates to:
  /// **'Goals ({count})'**
  String goalsCount(String count);

  /// No description provided for @buyMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Buy more'**
  String get buyMoreAction;

  /// No description provided for @buyMoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add units at a new price — the average is updated'**
  String get buyMoreSubtitle;

  /// No description provided for @sellAction.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellAction;

  /// No description provided for @sellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce the number of units you hold'**
  String get sellSubtitle;

  /// No description provided for @assignToGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Move to a goal'**
  String get assignToGoalAction;

  /// No description provided for @assignToGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Put this asset into one of your goals'**
  String get assignToGoalSubtitle;

  /// No description provided for @sellAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell all units?'**
  String get sellAllTitle;

  /// No description provided for @sellAllBody.
  ///
  /// In en, this message translates to:
  /// **'You are selling all of {name}. The holding will be removed from your portfolio.'**
  String sellAllBody(String name);

  /// No description provided for @sellAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sell all and remove'**
  String get sellAllConfirm;

  /// No description provided for @youHoldUnits.
  ///
  /// In en, this message translates to:
  /// **'You hold {quantity} units'**
  String youHoldUnits(String quantity);

  /// No description provided for @quantityToSell.
  ///
  /// In en, this message translates to:
  /// **'Quantity to sell'**
  String get quantityToSell;

  /// No description provided for @sellAllButton.
  ///
  /// In en, this message translates to:
  /// **'Sell all'**
  String get sellAllButton;

  /// No description provided for @sellTooMuch.
  ///
  /// In en, this message translates to:
  /// **'You only hold {quantity} units'**
  String sellTooMuch(String quantity);

  /// No description provided for @estimatedProceeds.
  ///
  /// In en, this message translates to:
  /// **'Estimated value at market price'**
  String get estimatedProceeds;

  /// No description provided for @remainingUnits.
  ///
  /// In en, this message translates to:
  /// **'{quantity} units left after selling'**
  String remainingUnits(String quantity);

  /// No description provided for @confirmSell.
  ///
  /// In en, this message translates to:
  /// **'Confirm sell'**
  String get confirmSell;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @assetsInThisGoal.
  ///
  /// In en, this message translates to:
  /// **'Assets in this goal'**
  String get assetsInThisGoal;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @buyNewFromMarket.
  ///
  /// In en, this message translates to:
  /// **'Buy from market'**
  String get buyNewFromMarket;

  /// No description provided for @assetRemovedFromGoal.
  ///
  /// In en, this message translates to:
  /// **'{name} moved to Unassigned'**
  String assetRemovedFromGoal(String name);

  /// No description provided for @deleteAssetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently? This cannot be undone.'**
  String deleteAssetConfirm(String name);

  /// No description provided for @percentOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of target'**
  String percentOfTarget(String percent);

  /// No description provided for @totalNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Total Net Worth'**
  String get totalNetWorth;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @financialGoals.
  ///
  /// In en, this message translates to:
  /// **'Financial Goals'**
  String get financialGoals;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. Create one!'**
  String get noGoalsYet;

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Completed'**
  String percentCompleted(String percent);

  /// No description provided for @assetPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Asset Portfolio'**
  String get assetPortfolio;

  /// No description provided for @noAssetsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No assets added yet.'**
  String get noAssetsAddedYet;

  /// No description provided for @sharesUnits.
  ///
  /// In en, this message translates to:
  /// **'{quantity} Shares/Units'**
  String sharesUnits(String quantity);

  /// No description provided for @activityDashboard.
  ///
  /// In en, this message translates to:
  /// **'Activity Dashboard'**
  String get activityDashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @spendingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Spending Breakdown'**
  String get spendingBreakdown;

  /// No description provided for @noTransactionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your criteria'**
  String get noTransactionsMatch;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @openPrice.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPrice;

  /// No description provided for @totalReturn.
  ///
  /// In en, this message translates to:
  /// **'Total Return'**
  String get totalReturn;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target:'**
  String get target;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @enterTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Target Amount'**
  String get enterTargetAmount;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @passiveIncome.
  ///
  /// In en, this message translates to:
  /// **'Passive Income'**
  String get passiveIncome;

  /// No description provided for @thaiStocks.
  ///
  /// In en, this message translates to:
  /// **'Thai Stocks'**
  String get thaiStocks;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @noAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No assets found'**
  String get noAssetsFound;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this goal'**
  String get optionalNotes;

  /// No description provided for @myPortfolio.
  ///
  /// In en, this message translates to:
  /// **'My Portfolio'**
  String get myPortfolio;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @setTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Set Target Amount'**
  String get setTargetAmount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Vol'**
  String get volume;

  /// No description provided for @retireReady.
  ///
  /// In en, this message translates to:
  /// **'Retire Ready'**
  String get retireReady;

  /// No description provided for @allocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get allocation;

  /// No description provided for @etfs.
  ///
  /// In en, this message translates to:
  /// **'ETFs'**
  String get etfs;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @buyAsset.
  ///
  /// In en, this message translates to:
  /// **'Buy Asset'**
  String get buyAsset;

  /// No description provided for @growthStocks.
  ///
  /// In en, this message translates to:
  /// **'Growth Stocks'**
  String get growthStocks;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocks;

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// No description provided for @defaultSort.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSort;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @keyStats.
  ///
  /// In en, this message translates to:
  /// **'Key Stats'**
  String get keyStats;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price (Low to High)'**
  String get priceLowToHigh;

  /// No description provided for @marketDataDelayed.
  ///
  /// In en, this message translates to:
  /// **'Market data is delayed by 15 minutes.'**
  String get marketDataDelayed;

  /// No description provided for @buyAction.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyAction;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @topMovers.
  ///
  /// In en, this message translates to:
  /// **'Top Movers'**
  String get topMovers;

  /// No description provided for @changeHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Change (High to Low)'**
  String get changeHighToLow;

  /// No description provided for @createPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Create Portfolio'**
  String get createPortfolio;

  /// No description provided for @changeLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Change (Low to High)'**
  String get changeLowToHigh;

  /// No description provided for @prevClose.
  ///
  /// In en, this message translates to:
  /// **'Prev Close'**
  String get prevClose;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price (High to Low)'**
  String get priceHighToLow;

  /// No description provided for @highPrice.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highPrice;

  /// No description provided for @marketCap.
  ///
  /// In en, this message translates to:
  /// **'Mkt Cap'**
  String get marketCap;

  /// No description provided for @lowPrice.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowPrice;

  /// No description provided for @searchAssets.
  ///
  /// In en, this message translates to:
  /// **'Search assets'**
  String get searchAssets;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveGoal;

  /// No description provided for @mutualFunds.
  ///
  /// In en, this message translates to:
  /// **'Mutual Funds'**
  String get mutualFunds;

  /// No description provided for @trackedMarket.
  ///
  /// In en, this message translates to:
  /// **'Tracked Market'**
  String get trackedMarket;

  /// No description provided for @spotlight.
  ///
  /// In en, this message translates to:
  /// **'Spotlight'**
  String get spotlight;

  /// No description provided for @length25Characters.
  ///
  /// In en, this message translates to:
  /// **'{length}/25 characters'**
  String length25Characters(String length);

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @whatWouldYouLikeToAdd.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get whatWouldYouLikeToAdd;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @updateGoal.
  ///
  /// In en, this message translates to:
  /// **'Update Goal'**
  String get updateGoal;

  /// No description provided for @cashFlowStatement.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Statement'**
  String get cashFlowStatement;

  /// No description provided for @cashInflows.
  ///
  /// In en, this message translates to:
  /// **'CASH INFLOWS'**
  String get cashInflows;

  /// No description provided for @cfActiveIncome.
  ///
  /// In en, this message translates to:
  /// **'Active Income'**
  String get cfActiveIncome;

  /// No description provided for @cfPassiveIncome.
  ///
  /// In en, this message translates to:
  /// **'Passive Income'**
  String get cfPassiveIncome;

  /// No description provided for @totalInflows.
  ///
  /// In en, this message translates to:
  /// **'Total Inflows'**
  String get totalInflows;

  /// No description provided for @cashOutflows.
  ///
  /// In en, this message translates to:
  /// **'CASH OUTFLOWS'**
  String get cashOutflows;

  /// No description provided for @cfSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving & Investment'**
  String get cfSaving;

  /// No description provided for @cfFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed Expenses'**
  String get cfFixed;

  /// No description provided for @cfInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get cfInstallment;

  /// No description provided for @cfVariable.
  ///
  /// In en, this message translates to:
  /// **'Variable Expenses'**
  String get cfVariable;

  /// No description provided for @totalOutflows.
  ///
  /// In en, this message translates to:
  /// **'Total Outflows'**
  String get totalOutflows;

  /// No description provided for @netCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Cash Flow'**
  String get netCashFlow;

  /// No description provided for @protectYourData.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Data'**
  String get protectYourData;

  /// No description provided for @pinSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Set up a 6-digit PIN to secure your financial data'**
  String get pinSetupDescription;

  /// No description provided for @setPinNow.
  ///
  /// In en, this message translates to:
  /// **'Set PIN Now'**
  String get setPinNow;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @pinSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PIN saved successfully'**
  String get pinSavedSuccessfully;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @appLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'App lock disabled'**
  String get appLockDisabled;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @enterPinToDisable.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to disable'**
  String get enterPinToDisable;

  /// No description provided for @disableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock'**
  String get disableAppLock;

  /// No description provided for @unassignedAssets.
  ///
  /// In en, this message translates to:
  /// **'Unassigned Assets'**
  String get unassignedAssets;

  /// No description provided for @longPressToAssign.
  ///
  /// In en, this message translates to:
  /// **'Long-press an asset to assign it to a goal'**
  String get longPressToAssign;

  /// No description provided for @noUnassignedAssets.
  ///
  /// In en, this message translates to:
  /// **'No unassigned assets'**
  String get noUnassignedAssets;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @suggestingAi.
  ///
  /// In en, this message translates to:
  /// **'Suggesting...'**
  String get suggestingAi;

  /// No description provided for @suggestCategoryAi.
  ///
  /// In en, this message translates to:
  /// **'Suggest category with AI'**
  String get suggestCategoryAi;

  /// No description provided for @whenDidItHappen.
  ///
  /// In en, this message translates to:
  /// **'When did it happen?'**
  String get whenDidItHappen;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @selectAssets.
  ///
  /// In en, this message translates to:
  /// **'Select Assets'**
  String get selectAssets;

  /// No description provided for @chooseAssetsForGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose unassigned assets to add to this goal'**
  String get chooseAssetsForGoal;

  /// No description provided for @addOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Add an optional note...'**
  String get addOptionalNote;

  /// No description provided for @assignAssets.
  ///
  /// In en, this message translates to:
  /// **'Assign Assets'**
  String get assignAssets;

  /// No description provided for @addExistingOrNewAsset.
  ///
  /// In en, this message translates to:
  /// **'Add existing unassigned assets, or create a new one from the market.'**
  String get addExistingOrNewAsset;

  /// No description provided for @selectExistingAssets.
  ///
  /// In en, this message translates to:
  /// **'Select Existing Assets'**
  String get selectExistingAssets;

  /// No description provided for @browseMarketCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Browse Market & Create New'**
  String get browseMarketCreateNew;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @browseMarketAddNew.
  ///
  /// In en, this message translates to:
  /// **'Browse market and add a new asset'**
  String get browseMarketAddNew;

  /// No description provided for @chooseOneOrMoreAssets.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more assets to add to this goal'**
  String get chooseOneOrMoreAssets;

  /// No description provided for @thisPortfolioEmpty.
  ///
  /// In en, this message translates to:
  /// **'This portfolio is currently empty'**
  String get thisPortfolioEmpty;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @removeFromGoal.
  ///
  /// In en, this message translates to:
  /// **'Remove from this goal'**
  String get removeFromGoal;

  /// No description provided for @removeFromGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Asset is NOT deleted — moves to Unassigned Assets'**
  String get removeFromGoalSubtitle;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @deletePermanentlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes this asset and all its data forever'**
  String get deletePermanentlySubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addAssetBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAssetBtn;

  /// No description provided for @changeQtyBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Change quantity or buy price'**
  String get changeQtyBuyPrice;

  /// No description provided for @whatIsItFor.
  ///
  /// In en, this message translates to:
  /// **'What is this for?'**
  String get whatIsItFor;

  /// No description provided for @symbolHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AAPL'**
  String get symbolHint;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1.5'**
  String get quantityHint;

  /// No description provided for @saveAsset.
  ///
  /// In en, this message translates to:
  /// **'Save Asset'**
  String get saveAsset;

  /// No description provided for @addAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAssetTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @symbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbolLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get pleaseFillAllFields;

  /// No description provided for @noteLunchSalary.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lunch, Salary...'**
  String get noteLunchSalary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
