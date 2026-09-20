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

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

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

  /// No description provided for @sellAction.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellAction;

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
