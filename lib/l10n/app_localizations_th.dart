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
}
