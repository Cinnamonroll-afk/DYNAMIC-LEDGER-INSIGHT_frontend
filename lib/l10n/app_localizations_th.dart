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
  String get pricePerUnit => 'ราคาต่อหน่วย';

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
  String get sellAction => 'ขาย';

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
}
