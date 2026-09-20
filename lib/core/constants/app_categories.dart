class AppCategories {
  AppCategories._();

  static const List<CategoryItem> income = [
    CategoryItem(id: 'salary',           label: 'Salary',           group: 'Active Income'),
    CategoryItem(id: 'bonus',            label: 'Bonus',            group: 'Active Income'),
    CategoryItem(id: 'interest_saving',  label: 'Savings Interest', group: 'Passive Income'),
    CategoryItem(id: 'interest_fixed',   label: 'Fixed Deposit',    group: 'Passive Income'),
    CategoryItem(id: 'dividend_stock',   label: 'Stock Dividend',   group: 'Passive Income'),
    CategoryItem(id: 'dividend_fund',    label: 'Fund Dividend',    group: 'Passive Income'),
    CategoryItem(id: 'dividend_other',   label: 'Other Dividend',   group: 'Passive Income'),
    CategoryItem(id: 'rental',           label: 'Rental Income',    group: 'Passive Income'),
    CategoryItem(id: 'income_other',     label: 'Other Income',     group: 'Passive Income'),
  ];

  static const List<CategoryItem> expense = [
    CategoryItem(id: 'saving_invest',    label: 'Investment Saving',  group: 'Saving'),
    CategoryItem(id: 'saving_fund',      label: 'Fund Saving',        group: 'Saving'),
    CategoryItem(id: 'social_security',  label: 'Social Security',    group: 'Fixed'),
    CategoryItem(id: 'provident_fund',   label: 'Provident Fund',     group: 'Fixed'),
    CategoryItem(id: 'life_insurance',   label: 'Life Insurance',     group: 'Fixed'),
    CategoryItem(id: 'car_insurance',    label: 'Car Insurance',      group: 'Fixed'),
    CategoryItem(id: 'home_insurance',   label: 'Home Insurance',     group: 'Fixed'),
    CategoryItem(id: 'common_fee',       label: 'Common Area Fee',    group: 'Fixed'),
    CategoryItem(id: 'fixed_other',      label: 'Other Fixed',        group: 'Fixed'),
    CategoryItem(id: 'home_loan',        label: 'Home Loan',          group: 'Installment'),
    CategoryItem(id: 'property_invest',  label: 'Investment Property',group: 'Installment'),
    CategoryItem(id: 'car_loan',         label: 'Car Loan',           group: 'Installment'),
    CategoryItem(id: 'credit_card',      label: 'Credit Card',        group: 'Installment'),
    CategoryItem(id: 'personal_loan',    label: 'Personal Loan',      group: 'Installment'),
    CategoryItem(id: 'clothing',         label: 'Clothing',           group: 'Variable'),
    CategoryItem(id: 'travel_entertain', label: 'Travel & Leisure',   group: 'Variable'),
    CategoryItem(id: 'car_maintenance',  label: 'Car Maintenance',    group: 'Variable'),
    CategoryItem(id: 'grocery',          label: 'Grocery',            group: 'Variable'),
    CategoryItem(id: 'food',             label: 'Food & Dining',      group: 'Variable'),
    CategoryItem(id: 'transport_fuel',   label: 'Transport & Fuel',   group: 'Variable'),
    CategoryItem(id: 'child_care',       label: 'Child Care',         group: 'Variable'),
    CategoryItem(id: 'parent_care',      label: 'Parent Care',        group: 'Variable'),
    CategoryItem(id: 'income_tax',       label: 'Income Tax',         group: 'Variable'),
    CategoryItem(id: 'expense_other',    label: 'Other Expense',      group: 'Variable'),
    CategoryItem(id: 'healthcare',       label: 'Healthcare',         group: 'Variable'),
    CategoryItem(id: 'education',        label: 'Education',          group: 'Variable'),
    CategoryItem(id: 'utilities',        label: 'Utilities',          group: 'Fixed'),
    CategoryItem(id: 'subscription',     label: 'Subscription',       group: 'Variable'),
  ];

  static List<String> get incomeLabels  => income.map((c) => c.label).toList();
  static List<String> get expenseLabels => expense.map((c) => c.label).toList();
  static List<CategoryItem> forType(bool isIncome) => isIncome ? income : expense;

  // ── Thai display labels (display-only, DB always stores English labels) ──
  static const Map<String, String> labelTh = {
    // Income
    'Salary':             'เงินเดือน',
    'Bonus':              'โบนัส',
    'Savings Interest':   'ดอกเบี้ยออมทรัพย์',
    'Fixed Deposit':      'เงินฝากประจำ',
    'Stock Dividend':     'เงินปันผลหุ้น',
    'Fund Dividend':      'เงินปันผลกองทุน',
    'Other Dividend':     'เงินปันผลอื่นๆ',
    'Rental Income':      'รายได้ค่าเช่า',
    'Other Income':       'รายได้อื่นๆ',
    // Expense
    'Investment Saving':  'ออมเพื่อลงทุน',
    'Fund Saving':        'ออมกองทุน',
    'Social Security':    'ประกันสังคม',
    'Provident Fund':     'กองทุนสำรองเลี้ยงชีพ',
    'Life Insurance':     'ประกันชีวิต',
    'Car Insurance':      'ประกันรถยนต์',
    'Home Insurance':     'ประกันบ้าน',
    'Common Area Fee':    'ค่าส่วนกลาง',
    'Other Fixed':        'ค่าคงที่อื่นๆ',
    'Home Loan':          'สินเชื่อบ้าน',
    'Investment Property':'อสังหาฯ ลงทุน',
    'Car Loan':           'สินเชื่อรถยนต์',
    'Credit Card':        'บัตรเครดิต',
    'Personal Loan':      'สินเชื่อส่วนบุคคล',
    'Clothing':           'เสื้อผ้า',
    'Travel & Leisure':   'ท่องเที่ยวและนันทนาการ',
    'Car Maintenance':    'ค่าบำรุงรักษารถ',
    'Grocery':            'ของชำ',
    'Food & Dining':      'อาหารและร้านอาหาร',
    'Transport & Fuel':   'ขนส่งและน้ำมัน',
    'Child Care':         'ค่าดูแลบุตร',
    'Parent Care':        'ค่าดูแลผู้ปกครอง',
    'Income Tax':         'ภาษีเงินได้',
    'Other Expense':      'ค่าใช้จ่ายอื่นๆ',
    'Healthcare':         'สุขภาพและการแพทย์',
    'Education':          'การศึกษา',
    'Utilities':          'ค่าสาธารณูปโภค',
    'Subscription':       'ค่าสมาชิก/บริการ',
  };

  /// Returns the localized label for display. Falls back to English if not found.
  static String localizedLabel(String label, String languageCode) {
    if (languageCode == 'th') return labelTh[label] ?? label;
    return label;
  }

}

class CategoryItem {
  final String id;
  final String label;
  final String group;
  const CategoryItem({required this.id, required this.label, required this.group});
}
