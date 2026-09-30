// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get username => 'ชื่อผู้ใช้';

  @override
  String get accountNo => 'เลขที่บัญชี';

  @override
  String get accountAndSecurity => 'บัญชีและความปลอดภัย';

  @override
  String get appLockPin => 'รหัสผ่านแอป';

  @override
  String get appLockPinDesc => 'ตั้งค่าหรือเปลี่ยนรหัส PIN 6 หลักของคุณ';

  @override
  String get preferences => 'การตั้งค่า';

  @override
  String get currency => 'สกุลเงิน';

  @override
  String get changeBaseCurrency => 'เปลี่ยนสกุลเงินหลัก';

  @override
  String get language => 'ภาษา';

  @override
  String get changeAppLanguage => 'เปลี่ยนภาษาของแอป';

  @override
  String get darkMode => 'โหมดกลางคืน';

  @override
  String get darkModeDesc => 'เหมาะสำหรับคนชอบแสงน้อย';

  @override
  String get support => 'สนับสนุน';

  @override
  String get helpCenter => 'ศูนย์ช่วยเหลือ';

  @override
  String get getHelpAndSupport => 'รับความช่วยเหลือและการสนับสนุน';

  @override
  String get termsAndPrivacy => 'ข้อกำหนดและความเป็นส่วนตัว';

  @override
  String get readOurPolicies => 'อ่านนโยบายของเรา';

  @override
  String get logout => 'ออกจากระบบ';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get english => 'English';

  @override
  String get thai => 'ไทย';

  @override
  String get goodMorning => 'สวัสดีตอนเช้า,';

  @override
  String get goodAfternoon => 'สวัสดีตอนบ่าย,';

  @override
  String get goodEvening => 'สวัสดีตอนเย็น,';

  @override
  String get totalBalance => 'ยอดเงินคงเหลือ';

  @override
  String get income => 'รายรับ';

  @override
  String get expenses => 'รายจ่าย';

  @override
  String get invest => 'ลงทุน';

  @override
  String get newGoal => 'เป้าหมายใหม่';

  @override
  String get wealth => 'ความมั่งคั่ง';

  @override
  String get activity => 'กิจกรรม';

  @override
  String get recent => 'ล่าสุด';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get noTransactionsYet => 'ยังไม่มีธุรกรรม';

  @override
  String errorMsg(String message) {
    return 'ข้อผิดพลาด: $message';
  }

  @override
  String get insight => 'ข้อมูลเชิงลึก';

  @override
  String get insightError => 'ไม่สามารถโหลดข้อมูลเชิงลึกได้ในขณะนี้';

  @override
  String get insightEmpty => 'ข้อมูลยังไม่เพียงพอสำหรับข้อมูลเชิงลึก';

  @override
  String get insightPeriodDay => 'วัน';

  @override
  String get insightPeriodWeek => 'สัปดาห์';

  @override
  String get insightPeriodMonth => 'เดือน';

  @override
  String get insightEmptyDay =>
      'วันนี้ยังไม่มีรายการ เพิ่มรายการเพื่อรับคำแนะนำ';

  @override
  String get insightEmptyWeek =>
      'สัปดาห์นี้ยังไม่มีรายการ เพิ่มรายการเพื่อรับคำแนะนำ';

  @override
  String get insightEmptyMonth =>
      'เดือนนี้ยังไม่มีรายการ เพิ่มรายการเพื่อรับคำแนะนำ';

  @override
  String get insightIncomeLabel => 'รายรับ';

  @override
  String get insightExpenseLabel => 'รายจ่าย';

  @override
  String get insightVsYesterday => 'จากเมื่อวาน';

  @override
  String get insightVsLastWeek => 'จากสัปดาห์ก่อน';

  @override
  String get insightVsLastMonth => 'จากเดือนก่อน';

  @override
  String get insightRetry => 'ลองใหม่';

  @override
  String get insightRefresh => 'ขอคำแนะนำใหม่';

  @override
  String get aiSuggestionsLabel => 'หมวดที่ AI แนะนำ';

  @override
  String get aiCategoryDisclaimer =>
      'AI อาจแนะนำผิดพลาดได้ โปรดตรวจสอบก่อนบันทึก';

  @override
  String get aiInsightDisclaimer => 'คำแนะนำจาก AI อาจไม่ถูกต้องเสมอไป';

  @override
  String get targetAmountRequired => 'กรุณาใส่จำนวนเงินเป้าหมายที่มากกว่า 0';

  @override
  String get noTargetSet => 'ยังไม่ได้ตั้งเป้าหมาย — แก้ไขเป้าหมายเพื่อเพิ่ม';

  @override
  String get recordBuyTitle => 'บันทึกการซื้อ';

  @override
  String get editHoldingTitle => 'แก้ไขการถือครอง';

  @override
  String get pricePerUnit => 'ราคาต่อหน่วย';

  @override
  String get avgPricePerUnit => 'ราคาเฉลี่ยต่อหน่วย';

  @override
  String get marketPriceLabel => 'ราคาตลาด';

  @override
  String get totalInvested => 'ยอดลงทุนรวม';

  @override
  String get totalEditHint => 'พิมพ์ยอดรวมแทนได้ แอปจะคำนวณจำนวนให้';

  @override
  String get useMarketPrice => 'ใช้ราคาตลาด';

  @override
  String get assetNameLabel => 'ชื่อสินทรัพย์';

  @override
  String get unitsSuffix => 'หน่วย';

  @override
  String get addNav => 'เพิ่ม';

  @override
  String get expenseSubtitle => 'บันทึกค่าใช้จ่าย';

  @override
  String get incomeSubtitle => 'บันทึกเงินเข้า';

  @override
  String get investSubtitle => 'ซื้อหุ้นหรือคริปโตจากตลาด';

  @override
  String get newGoalSubtitle => 'ตั้งเป้าหมายการออมหรือการลงทุน';

  @override
  String get addAssetManually => 'เพิ่มสินทรัพย์เอง (ไม่มีในตลาด)';

  @override
  String get trendTitle => 'รายรับ-รายจ่ายตามช่วงเวลา';

  @override
  String get summaryTab => 'สรุป';

  @override
  String get todayLabel => 'วันนี้';

  @override
  String get yesterdayLabel => 'เมื่อวาน';

  @override
  String get netLabel => 'คงเหลือ';

  @override
  String get noTransactionsInPeriod => 'ไม่มีรายการในช่วงนี้';

  @override
  String get vsPreviousPeriod => 'เทียบกับช่วงก่อนหน้า';

  @override
  String get transactionDeleted => 'ลบรายการแล้ว';

  @override
  String get previousPeriodTooltip => 'ช่วงก่อนหน้า';

  @override
  String get nextPeriodTooltip => 'ช่วงถัดไป';

  @override
  String get editTransactionSubtitle => 'แก้จำนวนเงิน หมวด หรือวันที่';

  @override
  String get deleteTransactionSubtitle => 'ลบรายการนี้ถาวร';

  @override
  String thisMonthLabel(String month) {
    return 'เดือนนี้ ($month)';
  }

  @override
  String spentOfIncome(String percent) {
    return 'ใช้ไป $percent% ของรายรับ';
  }

  @override
  String get netThisMonth => 'คงเหลือเดือนนี้';

  @override
  String get last7Days => '7 วัน';

  @override
  String get spendingThisMonth => 'ใช้จ่ายเดือนนี้';

  @override
  String get noSpendingThisMonth => 'เดือนนี้ยังไม่มีรายจ่าย';

  @override
  String get othersLabel => 'อื่นๆ';

  @override
  String get investmentPortfolio => 'พอร์ตลงทุน';

  @override
  String get startInvestingHint => 'ติดตามหุ้นและคริปโตเพื่อไปถึงเป้าหมาย';

  @override
  String get totalPortfolioValue => 'มูลค่าพอร์ตทั้งหมด';

  @override
  String get totalGainLabel => 'กำไรทั้งหมด';

  @override
  String get totalLossLabel => 'ขาดทุนทั้งหมด';

  @override
  String get costBasisLabel => 'ต้นทุน';

  @override
  String get investAction => 'ลงทุน';

  @override
  String get assetTypeStock => 'หุ้น';

  @override
  String get assetTypeCrypto => 'คริปโต';

  @override
  String get assetTypeEtf => 'ETF';

  @override
  String get assetTypeFund => 'กองทุน';

  @override
  String get assetTypeOther => 'อื่นๆ';

  @override
  String completedGoalsCount(String count) {
    return 'เป้าหมายที่สำเร็จแล้ว ($count)';
  }

  @override
  String get completedBadge => 'สำเร็จแล้ว';

  @override
  String get restoreGoal => 'ย้ายกลับไปเป้าหมายที่ใช้งาน';

  @override
  String get archiveGoal => 'ย้ายไปเป้าหมายที่สำเร็จแล้ว';

  @override
  String get deleteGoal => 'ลบเป้าหมาย';

  @override
  String get deleteGoalConfirm =>
      'ลบเป้าหมายนี้หรือไม่? สินทรัพย์ในเป้าหมายจะไม่ถูกลบ แต่ย้ายไปที่ยังไม่ได้จัดกลุ่ม';

  @override
  String get goalAchievedTitle => 'บรรลุเป้าหมายแล้ว!';

  @override
  String get goalAchievedBody =>
      'คุณทำได้ครบ 100% ของเป้าหมายนี้แล้ว ต้องการทำอะไรต่อ?';

  @override
  String get keepActive => 'ใช้งานต่อ';

  @override
  String get tapAssetForActions =>
      'แตะสินทรัพย์เพื่อซื้อเพิ่ม ขาย หรือย้ายเข้าเป้าหมาย';

  @override
  String get wealthEmptyTitle => 'เริ่มสร้างความมั่งคั่งของคุณ';

  @override
  String get wealthEmptyBody =>
      'เพิ่มการลงทุนแรกของคุณ แล้วจัดกลุ่มเป็นเป้าหมาย เช่น ซื้อบ้าน หรือเกษียณ';

  @override
  String get startInvesting => 'เริ่มลงทุน';

  @override
  String goalsCount(String count) {
    return 'เป้าหมาย ($count)';
  }

  @override
  String get buyMoreAction => 'ซื้อเพิ่ม';

  @override
  String get buyMoreSubtitle => 'เพิ่มจำนวนที่ราคาใหม่ ระบบคำนวณราคาเฉลี่ยให้';

  @override
  String get sellAction => 'ขาย';

  @override
  String get sellSubtitle => 'ลดจำนวนหน่วยที่ถืออยู่';

  @override
  String get assignToGoalAction => 'ย้ายเข้าเป้าหมาย';

  @override
  String get assignToGoalSubtitle => 'นำสินทรัพย์นี้เข้าเป้าหมายของคุณ';

  @override
  String get sellAllTitle => 'ขายทั้งหมด?';

  @override
  String sellAllBody(String name) {
    return 'คุณกำลังขาย $name ทั้งหมด รายการนี้จะถูกนำออกจากพอร์ต';
  }

  @override
  String get sellAllConfirm => 'ขายทั้งหมดและนำออก';

  @override
  String youHoldUnits(String quantity) {
    return 'คุณถืออยู่ $quantity หน่วย';
  }

  @override
  String get quantityToSell => 'จำนวนที่ขาย';

  @override
  String get sellAllButton => 'ขายทั้งหมด';

  @override
  String sellTooMuch(String quantity) {
    return 'คุณถืออยู่เพียง $quantity หน่วย';
  }

  @override
  String get estimatedProceeds => 'มูลค่าโดยประมาณตามราคาตลาด';

  @override
  String remainingUnits(String quantity) {
    return 'เหลือ $quantity หน่วยหลังขาย';
  }

  @override
  String get confirmSell => 'ยืนยันการขาย';

  @override
  String get targetLabel => 'เป้าหมาย';

  @override
  String get undoAction => 'เลิกทำ';

  @override
  String get deleteAction => 'ลบ';

  @override
  String get assetsInThisGoal => 'สินทรัพย์ในเป้าหมายนี้';

  @override
  String get totalLabel => 'รวม';

  @override
  String get buyNewFromMarket => 'ซื้อใหม่จากตลาด';

  @override
  String assetRemovedFromGoal(String name) {
    return 'ย้าย $name ไปที่ยังไม่ได้จัดกลุ่มแล้ว';
  }

  @override
  String deleteAssetConfirm(String name) {
    return 'ลบ \"$name\" ถาวรหรือไม่? ไม่สามารถกู้คืนได้';
  }

  @override
  String percentOfTarget(String percent) {
    return '$percent% ของเป้าหมาย';
  }

  @override
  String get totalNetWorth => 'ความมั่งคั่งสุทธิ';

  @override
  String get assets => 'สินทรัพย์';

  @override
  String get liabilities => 'หนี้สิน';

  @override
  String get notAvailable => 'ไม่มีข้อมูล';

  @override
  String get financialGoals => 'เป้าหมายการเงิน';

  @override
  String get addGoal => 'เพิ่มเป้าหมาย';

  @override
  String get noGoalsYet => 'ยังไม่มีเป้าหมาย สร้างเลย!';

  @override
  String percentCompleted(String percent) {
    return 'เสร็จสิ้น $percent%';
  }

  @override
  String get assetPortfolio => 'พอร์ตสินทรัพย์';

  @override
  String get noAssetsAddedYet => 'ยังไม่มีสินทรัพย์';

  @override
  String sharesUnits(String quantity) {
    return '$quantity หุ้น/หน่วย';
  }

  @override
  String get activityDashboard => 'แดชบอร์ดกิจกรรม';

  @override
  String get transactions => 'ธุรกรรม';

  @override
  String get searchTransactions => 'ค้นหาธุรกรรม...';

  @override
  String get all => 'ทั้งหมด';

  @override
  String get expense => 'รายจ่าย';

  @override
  String get day => 'วัน';

  @override
  String get week => 'สัปดาห์';

  @override
  String get month => 'เดือน';

  @override
  String get year => 'ปี';

  @override
  String get cashFlow => 'กระแสเงินสด';

  @override
  String get spendingBreakdown => 'สัดส่วนรายจ่าย';

  @override
  String get noTransactionsMatch => 'ไม่มีธุรกรรมที่ตรงกับเงื่อนไข';

  @override
  String get today => 'วันนี้';

  @override
  String get openPrice => 'เปิด';

  @override
  String get totalReturn => 'ผลตอบแทนรวม';

  @override
  String get dateTime => 'วันและเวลา';

  @override
  String get target => 'เป้าหมาย:';

  @override
  String get sortBy => 'เรียงตาม';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get enterTargetAmount => 'ใส่จำนวนเงินเป้าหมาย';

  @override
  String get totalValue => 'มูลค่ารวม';

  @override
  String get addTransaction => 'เพิ่มธุรกรรม';

  @override
  String get passiveIncome => 'สร้างรายได้ทางอ้อม';

  @override
  String get thaiStocks => 'หุ้นไทย';

  @override
  String get pleaseEnterAmount => 'กรุณาใส่จำนวนเงิน';

  @override
  String get addEntry => 'เพิ่มรายการ';

  @override
  String get noAssetsFound => 'ไม่พบสินทรัพย์';

  @override
  String get amount => 'จำนวนเงิน';

  @override
  String get optionalNotes => 'บันทึกเพิ่มเติมเกี่ยวกับเป้าหมายนี้';

  @override
  String get myPortfolio => 'พอร์ตโฟลิโอของฉัน';

  @override
  String get quantity => 'จำนวน';

  @override
  String get setTargetAmount => 'ตั้งเป้าหมายจำนวนเงิน';

  @override
  String get selectCategory => 'เลือกหมวดหมู่';

  @override
  String get volume => 'ปริมาณซื้อขาย';

  @override
  String get retireReady => 'เตรียมเกษียณ';

  @override
  String get allocation => 'สัดส่วนการลงทุน';

  @override
  String get etfs => 'กองทุน ETF';

  @override
  String get note => 'บันทึก';

  @override
  String get buyAsset => 'ซื้อสินทรัพย์';

  @override
  String get growthStocks => 'หุ้นเติบโต';

  @override
  String get stocks => 'หุ้น';

  @override
  String get crypto => 'คริปโต';

  @override
  String get defaultSort => 'ค่าเริ่มต้น';

  @override
  String get goalName => 'ชื่อเป้าหมาย';

  @override
  String get keyStats => 'สถิติสำคัญ';

  @override
  String get priceLowToHigh => 'ราคา (ต่ำไปสูง)';

  @override
  String get marketDataDelayed => 'ข้อมูลตลาดล่าช้า 15 นาที';

  @override
  String get buyAction => 'ซื้อ';

  @override
  String get date => 'วันที่';

  @override
  String get topMovers => 'เปลี่ยนแปลงสูงสุด';

  @override
  String get changeHighToLow => 'การเปลี่ยนแปลง (สูงไปต่ำ)';

  @override
  String get createPortfolio => 'สร้างพอร์ตโฟลิโอ';

  @override
  String get changeLowToHigh => 'การเปลี่ยนแปลง (ต่ำไปสูง)';

  @override
  String get prevClose => 'ปิดก่อนหน้า';

  @override
  String get priceHighToLow => 'ราคา (สูงไปต่ำ)';

  @override
  String get highPrice => 'สูงสุด';

  @override
  String get marketCap => 'มูลค่าตลาด';

  @override
  String get lowPrice => 'ต่ำสุด';

  @override
  String get searchAssets => 'ค้นหาสินทรัพย์';

  @override
  String get saveGoal => 'ออมเงิน';

  @override
  String get mutualFunds => 'กองทุนรวม';

  @override
  String get trackedMarket => 'ตลาดที่ติดตาม';

  @override
  String get spotlight => 'น่าสนใจ';

  @override
  String length25Characters(String length) {
    return '$length/25 ตัวอักษร';
  }

  @override
  String get submit => 'ยืนยัน';

  @override
  String get whatWouldYouLikeToAdd => 'คุณต้องการเพิ่มอะไร?';

  @override
  String get transaction => 'ธุรกรรม';

  @override
  String get asset => 'สินทรัพย์';

  @override
  String get goal => 'เป้าหมาย';

  @override
  String get home => 'หน้าหลัก';

  @override
  String get updateGoal => 'อัปเดตเป้าหมาย';

  @override
  String get cashFlowStatement => 'งบกระแสเงินสด';

  @override
  String get cashInflows => 'เงินสดรับ';

  @override
  String get cfActiveIncome => 'รายได้หลัก';

  @override
  String get cfPassiveIncome => 'รายได้ทางอ้อม';

  @override
  String get totalInflows => 'รายรับรวม';

  @override
  String get cashOutflows => 'เงินสดจ่าย';

  @override
  String get cfSaving => 'ออมและลงทุน';

  @override
  String get cfFixed => 'ค่าใช้จ่ายคงที่';

  @override
  String get cfInstallment => 'ผ่อนชำระ';

  @override
  String get cfVariable => 'ค่าใช้จ่ายผันแปร';

  @override
  String get totalOutflows => 'รายจ่ายรวม';

  @override
  String get netCashFlow => 'กระแสเงินสดสุทธิ';

  @override
  String get protectYourData => 'ปกป้องข้อมูลของคุณ';

  @override
  String get pinSetupDescription =>
      'ตั้งรหัส PIN 6 หลักเพื่อรักษาความปลอดภัยข้อมูลการเงินของคุณ';

  @override
  String get setPinNow => 'ตั้งรหัส PIN ทันที';

  @override
  String get skipForNow => 'ข้ามไปก่อน';

  @override
  String get incorrectPin => 'รหัส PIN ไม่ถูกต้อง';

  @override
  String get pinSavedSuccessfully => 'บันทึกรหัส PIN สำเร็จ';

  @override
  String get pinsDoNotMatch => 'รหัส PIN ไม่ตรงกัน';

  @override
  String get appLockDisabled => 'ปิดการล็อกแอปแล้ว';

  @override
  String get enterCurrentPin => 'ใส่รหัส PIN ปัจจุบัน';

  @override
  String get enterNewPin => 'ใส่รหัส PIN ใหม่';

  @override
  String get confirmNewPin => 'ยืนยันรหัส PIN ใหม่';

  @override
  String get enterPinToDisable => 'ใส่รหัส PIN เพื่อปิดการใช้งาน';

  @override
  String get disableAppLock => 'ปิดการล็อกแอป';

  @override
  String get unassignedAssets => 'สินทรัพย์ที่ยังไม่ได้จัดกลุ่ม';

  @override
  String get longPressToAssign => 'กดค้างที่สินทรัพย์เพื่อเพิ่มเข้าเป้าหมาย';

  @override
  String get noUnassignedAssets => 'ไม่มีสินทรัพย์ที่ยังไม่ได้จัดกลุ่ม';

  @override
  String get editTransaction => 'แก้ไขธุรกรรม';

  @override
  String get suggestingAi => 'กำลังแนะนำ...';

  @override
  String get suggestCategoryAi => 'แนะนำหมวดหมู่ด้วย AI';

  @override
  String get whenDidItHappen => 'เกิดขึ้นเมื่อไหร่?';

  @override
  String get saveIncome => 'บันทึกรายรับ';

  @override
  String get saveExpense => 'บันทึกรายจ่าย';

  @override
  String get selectAssets => 'เลือกสินทรัพย์';

  @override
  String get chooseAssetsForGoal =>
      'เลือกสินทรัพย์ที่ยังไม่ได้จัดกลุ่มเพื่อเพิ่มเข้าเป้าหมาย';

  @override
  String get addOptionalNote => 'เพิ่มหมายเหตุ (ถ้ามี)...';

  @override
  String get assignAssets => 'จัดกลุ่มสินทรัพย์';

  @override
  String get addExistingOrNewAsset =>
      'เพิ่มสินทรัพย์ที่มีอยู่แล้ว หรือสร้างใหม่จากตลาด';

  @override
  String get selectExistingAssets => 'เลือกสินทรัพย์ที่มีอยู่';

  @override
  String get browseMarketCreateNew => 'เลือกจากตลาดและสร้างใหม่';

  @override
  String get createGoal => 'สร้างเป้าหมาย';

  @override
  String get selectIcon => 'เลือกไอคอน';

  @override
  String get browseMarketAddNew => 'เลือกจากตลาดและเพิ่มสินทรัพย์ใหม่';

  @override
  String get chooseOneOrMoreAssets =>
      'เลือกสินทรัพย์อย่างน้อยหนึ่งรายการเพื่อเพิ่มเข้าเป้าหมาย';

  @override
  String get thisPortfolioEmpty => 'พอร์ตโฟลิโอนี้ยังไม่มีสินทรัพย์';

  @override
  String get editAction => 'แก้ไข';

  @override
  String get removeFromGoal => 'นำออกจากเป้าหมาย';

  @override
  String get removeFromGoalSubtitle =>
      'สินทรัพย์จะไม่ถูกลบ — ย้ายไปยังสินทรัพย์ที่ยังไม่ได้จัดกลุ่ม';

  @override
  String get deletePermanently => 'ลบถาวร';

  @override
  String get deletePermanentlySubtitle =>
      'ลบสินทรัพย์นี้และข้อมูลทั้งหมดออกอย่างถาวร';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get addAssetBtn => 'เพิ่มสินทรัพย์';

  @override
  String get changeQtyBuyPrice => 'เปลี่ยนจำนวนหรือราคาซื้อ';

  @override
  String get whatIsItFor => 'ใช้เพื่ออะไร?';

  @override
  String get symbolHint => 'เช่น AAPL';

  @override
  String get quantityHint => 'เช่น 1.5';

  @override
  String get saveAsset => 'บันทึกสินทรัพย์';

  @override
  String get addAssetTitle => 'เพิ่มสินทรัพย์';

  @override
  String get categoryLabel => 'หมวดหมู่';

  @override
  String get amountLabel => 'จำนวนเงิน';

  @override
  String get symbolLabel => 'สัญลักษณ์';

  @override
  String get dateLabel => 'วันที่';

  @override
  String get pleaseFillAllFields => 'กรุณากรอกข้อมูลให้ครบถ้วน';

  @override
  String get noteLunchSalary => 'เช่น มื้อกลางวัน, เงินเดือน...';

  @override
  String get holdingsTitle => 'สินทรัพย์ทั้งหมด';

  @override
  String get viewAllHoldings => 'ดูสินทรัพย์ทั้งหมด';

  @override
  String get holdingsHint =>
      'หุ้นตัวเดียวกันรวมเป็นแถวเดียวจากทุกเป้าหมาย แตะที่ตำแหน่งเพื่อซื้อเพิ่ม/ขาย/ย้าย/ลบ';

  @override
  String get holdingsEmpty => 'ยังไม่มีสินทรัพย์';

  @override
  String get holdingsUnassigned => 'ยังไม่ได้จัดกลุ่ม';

  @override
  String get moveQuantityLabel => 'จำนวนที่จะย้าย';

  @override
  String get moveAllButton => 'ทั้งหมด';

  @override
  String get moveToLabel => 'ย้ายไปที่';

  @override
  String get moveStaysLabel => 'เหลือที่เดิม';
}
